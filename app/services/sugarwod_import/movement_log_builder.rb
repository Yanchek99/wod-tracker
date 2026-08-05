require 'json'

class SugarwodImport
  class MovementLogBuilder
    def self.call(workout, log, row:, user:) = new(workout, log, row: row, user: user).build

    def initialize(workout, log, row:, user:)
      @workout = workout
      @log = log
      @row = row
      @user = user
    end

    # A single-movement workout, whether one exercise (a simple heavy single) or many (a pyramid
    # scheme, all the same movement), gets per-set MovementLogs via the scheme-extraction path. A
    # distinct-movement "total" workout (e.g. a 1-rep-max clean + bench press + overhead squat) gets
    # per-movement MovementLogs paired by position, but only when there's exactly one set_details
    # entry per movement with no extra attempts of any kind -- anything else (e.g. "CrossFit Total" =
    # back squat + shoulder press + deadlift with more attempts than movements) is skipped, since
    # building MovementLogs from ambiguous positional data would risk misattributing a load.
    #
    # Every non-weight workout the importer resolves (MonostructuralDetector, MaxRepDetector,
    # MaxDistanceDetector, or a single-movement catalog match) has exactly one exercise, so the
    # log's own score_value -- SugarWOD's one aggregate result for the row -- IS that exercise's
    # actual performance, not just a placeholder default.
    def build
      exercises = workout.exercises_for_log_recording
      return if exercises.blank?
      return build_lifting_movement_logs(exercises) if workout.score_weight?
      return unless single_movement?(exercises)

      log.build_movement_logs
      assign_single_exercise_result
    end

    private

    attr_reader :workout, :log, :row, :user

    def build_lifting_movement_logs(exercises)
      return unless single_movement?(exercises) || distinct_movement_total?(exercises)

      log.build_movement_logs
      single_movement?(exercises) ? assign_set_loads : assign_total_lift_loads
    end

    def assign_single_exercise_result
      value = log.score_value
      return unless value.is_a?(Numeric)

      movement_log = log.movement_logs.first
      case log.score_type
      when 'rep' then movement_log.reps = value
      when 'time' then movement_log.duration_seconds = value
      when 'calorie' then movement_log.calories = value
      when 'inch', 'foot', 'meter'
        movement_log.distance = value
        movement_log.distance_unit = log.score_type
      end
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

    def assign_set_loads
      sets = SetSchemeExtractor.call(row)
      return unless sets
      return unless sets.size == log.movement_logs.size

      log.movement_logs.zip(sets).each do |movement_log, set|
        movement_log.load = LoadEquivalence.to_lb(set[:load], user.load_display_unit.to_s)
      end
    end

    def assign_total_lift_loads
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
