require 'json'

class SugarwodImport
  class RowImporter
    DISREGARD_SCORE_TYPES = ['Checkbox', 'Points', 'Emoji Selection', 'Other / Text'].freeze

    Result = Struct.new(:status, :reason, keyword_init: true)

    def self.call(row, user:) = new(row, user: user).import

    def initialize(row, user:)
      @row = row
      @user = user
    end

    def import
      return Result.new(status: :skipped, reason: 'not a workout score type') if disregard?
      return Result.new(status: :skipped, reason: 'no score recorded') if row[:best_result_raw].blank?

      ActiveRecord::Base.transaction do
        workout = resolve_workout
        next Result.new(status: :skipped, reason: 'not a benchmark, barbell-lift, or single-modality workout') unless workout

        create_log(workout)
      end
    rescue ActiveRecord::ActiveRecordError => e
      Result.new(status: :skipped, reason: e.message)
    end

    private

    attr_reader :row, :user

    def disregard?
      DISREGARD_SCORE_TYPES.include?(row[:score_type].to_s.strip)
    end

    def resolve_workout
      NameMatcher.call(row[:title]) || build_from_barbell_lift || build_from_untagged_barbell_lift ||
        build_from_monostructural || build_from_max_rep
    end

    def build_from_barbell_lift
      persist(BarbellLiftBuilder.call(row))
    end

    def build_from_untagged_barbell_lift
      persist(UntaggedBarbellLiftDetector.call(row))
    end

    def build_from_monostructural
      persist(MonostructuralDetector.call(row))
    end

    def build_from_max_rep
      persist(MaxRepDetector.call(row))
    end

    def persist(workout)
      return nil unless workout
      return workout if workout.persisted?

      workout.save!
      workout.absorb_duplicate!
    end

    def create_log(workout)
      return Result.new(status: :already_imported) if existing_log?(workout)

      log = workout.logs.build(ScoreMapper.call(workout, row, user: user).merge(user: user))
      log.created_at = row[:date]
      build_movement_logs(workout, log)
      log.save!
      Result.new(status: :imported)
    end

    def existing_log?(workout)
      user.logs.where(workout: workout).exists?(created_at: row[:date].all_day)
    end

    # A single-movement workout, whether one exercise (a simple heavy single) or many (a pyramid
    # scheme, all the same movement), gets per-set MovementLogs via the scheme-extraction path. A
    # distinct-movement "total" workout (e.g. a 1-rep-max clean + bench press + overhead squat) gets
    # per-movement MovementLogs paired by position, but only when there's exactly one set_details
    # entry per movement with no extra attempts of any kind -- anything else (e.g. "CrossFit Total" =
    # back squat + shoulder press + deadlift with more attempts than movements) is skipped, since
    # building MovementLogs from ambiguous positional data would risk misattributing a load.
    def build_movement_logs(workout, log)
      exercises = workout.exercises_for_log_recording
      return unless workout.score_weight? && exercises.present?
      return unless single_movement?(exercises) || distinct_movement_total?(exercises)

      log.build_movement_logs
      single_movement?(exercises) ? assign_set_loads(log) : assign_total_lift_loads(log)
    end

    def single_movement?(exercises)
      exercises.map(&:movement).uniq.one?
    end

    # A "total" workout (e.g. a 1-rep-max clean + bench press + overhead squat) has one exercise per
    # distinct movement and one set_details entry per exercise, in the same order -- unlike repeated
    # sets of ONE movement, there is no rep scheme to infer: each exercise's own fixed reps apply as-is.
    # Requiring the RAW (unfiltered) set_details count to also match the movement count rules out
    # retry/ramp-up rows (e.g. a missed first attempt logged as an extra entry) whose successful-load
    # count only coincidentally matches -- pairing those positionally would misattribute a load to the
    # wrong movement, so anything with extra attempts of any kind falls through and is skipped instead.
    def distinct_movement_total?(exercises)
      movements = exercises.map(&:movement)
      movements.uniq.size == movements.size &&
        movements.size == successful_loads.size &&
        movements.size == parsed_set_details.size
    end

    def assign_set_loads(log)
      sets = SetSchemeExtractor.call(row)
      return unless sets
      return unless sets.size == log.movement_logs.size

      log.movement_logs.zip(sets).each do |movement_log, set|
        movement_log.load = LoadEquivalence.to_lb(set[:load], user.load_display_unit.to_s)
      end
    end

    def assign_total_lift_loads(log)
      return unless successful_loads.size == log.movement_logs.size

      log.movement_logs.zip(successful_loads).each do |movement_log, load|
        movement_log.load = LoadEquivalence.to_lb(load, user.load_display_unit.to_s)
      end
    end

    def successful_loads
      @successful_loads ||= parsed_set_details
                            .reject { |detail| detail['success'] == false }
                            .filter_map { |detail| Integer(detail['load'].to_s, exception: false) if detail['load'].present? }
    end

    def parsed_set_details
      @parsed_set_details ||= begin
        JSON.parse(row[:set_details].to_s)
      rescue JSON::ParserError
        []
      end
    end
  end
end
