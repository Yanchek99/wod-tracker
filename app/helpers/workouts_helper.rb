module WorkoutsHelper
  def workout_objective(workout)
    return ascending_ladder_objective(workout) if workout.ascending_ladder?
    return max_finding_objective(workout) if workout.max_finding?
    return "#{pluralize workout.set_based_lifting_set_count, 'set'} for load" if workout.set_based_lifting?
    return for_time_objective(workout) if workout.rounds_for_time?

    clock_objective(workout)
  end

  def clock_objective(workout)
    return total_reps_clock_objective(workout) if workout.segmented_total_reps?
    return amrap_objective(workout) if workout.amrap?
    return "EMOM #{workout.governing_segment.time_seconds / 60}" if workout.emom?
    return timed_rounds_objective(workout) if workout.timed_rounds?
    return "For #{workout.score_measurement}" if workout.governing_segment.blank?

    "#{workout.governing_segment.interval_scheme} for #{workout.score_measurement}"
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
    rounds = workout.governing_segment&.rounds || 1
    return 'For Time' if rounds == 1

    "#{pluralize rounds, 'round'} for time"
  end

  def amrap_objective(workout)
    score = workout.fixed_rep_amrap? ? 'rounds and reps' : 'rounds'

    "As many #{score} as possible in #{pluralize workout.governing_segment.time_seconds / 60, 'minute'}"
  end

  def ascending_ladder_objective(workout)
    ladder = "ascending ladder, +#{workout.ladder_step} reps each round"
    return ladder.upcase_first if workout.governing_segment&.time_seconds.blank?

    "As many reps as possible in #{pluralize workout.governing_segment.time_seconds / 60, 'minute'}, #{ladder}"
  end

  def max_finding_objective(workout)
    return "Find a max load in #{pluralize workout.governing_segment.time_seconds / 60, 'minute'}" if workout.governing_segment&.time_seconds.present?

    'For load'
  end

  def total_reps_clock_objective(workout)
    "On a #{workout.segments.sum(&:time_seconds) / 60}-minute clock for total reps"
  end

  def timed_rounds_objective(workout)
    segment = workout.governing_segment
    if workout.score_measurement == 'rep'
      "#{pluralize segment.rounds, 'round'}, complete as many reps as possible in #{pluralize segment.time_seconds / 60, 'minute'} of"
    else
      "#{segment.rounds} #{segment.time_seconds / 60}-minute rounds"
    end
  end
end
