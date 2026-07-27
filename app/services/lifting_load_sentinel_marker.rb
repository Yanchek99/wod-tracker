# Applies the load: 0 "find-a-max" sentinel to load-bearing exercises in a weight-scored workout
# that carry no explicit load, so the log form shows a Load field for each set. Covers both
# manually scored lifts (e.g. an Open-style complex) and calculated set-based lifting (e.g.
# "Deadlift 10-10-7-7-3-3-3"), whose per-set loads the athlete records. Called by both scrape
# parsers and reused by the #1783 backfill for pre-sentinel data.
class LiftingLoadSentinelMarker
  def self.call(workout, exercise_lines: nil) = new(workout, exercise_lines: exercise_lines).call

  def initialize(workout, exercise_lines: nil)
    @workout = workout
    @raw_lines_by_exercise = Array(exercise_lines).to_h { |line| [line[:exercise], line[:raw_line]] }
  end

  def call
    return unless workout.score_type == 'weight'

    marked = mark_candidates
    unmark(marked) if marking_created_max_finding?
  end

  private

  attr_reader :workout, :raw_lines_by_exercise

  def mark_candidates
    segment_exercises.filter_map do |exercise|
      mark_load_bearing_exercise(exercise)
    end
  end

  def mark_load_bearing_exercise(exercise)
    return unless load_missing?(exercise)
    return unless LoadBearingMovement.call(exercise.movement, raw_text: raw_lines_by_exercise[exercise])

    exercise.load = 0
    exercise
  end

  def load_missing?(exercise)
    exercise.load.blank? && exercise.female_load.blank? && exercise.male_load.blank?
  end

  def unmark(exercises)
    exercises.each { |exercise| exercise.load = nil }
  end

  # A set-based lifting workout is already a calculated-score workout whose per-set loads the
  # athlete records, so its sentinels stay. Otherwise, back out any sentinel that would turn a
  # manually scored workout into a max-finding one -- flipping a type-in-your-own-score workout
  # into a calculated one the athlete never asked for.
  #
  # Parser-built workouts are unsaved, so Workout#calculated_lifting_score? cannot see
  # has_many-through exercises yet; the segment exercises are checked directly for that reason.
  def marking_created_max_finding?
    return false if workout.set_based_lifting?

    workout.calculated_lifting_score? || (segment_exercises.one? && segment_exercises.first.max_load_prescription?)
  end

  def segment_exercises
    @segment_exercises ||= workout.segments.flat_map(&:exercises)
  end
end
