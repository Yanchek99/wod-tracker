require 'test_helper'
require_relative '../../support/stimulus_test_reference'

module StimulusCalculator
  class LoadingTest < ActiveSupport::TestCase
    include StimulusTestReference

    test 'Grace clean and jerk at 135 is moderate' do
      assert_equal 'moderate', loading_for(:clean_and_jerk, reps: 30, male_load: 135, female_load: 95)
    end

    test 'Fran thruster at 95 is light' do
      assert_equal 'light', loading_for(:thruster, reps: 21, male_load: 95, female_load: 65)
    end

    test 'Diane deadlift at 225 is moderate' do
      assert_equal 'moderate', loading_for(barbell_deadlift, reps: 21, male_load: 225, female_load: 155)
    end

    test 'at or above the heavy boundary is heavy' do
      assert_equal 'heavy', loading_for(:back_squat, reps: 3, load: 295)
    end

    test 'an unloaded bodyweight movement is unloaded' do
      assert_equal 'unloaded', loading_for(:pullup, reps: 10)
    end

    test 'a loaded movement with no bucket has no loading' do
      assert_nil loading_for(:overhead_walking_lunge, reps: 5, load: 95)
    end

    test 'the typical kettlebell is light and a 70-lb one is moderate' do
      swing = Movement.create!(name: 'Calc Kettlebell Swing', family: :weightlifting, equipment: :kettlebell)

      assert_equal 'light', loading_for(swing, reps: 21, male_load: 53, female_load: 35)
      assert_equal 'moderate', loading_for(swing, reps: 21, male_load: 70, female_load: 53)
    end

    private

    def loading_for(movement, **attrs)
      movement = movements(movement) if movement.is_a?(Symbol)
      workout = build_workout('Loading', movements: [{ movement:, **attrs }])
      StimulusCalculator::Loading.call(workout.exercises.first, test_reference)
    end
  end
end
