module StimulusCalculator
  # A weight-scored heavy day (L2 guide, Heavy Days). The L2 names three ways to approach
  # working sets and says the coach must state which: find a new max, hold a percentage, or add
  # load each set. The goal is read from the prescription and stays blank when it can't be.
  # Rest and the working-set floor follow the L2; an N-rep max's expected result as a % of 1RM
  # uses the Epley estimate (an app heuristic from strength literature, not CrossFit).
  module HeavyDay
    FIND_MAX = /build to|find|heaviest|\bmax\b/i
    PERCENT = /(\d{2,3})\s*%/

    module_function

    def call(workout, reference)
      goal = goal(workout)
      return {} unless goal

      rest_low, rest_high = reference.constant(:heavy_rest_seconds)
      { stimulus_rest_seconds_low: rest_low, stimulus_rest_seconds_high: rest_high }
        .merge(working_sets(workout))
        .merge(percent_values(workout, goal, reference))
    end

    def goal(workout)
      return 'heavy_find_max' if text(workout).match?(FIND_MAX) || workout.exercises.any?(&:max_load_prescription?)
      return 'heavy_hold_percent' if stated_percent(workout)

      'heavy_ascending' if sets_in(workout).to_i > 1
    end

    def percent_values(workout, goal, reference)
      return hold(stated_percent(workout)) if goal == 'heavy_hold_percent'

      low, high = rep_max_range(reps_in_set(workout))
      { stimulus_percent_1rm_low: reference.constant(:heavy_working_percent_low),
        stimulus_range_low: low, stimulus_range_high: high }
    end

    def hold(percent)
      { stimulus_percent_1rm_low: percent, stimulus_percent_1rm_high: percent,
        stimulus_range_low: percent, stimulus_range_high: percent }
    end

    # Epley: an N-rep max is about 100 / (1 + N/30) % of 1RM; a single is 100%.
    def rep_max_range(reps)
      return [nil, nil] unless reps.to_i.positive?

      center = reps == 1 ? 100 : (100 / (1 + (reps / 30.0))).round
      low = center - 2
      [low, [low + 4, 100].min]
    end

    def working_sets(workout)
      sets = sets_in(workout)
      sets ? { stimulus_working_sets_low: sets, stimulus_working_sets_high: sets } : {}
    end

    def sets_in(workout)
      segment = workout.governing_segment
      return unless segment

      segment.interval? ? segment.interval_scheme.split('-').size : segment.rounds
    end

    def reps_in_set(workout)
      exercise = workout.exercises.first
      exercise && Volume.reps_per_set(exercise)
    end

    def stated_percent(workout)
      percent = text(workout)[PERCENT, 1]&.to_i
      percent if percent&.between?(1, 100)
    end

    def text(workout)
      [workout.name, workout.notes.to_plain_text, *workout.segments.flat_map { |s| [s.name, s.notes] },
       *workout.exercises.map(&:notes)].compact.join(' ')
    end
  end
end
