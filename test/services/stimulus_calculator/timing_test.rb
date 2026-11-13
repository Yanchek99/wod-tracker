require 'test_helper'
require_relative '../../support/stimulus_test_reference'

module StimulusCalculator
  class TimingTest < ActiveSupport::TestCase
    include StimulusTestReference

    # Fran: 45 light thrusters x 2.0 s + 45 pull-ups x 1.5 s + 5 transitions x 10 s = 207.5 s.
    test 'Fran expected range runs from the fast time to twice it' do
      result = StimulusCalculator.workout(fran, test_reference)

      assert_equal [208, 415], result.values_at(:stimulus_range_low, :stimulus_range_high)
      assert_equal [69, 138], result.values_at(:stimulus_round_seconds_low, :stimulus_round_seconds_high)
      assert_equal 'for_time', result[:stimulus_goal]
    end

    test 'a movement missing from the table blanks the time but keeps covered loading' do
      workout = build_workout('Partial', rounds: 3, movements: [{ movement: movements(:thruster), reps: 15, load: 95 },
                                                                { movement: movements(:burpee), reps: 15 }])

      result = StimulusCalculator.workout(workout, test_reference)

      assert_nil result[:stimulus_range_high]
      assert_equal 'light', StimulusCalculator.exercise(workout.exercises.first, test_reference)[:stimulus_loading]
    end

    # One round: 200 m x 0.25 = 50 s + 10 light thrusters x 2.0 = 20 s + 2 transitions = 90 s; 600 / 90 = 6.7.
    test 'a rounds-scored AMRAP predicts rounds from the time cap' do
      workout = build_workout('AMRAP Calc', score_type: :round, time_seconds: 600,
                                            movements: [{ movement: movements(:run), distance: 200, distance_unit: :meter },
                                                        { movement: movements(:thruster), reps: 10, load: 95 }])

      result = StimulusCalculator.workout(workout, test_reference)

      assert_equal [3, 7], result.values_at(:stimulus_range_low, :stimulus_range_high)
      assert_equal [90, 180], result.values_at(:stimulus_round_seconds_low, :stimulus_round_seconds_high)
      assert_equal 'amrap', result[:stimulus_goal]
    end

    # One round: 1000 m x 0.25 = 250 s + 1 transition = 260 s in a 300 s cap: 0.58..1.15 rounds.
    test 'an AMRAP with long rounds never predicts zero rounds' do
      workout = build_workout('Long AMRAP', score_type: :round, time_seconds: 300,
                                            movements: [{ movement: movements(:run), distance: 1000, distance_unit: :meter }])

      assert_equal [1, 2], StimulusCalculator.workout(workout, test_reference).values_at(:stimulus_range_low,
                                                                                         :stimulus_range_high)
    end

    # One round: 10 light thrusters x 2.0 s = 20 s + 1 transition = 30 s; 600 s cap -> 10..20 rounds
    # of 10 reps.
    test 'a rep-scored AMRAP predicts total reps' do
      workout = build_workout('Rep AMRAP', score_type: :rep, time_seconds: 600,
                                           movements: [{ movement: movements(:thruster), reps: 10, load: 95 }])

      assert_equal [100, 200], StimulusCalculator.workout(workout, test_reference).values_at(:stimulus_range_low,
                                                                                             :stimulus_range_high)
    end

    test 'a rep-scored AMRAP with no counted reps gets no range' do
      workout = build_workout('Run AMRAP', score_type: :rep, time_seconds: 720,
                                           movements: [{ movement: movements(:run), distance: 400, distance_unit: :meter }])

      assert_nil StimulusCalculator.workout(workout, test_reference)[:stimulus_range_low]
    end

    # The scraper stores reps: 1 on distance lines. 3 x (400 m x 0.25 + 15 light thrusters x 2.0)
    # = 390 s + 5 transitions = 440 s.
    test 'a reps: 1 placeholder on a distance line does not blank the time' do
      workout = build_workout('Scraped Run', rounds: 3,
                                             movements: [{ movement: movements(:run), reps: 1, distance: 400, distance_unit: :meter },
                                                         { movement: movements(:thruster), reps: 15, load: 95 }])

      assert_equal [440, 880], StimulusCalculator.workout(workout, test_reference).values_at(:stimulus_range_low,
                                                                                             :stimulus_range_high)
    end

    # 21-15-9 calorie row stored as calories: 1 (the scheme supplies the calories): 45 x 3.0 = 135 s
    # + 45 light thrusters x 2.0 = 90 s + 5 transitions = 275 s.
    test 'an interval scheme supplies the calories of a calories: 1 placeholder' do
      workout = build_workout('Cal Row Fran', interval_scheme: '21-15-9',
                                              movements: [{ movement: movements(:row), calories: 1 },
                                                          { movement: movements(:thruster), reps: 1, load: 95 }])

      assert_equal 275, StimulusCalculator.workout(workout, test_reference)[:stimulus_range_low]
    end

    test 'an ascending ladder gets no time or rounds' do
      workout = build_workout('Ladder', score_type: :rep, time_seconds: 600,
                                        movements: [{ movement: movements(:thruster), reps: 3, load: 95 }])
      workout.update!(ladder_step: 3)

      assert_nil StimulusCalculator.workout(workout, test_reference)[:stimulus_range_high]
    end

    # 2 rounds of 400 m run (100 s) then 60 s rest: 200 + 120 s, plus one transition between the
    # two runs -- rest rows don't count as movements to transition between.
    test 'rest adds its time but no transitions or stimulus of its own' do
      rest = Movement.create!(name: 'Rest', family: :rest)
      workout = build_workout('Run Rest', rounds: 2,
                                          movements: [{ movement: movements(:run), distance: 400, distance_unit: :meter },
                                                      { movement: rest, duration_seconds: 60 }])

      assert_equal 330, StimulusCalculator.workout(workout, test_reference)[:stimulus_range_low]
      assert_equal({}, StimulusCalculator.exercise(workout.exercises.second, test_reference))
    end

    test 'a workout with no movements gets no range' do
      workout = build_workout('Empty', movements: [])

      assert_nil StimulusCalculator.workout(workout, test_reference)[:stimulus_range_high]
    end

    test 'a team workout gets no range' do
      workout = fran
      workout.update!(team_size: 2)

      assert_nil StimulusCalculator.workout(workout, test_reference)[:stimulus_range_high]
    end
  end
end
