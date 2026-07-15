module WorkoutScoring
  extend ActiveSupport::Concern

  def rep_scored_amrap?
    amrap? && (score_measurement == 'rep' || fixed_rep_amrap?)
  end

  def fixed_rep_amrap?
    amrap? && fixed_amrap_reps_per_round.present?
  end

  def set_based_lifting?
    set_based_lifting_structure? &&
      score_measurement == 'weight'
  end

  def max_finding?
    score_measurement == 'weight' && top_level_max_finding?
  end

  def calculated_lifting_score?
    set_based_lifting? || single_max_finding?
  end

  def exercises_for_log_recording
    return exercises unless set_based_lifting?

    governing_segment.rounds.times.flat_map { governing_segment_exercises }
  end

  def lifting_score(movement_logs)
    exercises_for_log_recording.zip(movement_logs).filter_map do |exercise, movement_log|
      successful_set_load(exercise, movement_log)
    end.max_by(&:value)
  end

  def governing_segment_exercises
    governing_segment&.exercises || []
  end

  def amrap_score_components
    return [] unless rep_scored_amrap?
    return [] if ascending_ladder? # variable reps per round; scored by raw total

    governing_segment_exercises.map.with_index do |exercise, index|
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

    score_measurement
  end

  private

  def set_based_lifting_structure?
    governing_segment&.rounds? || false
  end

  def top_level_max_finding?
    max_finding_exercises?(governing_segment_exercises)
  end

  def single_max_finding?
    max_finding? && max_finding_exercises.one?
  end

  def max_finding_exercises
    exercises.select(&:max_load_prescription?)
  end

  def max_finding_exercises?(exercises)
    exercises.any? && exercises.all?(&:max_load_prescription?)
  end

  def fixed_amrap_reps_per_round
    return nil if ascending_ladder? # reps grow each round, so there is no fixed per-round total
    return nil if governing_segment_exercises.empty?

    governing_segment_exercises.sum do |exercise|
      component = exercise.score_component
      return nil unless component

      component[:score_reps]
    end
  end

  def successful_set_load(exercise, movement_log)
    return unless completed_prescribed_reps?(exercise, movement_log)

    movement_log.prescription_metrics.find do |metric|
      Metric::LOAD_MEASUREMENTS.include?(metric.measurement) && metric.value.present?
    end
  end

  def completed_prescribed_reps?(exercise, movement_log)
    prescribed_reps = exercise.prescription_metrics.find(&:rep?)&.value
    completed_reps = movement_log.prescription_metrics.find(&:rep?)&.value

    prescribed_reps.present? && completed_reps.present? && completed_reps >= prescribed_reps
  end
end
