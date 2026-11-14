require 'test_helper'
require_relative '../../support/stimulus_test_reference'

module StimulusCalculator
  class PaceTest < ActiveSupport::TestCase
    include StimulusTestReference

    setup do
      @box_jump = Movement.create!(name: 'Calc Box Jump', family: :gymnastics, equipment: :box, skill_level: :basic)
    end

    # 20 basic reps x 1.2 s = 24 s at the typical 24-in box.
    test 'a box at its typical height keeps the skill-level pace' do
      assert_in_delta 24, seconds(reps: 20, male_distance: 24, female_distance: 20, distance_unit: :inch)
    end

    test 'a box above its typical height makes each rep slower' do
      assert_in_delta 30, seconds(reps: 20, male_distance: 30, female_distance: 24, distance_unit: :inch)
    end

    test 'the height scale stays inside its bounds' do
      assert_in_delta 36, seconds(reps: 20, male_distance: 48, female_distance: 40, distance_unit: :inch)
    end

    test 'with no height the skill-level pace stands' do
      assert_in_delta 24, seconds(reps: 20)
    end

    private

    def seconds(**attrs)
      workout = build_workout('Box', movements: [{ movement: @box_jump, **attrs }])
      exercise = workout.exercises.first
      StimulusCalculator::Pace.seconds(exercise, StimulusCalculator::Volume.for(exercise), test_reference)
    end
  end
end
