class SugarwodImport
  class RowImporter
    DISREGARD_SCORE_TYPES = ['Checkbox', 'Points', 'Emoji Selection', 'Other / Text'].freeze
    DETECTOR_STRATEGIES = [
      BarbellLiftBuilder, UntaggedBarbellLiftDetector, MonostructuralDetector, MaxRepDetector, MaxDistanceDetector
    ].freeze
    # Keeps the advisory lock key within Postgres's signed-bigint range (pg_advisory_xact_lock
    # takes a bigint).
    LOCK_KEY_MODULUS = 2**62

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
      NameMatcher.call(row[:title]) || detected_workout
    end

    def detected_workout
      DETECTOR_STRATEGIES.each do |detector|
        workout = persist(detector.call(row))
        return workout if workout
      end
      nil
    end

    def persist(workout)
      return nil unless workout
      return workout if workout.persisted?

      workout.save!
      workout.absorb_duplicate!
    end

    def create_log(workout)
      acquire_import_lock(workout)
      return Result.new(status: :already_imported) if existing_log?(workout)

      attrs = ScoreMapper.call(workout, row, user: user)
      return Result.new(status: :skipped, reason: 'best_result_raw is not a valid score for this workout') unless attrs

      log = workout.logs.build(attrs.merge(user: user))
      log.created_at = row[:date]
      MovementLogBuilder.call(workout, log, row: row, user: user)
      log.save!
      Result.new(status: :imported)
    end

    def existing_log?(workout)
      user.logs.where(workout: workout).exists?(created_at: row[:date].all_day)
    end

    # Serializes concurrent imports of the same user/workout/date within this row's own
    # transaction: existing_log?'s read and the eventual insert would otherwise race (two
    # concurrent imports -- e.g. the same CSV uploaded twice -- could both see no existing log
    # and both insert). Transaction-scoped, so it releases automatically at commit/rollback, and
    # keyed off the exact identity existing_log? dedupes on, so it never blocks unrelated
    # user/workout/date imports from proceeding in parallel.
    def acquire_import_lock(workout)
      key = Digest::SHA256.hexdigest("#{user.id}:#{workout.id}:#{row[:date]}").to_i(16) % LOCK_KEY_MODULUS
      ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql(['SELECT pg_advisory_xact_lock(?)', key]))
    end
  end
end
