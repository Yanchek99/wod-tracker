# The Intended stimulus panel's lines beyond the prose: the workout goal, workout-level
# targets, and one line per movement. Each line carries whether it is calculated (derived or
# predicted) so the panel can tag it; CrossFit's and coaches' own values render untagged.
module IntendedStimulusLinesHelper
  STIMULUS_GOAL_LABELS = {
    'for_time' => 'For time', 'amrap' => 'AMRAP', 'intervals' => 'Intervals',
    'heavy_ascending' => 'Heavy day: build each set', 'heavy_hold_percent' => 'Heavy day: hold a percentage',
    'heavy_find_max' => 'Heavy day: find a max', 'skill_practice' => 'Skill practice'
  }.freeze

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
      stimulus_pair_line(workout, 'Per round', :stimulus_round_seconds) { |value| clock_duration(value) },
      stimulus_pair_line(workout, 'Load', :stimulus_percent_1rm, suffix: '% of 1RM'),
      stimulus_pair_line(workout, 'Working sets', :stimulus_working_sets),
      stimulus_pair_line(workout, 'Rest', :stimulus_rest_seconds, suffix: ' between sets') { |value| clock_duration(value) },
      stimulus_single_line(workout, 'Work', :stimulus_interval_work_seconds, '≤ %s per interval'),
      stimulus_single_line(workout, 'Rest', :stimulus_interval_rest_seconds_min, '≥ %s per interval')
    ].compact
  end

  # [[movement name, text, calculated], ...] for each exercise with any stimulus value.
  def stimulus_movement_lines(workout)
    workout.segments.flat_map(&:exercises).filter_map do |exercise|
      resolved = Exercise::STIMULUS_FIELDS.index_with { |field| exercise.intended_stimulus_for(field) }.compact
      resolved.select! { |_, stimulus_value| stimulus_value.value }
      parts = stimulus_movement_parts(resolved.transform_values(&:value))
      [exercise.movement.name, parts.join(' · '), resolved.values.any? { |value| stimulus_calculated?(value) }] if parts.any?
    end
  end

  private

  def stimulus_range_line(workout)
    range = intended_stimulus_range(workout)
    ['Expected', range, stimulus_pair(workout, :stimulus_range_low, :stimulus_range_high).last] if range
  end

  def stimulus_pair_line(workout, label, prefix, suffix: '', &format)
    low, high, calculated = stimulus_pair(workout, :"#{prefix}_low", :"#{prefix}_high")
    return if low.blank? && high.blank?

    [label, "#{stimulus_bounds_text(low, high, &format || :to_s.to_proc)}#{suffix}", calculated]
  end

  def stimulus_single_line(workout, label, field, template)
    resolved = workout.intended_stimulus_for(field)
    [label, format(template, clock_duration(resolved.value)), stimulus_calculated?(resolved)] if resolved&.value
  end

  def stimulus_movement_parts(values)
    [
      values['stimulus_loading']&.humanize,
      stimulus_sets_text(values['stimulus_sets_max']),
      ("≤ #{clock_duration(values['stimulus_duration_max'])}" if values['stimulus_duration_max']),
      ("rest ≤ #{clock_duration(values['stimulus_rest_max_seconds'])}" if values['stimulus_rest_max_seconds']),
      values['stimulus_effort']&.humanize
    ].compact
  end

  def stimulus_sets_text(sets)
    return unless sets

    sets == 1 ? 'unbroken' : "#{sets} sets or fewer"
  end
end
