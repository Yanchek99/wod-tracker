module WorkoutsHelper
  def workout_objective(workout)
    return "#{pluralize workout.rounds, 'round'} for time" if workout.rounds_for_time?
    return "As many rounds as possible in #{pluralize workout.time, 'minute'}" if workout.amrap?
    return "EMOM #{workout.time}" if workout.emom?
    return "#{workout.rounds} #{workout.time}-minute rounds" if workout.timed_rounds?
    "#{workout.interval} for #{workout.measurement.name}"
  end
end
