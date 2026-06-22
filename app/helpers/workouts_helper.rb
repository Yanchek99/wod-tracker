module WorkoutsHelper
  def workout_objective(workout)
    return "#{pluralize workout.rounds, 'set'} for load" if workout.set_based_lifting?
    return for_time_objective(workout) if workout.rounds_for_time?
    return total_reps_clock_objective(workout) if workout.segmented_total_reps?
    return amrap_objective(workout) if workout.amrap?
    return "EMOM #{workout.time}" if workout.emom?
    return timed_rounds_objective(workout) if workout.timed_rounds?

    "#{workout.interval} for #{workout.score_measurement}"
  end

  def generate_workout_name
    "#{Current.user.email.first(2).upcase}-#{Time.current.strftime('%m%d%g-%H%M')}"
  end

  def for_time_objective(workout)
    return 'For Time' if workout.rounds == 1

    "#{pluralize workout.rounds, 'round'} for time"
  end

  def amrap_objective(workout)
    score = workout.fixed_rep_amrap? ? 'rounds and reps' : 'rounds'

    "As many #{score} as possible in #{pluralize workout.time, 'minute'}"
  end

  def total_reps_clock_objective(workout)
    "On a #{workout.time}-minute clock for total reps"
  end

  def timed_rounds_objective(workout)
    if workout.score_measurement == 'rep'
      "#{pluralize workout.rounds, 'round'}, complete as many reps as possible in #{pluralize workout.time, 'minute'} of"
    else
      "#{workout.rounds} #{workout.time}-minute rounds"
    end
  end
end
