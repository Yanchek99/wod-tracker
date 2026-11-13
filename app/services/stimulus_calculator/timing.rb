module StimulusCalculator
  # Programming Basics pt 1: each movement's time, summed for a round, times the rounds, plus
  # transitions. The fast time is that sum; the range runs to slow_factor x fast (Rochet,
  # "Hitting the Stimulus"). An AMRAP's expected rounds are its time cap over the round time.
  # Every movement must have a pace -- a partial sum would understate the time -- and team
  # workouts get no range (their volume is shared).
  module Timing
    module_function

    def call(workout, reference)
      # A team splits the volume; an ascending ladder's reps grow every round.
      return {} if workout.team? || workout.ascending_ladder?

      workout.amrap? ? amrap(workout, reference) : for_time(workout, reference)
    end

    def for_time(workout, reference)
      total = workout.segments.sum { |segment| segment_seconds(segment, reference) || (return {}) }
      return {} unless total.positive?

      slow = reference.constant(:slow_factor)
      result = { stimulus_range_low: total.round, stimulus_range_high: (total * slow).round }
      rounds = rounds_of(workout.governing_segment)
      result.merge!(round_seconds(total / rounds, slow)) if workout.segments.one? && rounds > 1
      result
    end

    def amrap(workout, reference)
      segment = workout.governing_segment
      round = segment_seconds(segment, reference)
      return {} unless round&.positive? && segment.time_seconds

      slow = reference.constant(:slow_factor)
      low, high = expected_rounds(segment.time_seconds, round, slow)
      if workout.score_rep?
        reps = reps_per_round(segment)
        return round_seconds(round, slow) unless reps.positive?

        low, high = [low, high].map { |count| count * reps }
      end
      { stimulus_range_low: low, stimulus_range_high: high }.merge(round_seconds(round, slow))
    end

    # Whole rounds between the slow and the fast pace; at least one.
    def expected_rounds(cap, round, slow)
      [[(cap / (round * slow)).floor, 1].max, (cap / round).ceil]
    end

    # The segment's fast time across its rounds (one round for an AMRAP), with a transition
    # between consecutive movements; nil when any movement has no pace.
    def segment_seconds(segment, reference)
      exercises = segment.exercises.to_a
      return if exercises.empty?

      work = exercises.sum do |exercise|
        Pace.seconds(exercise, Volume.for(exercise), Loading.call(exercise, reference), reference) || (return nil)
      end
      work + (transitions(segment, exercises) * reference.constant(:transition_seconds))
    end

    # Between consecutive movements (rest rows don't count); an AMRAP round also turns over.
    def transitions(segment, exercises)
      movements = exercises.count { |exercise| !exercise.movement.family_rest? }
      [(movements * rounds_of(segment)) - (segment.amrap? ? 0 : 1), 0].max
    end

    def rounds_of(segment)
      return 1 unless segment
      return segment.interval_scheme.split('-').size if segment.interval?

      segment.rounds || 1
    end

    def reps_per_round(segment)
      segment.exercises.sum { |exercise| exercise.reps.to_i }
    end

    def round_seconds(seconds, slow)
      { stimulus_round_seconds_low: seconds.round, stimulus_round_seconds_high: (seconds * slow).round }
    end
  end
end
