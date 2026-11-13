module StimulusCalculator
  # A fixed-interval workout (an EMOM, or N rounds every M minutes): the work inside one
  # interval at fast pace, and the rest left before the next interval starts.
  module Interval
    module_function

    def call(workout, reference)
      segment = segment(workout)
      length = segment.time_seconds / segment.rounds
      work = segment.exercises.sum do |exercise|
        Pace.seconds(exercise, Volume.per_effort(exercise), Loading.call(exercise, reference), reference) || (return {})
      end.round
      rest = length - work
      { stimulus_interval_work_seconds: work, stimulus_interval_rest_seconds_min: (rest if rest.positive?) }
    end

    # The workout's governing segment when it runs on a fixed interval.
    def segment(workout)
      return if workout.ascending_ladder?

      segment = workout.governing_segment
      segment if segment&.timed_rounds? && (segment.time_seconds % segment.rounds).zero?
    end
  end
end
