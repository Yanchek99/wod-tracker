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

      create_log(resolve_workout)
    rescue CfWod::WorkoutParser::UnparseableError, WorkoutExtraction::LlmParser::ExtractionError,
           WorkoutExtraction::LlmParser::UnrepresentableWorkoutError, ActiveRecord::ActiveRecordError => e
      Result.new(status: :skipped, reason: e.message)
    end

    private

    attr_reader :row, :user

    def disregard?
      DISREGARD_SCORE_TYPES.include?(row[:score_type].to_s.strip)
    end

    def resolve_workout
      NameMatcher.call(row[:title]) || build_from_barbell_lift || build_from_heuristic_or_llm
    end

    def build_from_barbell_lift
      return nil if row[:barbell_lift].blank?

      text = BarbellLiftHeader.call(row)
      page = WodPageBuilder.call(row.merge(description: text), date: row[:date])
      workout = persist(CfWod::WorkoutParser.call(page))
      @built_from_barbell_lift = true
      workout
    end

    def build_from_heuristic_or_llm
      page = WodPageBuilder.call(row, date: row[:date])
      persist(heuristic_or_llm_workout(page))
    end

    def heuristic_or_llm_workout(page)
      CfWod::WorkoutParser.call(page)
    rescue CfWod::WorkoutParser::UnparseableError
      WorkoutExtraction::LlmParser.call(page.body_text, date: row[:date])
    end

    def persist(workout)
      return workout if workout.persisted?

      workout.save!
      workout.absorb_duplicate!
    end

    def create_log(workout)
      return Result.new(status: :already_imported) if existing_log?(workout)

      log = workout.logs.build(ScoreMapper.call(workout, row, user: user).merge(user: user))
      log.created_at = row[:date]
      log.save!
      # Not workout.single_max_finding? (workout_scoring.rb): that predicate requires
      # Exercise#max_load_prescription? which additionally requires duration_seconds to be
      # present, and CfWod::WorkoutParser#build_max_finding_exercise never sets it for the
      # "Find a N-rep-max <lift>" header BarbellLiftHeader synthesizes -- so it is never true for
      # a workout built via build_from_barbell_lift. Track that this row actually resolved through
      # that path instead, which is the real signal for "this is a single-lift PR row."
      build_movement_log(workout, log) if @built_from_barbell_lift
      Result.new(status: :imported)
    end

    def existing_log?(workout)
      user.logs.where(workout: workout).exists?(created_at: row[:date].all_day)
    end

    def build_movement_log(workout, log)
      exercise = workout.exercises_for_log_recording.first
      return unless exercise

      log.movement_logs.create!(movement: exercise.movement, load: log.score_value, reps: exercise.reps)
    end
  end
end
