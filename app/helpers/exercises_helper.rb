module ExercisesHelper
  def exercise_message(exercise)
    msg = ''
    msg << pluralize(exercise.reps, exercise.movement.name)
    msg << " #{pluralize exercise.measurement_value, exercise.movement.measurement_unit}" if exercise.measurement_value.present?
    msg << rx_values(exercise)
  end

  def rx_values(exercise)
    " #{exercise.male_rx}#{'/' if exercise.male_rx && exercise.female_rx}#{exercise.female_rx}"
  end
end
