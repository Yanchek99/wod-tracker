require 'test_helper'

class MeasurableHelperTest < ActionView::TestCase
  include MetricsHelper

  test 'does not render blank load metrics in workout prescriptions' do
    assert_equal '5 Back Squats', measurable_message(exercises(:back_squat_5x5_back_squat))
  end

  test 'renders sex-specific additional exercise metrics' do
    exercise = exercises(:fran_pullup)
    exercise.metrics.create!(measurement: :lb, female_value: 65, male_value: 95)

    assert_equal 'Pull Up (♀65lb / ♂95lb)', measurable_message(exercise)
  end

  test 'groups multiple sex-specific additional exercise metrics by sex' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    exercise = workouts(:fran).exercises.create!(movement: wall_ball, position: 3)
    exercise.metrics.create!(measurement: :lb, female_value: 14, male_value: 20)
    exercise.metrics.create!(measurement: :foot, female_value: 9, male_value: 10)

    assert_equal 'Wall-ball Shot (♀14lb + 9ft / ♂20lb + 10ft)', measurable_message(exercise)
  end

  test 'renders timed max-rep station movements with duration prefix' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    exercise = workouts(:fran).exercises.create!(movement: wall_ball, position: 3)
    exercise.metrics.create!(measurement: :rep)
    exercise.metrics.create!(measurement: :seconds, value: 60)
    exercise.metrics.create!(measurement: :lb, female_value: 14, male_value: 20)
    exercise.metrics.create!(measurement: :foot, female_value: 9, male_value: 10)

    assert_equal '1:00 Wall-ball Shots (♀14lb + 9ft / ♂20lb + 10ft)', measurable_message(exercise)
  end

  test 'renders timed station movements without pluralizing fixed single-rep movements' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:row), position: 3)
    exercise.metrics.create!(measurement: :rep, value: 1)
    exercise.metrics.create!(measurement: :seconds, value: 60)
    exercise.metrics.create!(measurement: :calorie)

    assert_equal '1:00 Row', measurable_message(exercise)
  end

  test 'renders distance-only exercise prescriptions before the movement' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3)
    exercise.metrics.create!(measurement: :meter, value: 1600)

    assert_equal '1600 meter Run', measurable_message(exercise)
  end

  test 'renders distance prescriptions with structural single rep before the movement' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3)
    exercise.metrics.create!(measurement: :rep, value: 1)
    exercise.metrics.create!(measurement: :meter, value: 1600)

    assert_equal '1600 meter Run', measurable_message(exercise)
  end

  test 'renders calorie-only exercise prescriptions before the movement' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:row), position: 3)
    exercise.metrics.create!(measurement: :calorie, value: 20)

    assert_equal '20 calorie Row', measurable_message(exercise)
  end

  test 'renders sex-specific leading work metrics in compact male female order' do
    row = workouts(:fran).exercises.create!(movement: movements(:row), position: 3)
    row.metrics.create!(measurement: :calorie, female_value: 18, male_value: 20)

    assert_equal '20/18 calorie Row', measurable_message(row)

    row_distance = workouts(:fran).exercises.create!(movement: movements(:row), position: 4)
    row_distance.metrics.create!(measurement: :meter, female_value: 450, male_value: 500)

    assert_equal '500/450 meter Row', measurable_message(row_distance)
  end

  test 'keeps distance in additional metrics when another exercise metric is present' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3)
    exercise.metrics.create!(measurement: :meter, value: 400)
    exercise.metrics.create!(measurement: :lb, value: 20)

    assert_equal 'Run (400 meters / 20 lbs)', measurable_message(exercise)
  end

  test 'keeps movement log distances as additional metric text' do
    movement_log = logs(:matt_amrap).movement_logs.create!(movement: movements(:row))
    movement_log.metrics.create!(measurement: :meter, value: 300)

    assert_equal 'Row (300 meters)', measurable_message(movement_log)
  end
end
