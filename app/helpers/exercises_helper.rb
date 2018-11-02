module ExercisesHelper
  def exercise_message(exercise)
    "#{exercise_movement_msg(exercise)}#{exercise_measurement_unit_msg(exercise)}#{exercise_rx_msg(exercise)}"
  end

  def exercise_rx_msg(exercise)
    " #{exercise.male_rx}#{'/' if exercise.male_rx && exercise.female_rx}#{exercise.female_rx}"
  end

  def exercise_movement_msg(exercise)
    rep_metric = exercise.metrics.where(measurement: :rep).first
    return "Max reps #{exercise.movement.name}" if rep_metric.nil?
    return exercise.movement.name if exercise.workout.interval?

    pluralize(rep_metric.value, exercise.movement.name)
  end

  def exercise_measurement_unit_msg(exercise)
    msg = ""
    exercise.metrics.where.not(measurement: :rep).each do |metric|
      msg << " / #{pluralize metric.value, measurement_unit(metric)}"
    end
    return msg
  end
end
