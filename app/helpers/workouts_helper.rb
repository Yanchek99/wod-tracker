module WorkoutsHelper
  def workout_objective(workout)
    return ascending_ladder_objective(workout) if workout.ascending_ladder?
    return max_finding_objective(workout) if workout.max_finding?
    return "#{pluralize workout.rounds, 'set'} for load" if workout.set_based_lifting?
    return for_time_objective(workout) if workout.rounds_for_time?

    clock_objective(workout)
  end

  def clock_objective(workout)
    return total_reps_clock_objective(workout) if workout.segmented_total_reps?
    return amrap_objective(workout) if workout.amrap?
    return "EMOM #{workout.time}" if workout.emom?
    return timed_rounds_objective(workout) if workout.timed_rounds?

    "#{workout.interval} for #{workout.score_measurement}"
  end

  # Short descriptor for a shared-work workout: "Partner" for two athletes,
  # "Team of N" for more. nil for an ordinary individual workout.
  def team_objective(workout)
    return unless workout.team?

    workout.partner? ? 'Partner' : "Team of #{workout.team_size}"
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

  def ascending_ladder_objective(workout)
    ladder = "ascending ladder, +#{workout.ladder_step} reps each round"
    return ladder.upcase_first if workout.time.blank?

    "As many reps as possible in #{pluralize workout.time, 'minute'}, #{ladder}"
  end

  def max_finding_objective(workout)
    return "Find a max load in #{pluralize workout.time, 'minute'}" if workout.time.present?

    'For load'
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
