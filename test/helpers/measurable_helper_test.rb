require 'test_helper'

class MeasurableHelperTest < ActionView::TestCase
  include MetricsHelper

  test 'does not render blank load metrics in workout prescriptions' do
    assert_equal '5 Back Squats', measurable_message(exercises(:back_squat_5x5_back_squat))
  end

  test 'renders sex-specific additional exercise metrics' do
    exercise = exercises(:fran_pullup)
    exercise.update!(load_unit: :lb, female_load: 65, male_load: 95)

    assert_equal 'Pull Up (♀65lb / ♂95lb)', measurable_message(exercise)
  end

  test 'renders multi-implement dumbbell load with a count prefix' do
    thruster = Movement.create!(name: 'Dumbbell Thruster')
    exercise = workouts(:fran).exercises.create!(movement: thruster, position: 3, reps: 10,
                                                 load_unit: :lb, female_load: 35, male_load: 50,
                                                 implement_count: 2)

    assert_equal '10 Dumbbell Thrusters (2×♀35lb / ♂50lb)', measurable_message(exercise)
  end

  test 'groups multiple sex-specific additional exercise metrics by sex' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    exercise = workouts(:fran).exercises.create!(movement: wall_ball, position: 3,
                                                 load_unit: :lb, female_load: 14, male_load: 20,
                                                 distance_unit: :foot, female_distance: 9, male_distance: 10)

    assert_equal 'Wall-ball Shot (♀14lb + 9ft / ♂20lb + 10ft)', measurable_message(exercise)
  end

  test 'renders timed max-rep station movements with duration prefix' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    exercise = workouts(:fran).exercises.create!(movement: wall_ball, position: 3,
                                                 reps: 0, duration_seconds: 60,
                                                 load_unit: :lb, female_load: 14, male_load: 20,
                                                 distance_unit: :foot, female_distance: 9, male_distance: 10)

    assert_equal '1:00 Wall-ball Shots (♀14lb + 9ft / ♂20lb + 10ft)', measurable_message(exercise)
  end

  test 'renders untimed max-rep station movements with max reps prefix' do
    toes_to_bar = Movement.create!(name: 'Toes to Bar')
    exercise = workouts(:fran).exercises.create!(movement: toes_to_bar, position: 3, reps: 0)

    assert_equal 'max reps Toes to Bar', measurable_message(exercise)
  end

  test 'renders timed station movements without pluralizing fixed single-rep movements' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:row), position: 3,
                                                 reps: 1, duration_seconds: 60, calories: 0)

    assert_equal '1:00 Row', measurable_message(exercise)
  end

  test 'renders distance-only exercise prescriptions before the movement' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3,
                                                 distance: 1600, distance_unit: :meter)

    assert_equal '1600 meter Run', measurable_message(exercise)
  end

  test 'renders distance prescriptions with structural single rep before the movement' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3,
                                                 reps: 1, distance: 1600, distance_unit: :meter)

    assert_equal '1600 meter Run', measurable_message(exercise)
  end

  test 'renders calorie-only exercise prescriptions before the movement' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:row), position: 3, calories: 20)

    assert_equal '20 calorie Row', measurable_message(exercise)
  end

  test 'renders sex-specific leading work metrics in compact male female order' do
    row = workouts(:fran).exercises.create!(movement: movements(:row), position: 3,
                                            female_calories: 18, male_calories: 20)

    assert_equal '20/18 calorie Row', measurable_message(row)

    row_distance = workouts(:fran).exercises.create!(movement: movements(:row), position: 4,
                                                     distance_unit: :meter, female_distance: 450, male_distance: 500)

    assert_equal '500/450 meter Row', measurable_message(row_distance)
  end

  test 'keeps distance in additional metrics when another exercise metric is present' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3,
                                                 distance: 400, distance_unit: :meter, load: 20, load_unit: :lb)

    assert_equal 'Run (400 meters / 20 lbs)', measurable_message(exercise)
  end

  test 'keeps movement log distances as additional metric text' do
    movement_log = logs(:matt_amrap).movement_logs.create!(movement: movements(:row),
                                                           distance: 300, distance_unit: :meter)

    assert_equal 'Row (300 meters)', measurable_message(movement_log)
  end

  test 'renders single-value target heights as ft after load' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    movement_log = logs(:matt_amrap).movement_logs.create!(movement: wall_ball,
                                                           reps: 30, load: 20, load_unit: :lb,
                                                           distance: 10, distance_unit: :foot)

    assert_equal '30 Wall-ball Shots (20 lbs / 10 ft)', measurable_message(movement_log)
  end

  test 'renders a movement log from its performance columns' do
    movement_log = logs(:matt_amrap).movement_logs.build(movement: movements(:row),
                                                         distance: 300, distance_unit: :meter)

    assert_equal 'Row (300 meters)', measurable_message(movement_log)
  end
end
