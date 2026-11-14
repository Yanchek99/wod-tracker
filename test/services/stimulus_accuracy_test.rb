require 'test_helper'
require_relative '../support/stimulus_test_reference'

class StimulusAccuracyTest < ActiveSupport::TestCase
  include StimulusTestReference

  setup do
    fran # Fran Calc: calculated 208..415 s, thrusters light
    build_workout('Diane Calc', interval_scheme: '21-15-9',
                                movements: [{ movement: movements(:deadlift), reps: 1, load: 225 }])
  end

  test 'compares stated against calculated time, loading and sets' do
    claims = [claim('Fran Calc', 'finish_seconds' => [nil, 300], 'loading' => { 'Thruster' => 'light' },
                                 'sets_max' => { 'Thruster' => 2 }),
              claim('Diane Calc', 'finish_seconds' => [600, 900], 'loading' => { 'Deadlift' => 'heavy' },
                                  'sets_max' => { 'Deadlift' => 4 })]

    report = StimulusAccuracy.call(claims, test_reference)

    assert_equal 2, report.matched
    assert_equal({ overlap: 1, compared: 2 }, report.time.slice(:overlap, :compared))
    assert_equal 1, report.loading.dig('light', 'light')
    assert_equal 1, report.loading.dig('heavy', 'moderate')
    assert_equal({ exact: 1, within_one: 2, compared: 2 }, report.sets)
    assert_equal 'Diane Calc', report.worst.first[:workout]
  end

  test 'compares round time, target rounds and working-set percent' do
    build_workout('Squat Calc', score_type: :weight, rounds: 5,
                                movements: [{ movement: movements(:back_squat), reps: 5, notes: 'All sets at 75%' }])
    claims = [claim('Fran Calc', 'round_seconds' => [60, 120]),      # calculated 69..138 -> overlaps
              claim('Squat Calc', 'percent_1rm' => [70, nil])]       # calculated 75 -> within the stated window

    report = StimulusAccuracy.call(claims, test_reference)

    assert_equal({ overlap: 1, compared: 1 }, report.round.slice(:overlap, :compared))
    assert_equal({ overlap: 1, compared: 1 }, report.percent.slice(:overlap, :compared))
  end

  test 'compares a result window in the workout score unit' do
    claims = [claim('Fran Calc', 'result' => [200, 300])] # calculated 208..415 s -> overlaps

    report = StimulusAccuracy.call(claims, test_reference)

    assert_equal({ overlap: 1, compared: 1 }, report.result.slice(:overlap, :compared))
  end

  test 'summarizes the report in plain lines' do
    report = StimulusAccuracy.call([claim('Fran Calc', 'finish_seconds' => [nil, 300], 'loading' => { 'Thruster' => 'light' })],
                                   test_reference)

    lines = StimulusAccuracy.summary(report)

    assert_includes lines, '1 claimed workout(s) matched, 0 not in this database'
    assert_includes lines, 'Finish window overlaps CrossFit\'s: 1 of 1 (median gap 0 s)'
    assert_includes lines, 'Loading stated light: calculated light 1'
  end

  test 'a workout name that is not in this database is counted as unmatched' do
    report = StimulusAccuracy.call([claim('CF-999999', 'finish_seconds' => [nil, 300])], test_reference)

    assert_equal [0, 1], [report.matched, report.unmatched]
  end

  private

  def claim(name, claims)
    StimulusClaims::Claim.new(workout_name: name, claims:, source: 'test', reviewed: 'test')
  end
end
