module CfWod
  class WorkoutParser
    class UnparseableError < StandardError; end

    def self.call(wod_page) = new(wod_page).parse

    def initialize(wod_page)
      @wod_page = wod_page
    end

    def parse
      header, rest = wod_page.body_text.split("\n", 2)
      attrs = WorkoutFormatClassifier.call(header)
      workout = Workout.new(name: "CF-#{wod_page.slug}", notes: wod_page.body_text, **attrs.except(:lift_name))
      build_workout_content(workout, attrs, rest)
      validate_workout!(workout)
      workout
    end

    private

    attr_reader :wod_page

    def build_workout_content(workout, attrs, rest)
      if attrs[:lift_name]
        build_max_finding_exercise(workout, attrs[:lift_name])
      else
        build_from_body(workout, rest.to_s)
      end
    end

    def validate_workout!(workout)
      raise UnparseableError, "built workout failed validation: #{workout.errors.full_messages.join(', ')}" unless workout.valid?
    end

    def build_max_finding_exercise(workout, lift_name)
      movement = lookup_movement!(lift_name)
      workout.exercises.build(movement: movement, position: 1, reps: 1, load: 0)
    end

    def build_from_body(workout, body)
      split = PartSplitter.call(body)
      exercise_lines = build_exercise_lines(workout, split[:parts])
      return unless split[:prescription_text]

      clauses = PrescriptionClauseParser.call(split[:prescription_text])
      PrescriptionClauseAssigner.call(exercise_lines, clauses)
    end

    def build_exercise_lines(workout, parts)
      top_level_position = 0
      exercise_lines = []

      parts.each do |part|
        if part[:segment]
          top_level_position += 1
          segment = workout.segments.build(name: part[:name], time_seconds: part[:time_seconds],
                                           rounds: part[:rounds], position: top_level_position)
          part[:lines].each_with_index do |line, index|
            exercise_lines << build_exercise_line(workout, line, position: index + 1, segment: segment)
          end
        else
          part[:lines].each do |line|
            top_level_position += 1
            exercise_lines << build_exercise_line(workout, line, position: top_level_position)
          end
        end
      end

      exercise_lines
    end

    def build_exercise_line(workout, line, position:, segment: nil)
      attrs = ExerciseLineParser.call(line)
      raise UnparseableError, "unrecognized exercise line: #{line.inspect}" unless attrs

      movement = lookup_movement!(attrs[:movement_name])
      exercise = workout.exercises.build(attrs.except(:movement_name).merge(movement: movement, position: position,
                                                                            segment: segment))
      { exercise: exercise, raw_line: line }
    end

    def lookup_movement!(name)
      MovementLookup.call(name) || raise(UnparseableError, "unrecognized movement: #{name.inspect}")
    end
  end
end
