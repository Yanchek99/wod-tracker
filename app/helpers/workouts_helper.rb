module WorkoutsHelper
  def workout_objective(workout)
    return "#{pluralize workout.rounds, 'round'} for time" if workout.rounds_for_time?
    return "As many rounds as possible in #{pluralize workout.time, 'minute'}" if workout.amrap?
    return "EMOM #{workout.time}" if workout.emom?
    return "#{workout.rounds} #{workout.time}-minute rounds" if workout.timed_rounds?

    "#{workout.interval} for #{workout.metric.measurement}"
  end

  def generate_workout_name
    "#{Current.user.email.first(2).upcase}-#{Time.current.strftime('%m%d%g-%H%M')}"
  end
end
