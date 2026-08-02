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
      NameMatcher.call(row[:title]) || build_from_barbell_lift || build_from_monostructural || build_from_bodyweight_max_rep
    end

    def build_from_barbell_lift
      persist(BarbellLiftBuilder.call(row))
    end

    def build_from_monostructural
      persist(MonostructuralDetector.call(row))
    end

    def build_from_bodyweight_max_rep
      persist(BodyweightMaxRepDetector.call(row))
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

    # Weight-scored workouts that total more than one DISTINCT movement (e.g. "CrossFit Total" =
    # back squat + shoulder press + deadlift, summed) represent a combined total. Building
    # MovementLogs from a single row's data would misattribute that total to the wrong movement,
    # so those are skipped. A single-movement workout, whether one exercise (a simple heavy
    # single) or many (a pyramid scheme, all the same movement), is safe to build per-set.
    def build_movement_logs(workout, log)
      exercises = workout.exercises_for_log_recording
      return unless workout.score_weight? && exercises.present? && exercises.map(&:movement).uniq.one?

      log.build_movement_logs
      assign_set_loads(log)
    end

    def assign_set_loads(log)
      sets = SetSchemeExtractor.call(row)
      return unless sets
      return unless sets.size == log.movement_logs.size

      log.movement_logs.zip(sets).each do |movement_log, set|
        movement_log.load = LoadEquivalence.to_lb(set[:load], user.load_display_unit.to_s)
      end
    end
  end
end
