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

  # 20-minute AMRAP: 8 toes-to-bars, 10 dumbbell hang clean and jerks (50/35), 14/12-calorie row --
  # 32 score reps a round. CrossFit's posted text: 2018 average about 9 rounds (~288 reps), top
  # scores 487 (men) / 452 (women).
  test 'Open 18.1 gets an expected total-reps range in line with CrossFit' do
    toes_to_bar = Movement.find_or_create_by!(name: 'Toes to Bar') { |movement| movement.family = :gymnastics }
    dumbbell = Movement.find_or_create_by!(name: 'Dumbbell Hang Clean and Jerk') { |movement| movement.family = :weightlifting }
    workout = build_workout('Open 18.1 Real', score_type: :rep, time_seconds: 1200,
                                              movements: [{ movement: toes_to_bar, reps: 8 },
                                                          { movement: dumbbell, reps: 10, male_load: 50, female_load: 35,
                                                            load_unit: :lb },
                                                          { movement: movements(:row), reps: 1, male_calories: 14,
                                                            female_calories: 12 }])

    low, high = StimulusCalculator.workout(workout).values_at(:stimulus_range_low, :stimulus_range_high)

    assert_operator low, :positive?
    assert_operator high, :>=, 250
    assert_operator high, :<=, 500
  end
end
