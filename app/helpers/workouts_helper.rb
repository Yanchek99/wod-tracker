module WorkoutsHelper
  def workout_objective(workout)
    return weight_objective(workout) if workout.score_measurement == 'weight'
    return achievement_objective(workout) if workout.single_achievement_test?
    return ascending_ladder_objective(workout) if workout.ascending_ladder?
    return for_time_objective(workout) if workout.rounds_for_time?

    clock_objective(workout)
  end

  # Mirrors the exercise line's own wording (leading_prescription's "max reps"/"max calories"/
  # "max height") so the workout-level objective and the exercise bullet never disagree.
  def achievement_objective(workout)
    exercise = workout.governing_segment_exercises.first
    "For #{leading_prescription(exercise).text}"
  end

  # Weight-scored workouts are always "for load" -- the only exception is a find-a-max
  # prescription with a time window, which gets its own "in N minutes" phrasing.
  def weight_objective(workout)
    return max_finding_objective(workout) if workout.max_finding?

    'For load'
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

  # Plain-text rendering of a workout for the paste-text box, so switching to the unstructured
  # edit view shows the current workout instead of a blank textarea. Mirrors show.html.slim's
  # assembly of workout_objective/segment_objective/measurable_message -- the closest existing
  # convention for describing a workout as text, just written as lines instead of HTML.
  def workout_as_text(workout)
    lines = [workout.name, [team_objective(workout), workout_objective(workout)].compact.join(' ')]
    workout.distinct_segments.each_with_index { |segment, index| lines.concat(segment_as_text_lines(workout, segment, index)) }
    lines.concat(workout_as_text_trailer(workout)).compact_blank.join("\n")
  end

  def for_time_objective(workout)
    rounds = workout.governing_segment&.rounds || 1
    return 'For Time' if rounds == 1

    "#{pluralize rounds, 'round'} for time"
  end

  def amrap_objective(workout)
    "As many #{amrap_score_word(workout)} as possible in #{pluralize workout.governing_segment.time_seconds / 60, 'minute'}"
  end

  # "rounds and reps" once a per-round total is known, "rounds" for a multi-movement AMRAP without
  # one, or the score measurement itself (e.g. "reps") for a single-movement open-ended AMRAP like
  # Open 12.1's max-rep burpees, where there's no round structure to speak of.
  def amrap_score_word(workout)
    return 'rounds and reps' if workout.fixed_rep_amrap?
    return workout.score_measurement.pluralize if workout.governing_segment_exercises.one?

    'rounds'
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

  # Collapses a single-movement set-based lifting workout's sets into one rep-scheme line
  # ("10-10-7-7-3-3-3 Deadlift") in place of one identical line per set. Returns nil -- so the
  # caller falls back to rendering each exercise -- when the workout isn't a single-movement
  # find-a-max scheme, or when the sets carry prescribed loads worth showing per set.
  def lifting_sets_line(workout)
    return unless workout.set_based_lifting?

    sets = workout.exercises_for_log_recording
    return unless sets.map(&:movement).uniq.one?
    return if sets.any? { |exercise| prescribed_load?(exercise) }

    "#{sets.map(&:reps).join('-')} #{sets.first.movement.name}"
  end

  def total_reps_clock_objective(workout)
    rounds = workout.segment_group_rounds
    return "#{pluralize rounds, 'round'} for total reps of" if rounds > 1

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

  private

  # A load worth showing per set: a real prescribed weight, not the load: 0 find-a-max sentinel.
  def prescribed_load?(exercise)
    exercise.female_load.present? || exercise.male_load.present? || exercise.load.to_i.positive?
  end

  # workout_as_text's per-segment lines: the segment's own prescription (suppressed for the
  # governing segment, since workout_objective already conveyed its scheme) followed by each
  # exercise's line.
  def segment_as_text_lines(workout, segment, index)
    governing = segment == workout.governing_segment
    objective = governing ? nil : segment_objective(segment, then_prefix: index.positive?)
    set_based_line = lifting_sets_line(workout) if governing
    exercise_lines = set_based_line ? [set_based_line] : segment.exercises.map { |exercise| measurable_message(exercise) }
    [objective, *exercise_lines, segment_rest(segment)].compact
  end

  def workout_as_text_trailer(workout)
    trailer = []
    trailer << "Time cap: #{workout.time_cap}" if workout.time_cap_seconds.present?
    trailer << workout.notes.to_plain_text.strip if workout.notes.present?
    trailer
  end
end
