module ExercisesHelper
  def exercise_message(exercise)
    "#{exercise_movement_msg(exercise)}#{exercise_measurement_unit_msg(exercise)}#{exercise_rx_msg(exercise)}"
  end

  def exercise_rx_msg(exercise)
    " #{exercise.male_rx}#{'/' if exercise.male_rx && exercise.female_rx}#{exercise.female_rx}"
  end

  def exercise_movement_msg(exercise)
    pluralize(exercise.reps, exercise.movement.name)
  end

  def exercise_measurement_unit_msg(exercise)
    " #{pluralize exercise.measurement_value, exercise.movement.measurement.unit}" if exercise.measurement_value.present?
  end
end
