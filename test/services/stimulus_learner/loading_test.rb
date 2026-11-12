require 'test_helper'
require_relative '../../support/stimulus_examples'

module StimulusLearner
  class LoadingTest < ActiveSupport::TestCase
    include StimulusExamples

    test 'unloaded? is true for a bodyweight movement with no load' do
      assert Loading.unloaded?(exercises(:fran_pullup))
    end

    test 'unloaded? is false for a loaded barbell movement' do
      assert_not Loading.unloaded?(exercises(:fran_thruster))
    end

    test 'predicts loading from the loads CrossFit labeled for that movement' do
      label_clean_and_jerks(light: [95, 105], moderate: [135, 155], heavy: [225, 245])

      assert_equal({ stimulus_loading: 'moderate' }, predict(load: 135))
      assert_equal({ stimulus_loading: 'heavy' }, predict(load: 225))
      assert_equal({ stimulus_loading: 'light' }, predict(load: 75))
    end

    test 'returns nothing below the example threshold' do
      label_clean_and_jerks(light: [95, 105], moderate: [135, 155])

      assert_equal({}, predict(load: 135))
    end

    test 'does not extrapolate past the heaviest label when it is not heavy' do
      label_clean_and_jerks(light: [95, 105, 115], moderate: [135, 155])

      assert_equal({}, predict(load: 315))
    end

    test 'uses male_load when the load is sex-split' do
      label_clean_and_jerks(light: [95, 105], moderate: [135, 155], heavy: [225, 245])

      assert_equal({ stimulus_loading: 'heavy' }, predict(male_load: 225, female_load: 155))
    end

    test 'ignores examples for other movements' do
      label_clean_and_jerks(light: [95, 105], moderate: [135, 155], heavy: [225, 245])

      target = target_workout('Deadlift Target', movements: [{ movement: movements(:deadlift), reps: 5, load: 135 }])

      assert_equal({}, Loading.new(Examples.load).predict(target.exercises.first))
    end

    private

    def label_clean_and_jerks(by_label)
      by_label.each do |label, loads|
        loads.each do |load|
          labeled_workout("C&J #{label} #{load}",
                          movements: [{ movement: movements(:clean_and_jerk), reps: 10, load:,
                                        stimulus_loading: label }])
        end
      end
    end

    def predict(**load)
      target = target_workout('C&J Target', movements: [{ movement: movements(:clean_and_jerk), reps: 30, **load }])
      Loading.new(Examples.load).predict(target.exercises.first)
    end
  end
end
