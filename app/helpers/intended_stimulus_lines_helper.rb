# The Intended stimulus panel's lines beyond the prose: the workout goal, workout-level
# targets, and one line per movement. Each line carries whether it is calculated (derived or
# predicted) so the panel can tag it; CrossFit's and coaches' own values render untagged.
module IntendedStimulusLinesHelper
  STIMULUS_GOAL_LABELS = {
    'for_time' => 'For time', 'amrap' => 'AMRAP', 'intervals' => 'Intervals',
    'heavy_ascending' => 'Heavy day: build each set', 'heavy_hold_percent' => 'Heavy day: hold a percentage',
    'heavy_find_max' => 'Heavy day: find a max', 'skill_practice' => 'Skill practice'
  }.freeze

  # Workout-level low/high lines, in display order. clock: render seconds as MM:SS.
  STIMULUS_PAIR_LINES = [
    { label: 'Per round', prefix: :stimulus_round_seconds, clock: true, suffix: '' },
    { label: 'Load', prefix: :stimulus_percent_1rm, clock: false, suffix: '% of 1RM' },
    { label: 'Working sets', prefix: :stimulus_working_sets, clock: false, suffix: '' },
    { label: 'Rest', prefix: :stimulus_rest_seconds, clock: true, suffix: ' between sets' }
  ].freeze

  # Workout-level single-value interval lines (always seconds).
  STIMULUS_SINGLE_LINES = [
    { label: 'Work', field: :stimulus_interval_work_seconds, template: '≤ %s per interval' },
    { label: 'Rest', field: :stimulus_interval_rest_seconds_min, template: '≥ %s per interval' }
  ].freeze

  # Per-movement fields in display order.
  STIMULUS_MOVEMENT_FIELDS = %w[
    stimulus_loading stimulus_sets_max stimulus_duration_max stimulus_rest_max_seconds stimulus_effort
  ].freeze

  # [label, calculated] or nil.
  def stimulus_goal(workout)
    goal = workout.intended_stimulus_for(:stimulus_goal)
    [STIMULUS_GOAL_LABELS[goal.value], stimulus_calculated?(goal)] if goal&.value
  end

  def stimulus_goal_label(workout)
    stimulus_goal(workout)&.first
  end

  # [[label, text, calculated], ...] for each workout-level target that has a value.
  def stimulus_workout_lines(workout)
    [
      stimulus_range_line(workout),
      *STIMULUS_PAIR_LINES.map { |spec| stimulus_pair_line(workout, spec) },
      *STIMULUS_SINGLE_LINES.map { |spec| stimulus_single_line(workout, spec) }
    ].compact
  end

  # [[movement name, [[text, calculated], ...]], ...] for each exercise with any stimulus
  # value. Each value carries its own calculated flag, so a predicted effort beside CrossFit's
  # extracted loading tags only the effort.
  def stimulus_movement_lines(workout)
    workout.segments.flat_map(&:exercises).filter_map do |exercise|
      parts = stimulus_movement_parts(exercise)
      [exercise.movement.name, parts] if parts.any?
    end
  end

  private

  def stimulus_range_line(workout)
    range = intended_stimulus_range(workout)
    ['Expected', range, stimulus_pair(workout, :stimulus_range_low, :stimulus_range_high).last] if range
  end

  # [[text, calculated], ...] for each per-movement field with a value.
  def stimulus_movement_parts(exercise)
    STIMULUS_MOVEMENT_FIELDS.filter_map do |field|
      resolved = exercise.intended_stimulus_for(field)
      [stimulus_movement_text(field, resolved.value), stimulus_calculated?(resolved)] if resolved&.value
    end
  end

  def stimulus_pair_line(workout, spec)
    low, high, calculated = stimulus_pair(workout, :"#{spec[:prefix]}_low", :"#{spec[:prefix]}_high")
    return if low.blank? && high.blank?

    text = stimulus_bounds_text(low, high) { |value| spec[:clock] ? clock_duration(value) : value.to_s }
    [spec[:label], "#{text}#{spec[:suffix]}", calculated]
  end

  def stimulus_single_line(workout, spec)
    resolved = workout.intended_stimulus_for(spec[:field])
    return unless resolved&.value

    [spec[:label], format(spec[:template], clock_duration(resolved.value)), stimulus_calculated?(resolved)]
  end

  def stimulus_movement_text(field, value)
    case field
    when 'stimulus_sets_max' then value == 1 ? 'unbroken' : "#{value} sets or fewer"
    when 'stimulus_duration_max' then "≤ #{clock_duration(value)}"
    when 'stimulus_rest_max_seconds' then "rest ≤ #{clock_duration(value)}"
    else value.humanize
    end
  end
end
