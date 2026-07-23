class ManuallyScoredLiftingLoadMarker
  def self.call(workout, exercise_lines: nil) = new(workout, exercise_lines: exercise_lines).call

  def initialize(workout, exercise_lines: nil)
    @workout = workout
    @raw_lines_by_exercise = Array(exercise_lines).to_h { |line| [line[:exercise], line[:raw_line]] }
  end

  def call
    return unless manually_scored_lifting_workout?

    marked = mark_candidates
    unmark(marked) if calculated_lifting_score_after_marking?
  end

  private

  attr_reader :workout, :raw_lines_by_exercise

  def manually_scored_lifting_workout?
    workout.score_type == 'weight' && !workout.calculated_lifting_score?
  end

  def mark_candidates
    workout.segments.flat_map(&:exercises).filter_map do |exercise|
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

  def calculated_lifting_score_after_marking?
    workout.calculated_lifting_score? || (segment_exercises.one? && segment_exercises.first.max_load_prescription?)
  end

  def segment_exercises
    workout.segments.flat_map(&:exercises)
  end
end
