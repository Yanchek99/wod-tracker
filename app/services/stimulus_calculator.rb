# Calculates a workout's intended stimulus from its prescription, the way a programmer writes it
# before anyone has done the workout (#1992, cf/docs/decisions.md 2026-11-11): Programming
# Basics' time method, loading as prescribed load against a reference load, a sets guide from
# the load class, heavy-day and interval rules. Reads only the prescription and the reference
# table (StimulusReference) -- no athlete logs, no LLM. CrossFit's posted Stimulus and Strategy
# is used to check the result (StimulusAccuracy), never as an input.
module StimulusCalculator
  module_function

  # Workout-level stimulus values, nils removed.
  def workout(workout, reference = StimulusReference.current)
    goal = goal(workout)
    values = { stimulus_goal: goal }
    values.merge!(Timing.call(workout, reference)) if %w[for_time amrap].include?(goal)
    values.merge!(HeavyDay.call(workout, reference)) if workout.score_weight?
    values.merge!(Interval.call(workout, reference)) if goal == 'intervals'
    values.compact
  end

  # Per-exercise stimulus values, nils removed.
  def exercise(exercise, reference = StimulusReference.current)
    return {} if exercise.movement.family_rest?

    loading = Loading.call(exercise, reference)
    Effort.call(exercise, loading, reference).merge(stimulus_loading: loading).compact
  end

  def goal(workout)
    return HeavyDay.goal(workout) if workout.score_weight?
    return 'intervals' if Interval.segment(workout)
    return 'amrap' if workout.amrap?

    'for_time' if workout.score_time?
  end
end
