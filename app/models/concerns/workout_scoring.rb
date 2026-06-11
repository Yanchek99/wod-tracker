module WorkoutScoring
  extend ActiveSupport::Concern

  def rep_scored_amrap?
    amrap? && (score_type == 'rep' || fixed_rep_amrap?)
  end

  def fixed_rep_amrap?
    amrap? && fixed_amrap_reps_per_round.present?
  end

  def set_based_lifting?
    set_based_lifting_structure? &&
      score_type == 'weight' &&
      top_level_exercises.any?(&:load_bearing?)
  end

  def exercises_for_log_recording
    return exercises unless set_based_lifting?

    rounds.times.flat_map { top_level_exercises }
  end

  def lifting_score(movement_logs)
    exercises_for_log_recording.zip(movement_logs).filter_map do |exercise, movement_log|
      successful_set_load(exercise, movement_log)
    end.max_by(&:value)
  end

  def top_level_exercises
    exercises.reject(&:segment_id)
  end

  def amrap_score_components
    return [] unless rep_scored_amrap?

    top_level_exercises.map.with_index do |exercise, index|
      component = exercise.score_component
      next unless component

      component.merge(index: index, exercise_id: exercise.id)
    end.compact
  end

  def amrap_reps_per_round
    return nil unless amrap?

    fixed_amrap_reps_per_round
  end

  def log_metric_measurement
    return :rep if fixed_rep_amrap?

    score_type
  end

  private

  def set_based_lifting_structure?
    rounds.present? &&
      rounds.positive? &&
      time.blank? &&
      interval.blank?
  end

  def fixed_amrap_reps_per_round
    return nil if top_level_exercises.empty?

    top_level_exercises.sum do |exercise|
      component = exercise.score_component
      return nil unless component

      component[:score_reps]
    end
  end

  def successful_set_load(exercise, movement_log)
    return unless completed_prescribed_reps?(exercise, movement_log)

    movement_log.metrics.find do |metric|
      Metric::LOAD_MEASUREMENTS.include?(metric.measurement) && metric.value.present?
    end
  end

  def completed_prescribed_reps?(exercise, movement_log)
    prescribed_reps = exercise.metrics.find(&:rep?)&.value
    completed_reps = movement_log.metrics.find(&:rep?)&.value

    prescribed_reps.present? && completed_reps.present? && completed_reps >= prescribed_reps
  end
end
