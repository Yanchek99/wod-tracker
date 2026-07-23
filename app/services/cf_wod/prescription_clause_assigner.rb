module CfWod
  class PrescriptionClauseAssigner
    STOPWORDS = %w[a an the to of and or with for on at in].freeze
    LOAD_UNITS = %i[lb kg pood].freeze
    DISTANCE_UNITS = %i[inch foot meter].freeze

    def self.call(exercise_lines, clauses) = new(exercise_lines, clauses).assign

    def initialize(exercise_lines, clauses)
      @exercise_lines = exercise_lines
      @clauses = clauses
      @bound = Set.new
    end

    def assign
      validate_clause_symmetry!
      clauses[:female].each_with_index do |female_values, index|
        bind_clause_pair(female_values, clauses[:male][index])
      end
    end

    private

    attr_reader :exercise_lines, :clauses, :bound

    def validate_clause_symmetry!
      female_clauses = clauses[:female]
      male_clauses = clauses[:male]
      if female_clauses.length != male_clauses.length
        raise WorkoutParser::UnparseableError,
              "prescription clause count mismatch: #{female_clauses.length} female clause(s), " \
              "#{male_clauses.length} male clause(s)"
      end

      female_clauses.each_with_index { |female_values, index| validate_clause_pair_symmetry!(female_values, male_clauses[index], index) }
    end

    def validate_clause_pair_symmetry!(female_values, male_values, index)
      return if female_values.length == male_values.length

      raise WorkoutParser::UnparseableError,
            "prescription clause #{index} value-count mismatch: #{female_values.length} female value(s), " \
            "#{male_values.length} male value(s)"
    end

    def bind_clause_pair(female_values, male_values)
      candidates = matching_candidates(female_values.first)
      if candidates.empty?
        implement = female_values.first[:implement]
        raise WorkoutParser::UnparseableError, "prescription clause matched no movement: #{implement.inspect}"
      end

      candidates.each do |candidate|
        bound << candidate
        female_values.zip(male_values).each { |female_value, male_value| apply_value(candidate, female_value, male_value) }
      end
    end

    def matching_candidates(primary_value)
      by_token = unbound_lines.select { |line| shares_token?(primary_value[:implement], line[:raw_line]) }
      by_token.presence || unbound_lines.select { |line| barbell_family?(line) }
    end

    def unbound_lines
      exercise_lines.reject { |line| bound.include?(line) }
    end

    def shares_token?(implement, raw_line)
      tokens(implement).intersect?(tokens(raw_line))
    end

    def tokens(text)
      text.to_s.downcase.split(/[^a-z]+/).compact_blank - STOPWORDS
    end

    def barbell_family?(line)
      ::LoadBearingMovement.call(line[:exercise].movement, raw_text: line[:raw_line])
    end

    def apply_value(candidate, female_value, male_value)
      exercise = candidate[:exercise]
      if LOAD_UNITS.include?(female_value[:unit])
        apply_load(exercise, female_value, male_value)
      elsif DISTANCE_UNITS.include?(female_value[:unit])
        apply_distance(exercise, female_value, male_value)
      end
    end

    def apply_load(exercise, female_value, male_value)
      exercise.female_load = LoadEquivalence.to_lb(female_value[:value], female_value[:unit])
      exercise.male_load = LoadEquivalence.to_lb(male_value[:value], male_value[:unit])
    end

    def apply_distance(exercise, female_value, male_value)
      exercise.female_distance = female_value[:value]
      exercise.male_distance = male_value[:value]
      exercise.distance_unit = female_value[:unit]
    end
  end
end
