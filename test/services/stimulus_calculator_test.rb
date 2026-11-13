require 'test_helper'
require_relative '../support/stimulus_test_reference'

# Benchmarks against the drafted production reference table (config/stimulus_reference.yml).
# Loose bounds on purpose: the table is owner-reviewed and will be tuned against CrossFit.
class StimulusCalculatorTest < ActiveSupport::TestCase
  include StimulusTestReference

  test 'Fran comes out light on the thrusters and finishes inside 3 to 8 minutes' do
    workout = build_workout('Fran Real', interval_scheme: '21-15-9',
                                         movements: [{ movement: movements(:thruster), reps: 1, male_load: 95,
                                                       female_load: 65, load_unit: :lb },
                                                     { movement: movements(:pull_up), reps: 1 }])

    result = StimulusCalculator.workout(workout)

    assert_operator result[:stimulus_range_low], :>=, 120
    assert_operator result[:stimulus_range_high], :<=, 480
    assert_equal 'light', StimulusCalculator.exercise(workout.exercises.first)[:stimulus_loading]
  end

  test 'Grace clean and jerks are moderate' do
    workout = build_workout('Grace Real', movements: [{ movement: movements(:clean_and_jerk), reps: 30, male_load: 135,
                                                        female_load: 95, load_unit: :lb }])

    assert_equal 'moderate', StimulusCalculator.exercise(workout.exercises.first)[:stimulus_loading]
  end

  test 'Diane deadlifts are moderate' do
    workout = build_workout('Diane Real', interval_scheme: '21-15-9',
                                          movements: [{ movement: movements(:deadlift), reps: 1, male_load: 225,
                                                        female_load: 155, load_unit: :lb },
                                                      { movement: movements(:handstand_push_up), reps: 1 }])

    assert_equal 'moderate', StimulusCalculator.exercise(workout.exercises.first)[:stimulus_loading]
    assert_operator StimulusCalculator.workout(workout)[:stimulus_range_high], :<=, 600
  end
end
