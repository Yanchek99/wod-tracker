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
      assert_equal 'moderate', loading_for(:deadlift, reps: 21, male_load: 225, female_load: 155)
    end

    test 'at or above the heavy boundary is heavy' do
      assert_equal 'heavy', loading_for(:back_squat, reps: 3, load: 295)
    end

    test 'an unloaded bodyweight movement is unloaded' do
      assert_equal 'unloaded', loading_for(:pullup, reps: 10)
    end

    test 'a loaded movement missing from the table has no loading' do
      assert_nil loading_for(:front_squat, reps: 5, load: 185)
    end

    private

    def loading_for(movement, **attrs)
      workout = build_workout('Loading', movements: [{ movement: movements(movement), **attrs }])
      StimulusCalculator::Loading.call(workout.exercises.first, test_reference)
    end
  end
end
