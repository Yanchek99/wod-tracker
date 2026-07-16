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
    exercise = workouts(:fran).segments.first.exercises.create!(movement: thruster, position: 3, reps: 10,
                                                                load_unit: :lb, female_load: 35, male_load: 50,
                                                                implement_count: 2)

    assert_equal '10 Dumbbell Thrusters (2×♀35lb / ♂50lb)', measurable_message(exercise)
  end

  test 'renders 30 Box Jumps (♀20-inch / ♂24-inch)' do
    box_jump = Movement.create!(name: 'Box Jump')
    exercise = workouts(:fran).segments.first.exercises.create!(movement: box_jump, position: 3, reps: 30,
                                                                female_distance: 20, male_distance: 24, distance_unit: :inch)

    assert_equal '30 Box Jumps (♀20-inch / ♂24-inch)', measurable_message(exercise)
  end

  test 'groups multiple sex-specific additional exercise metrics by sex' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    exercise = workouts(:fran).segments.first.exercises.create!(movement: wall_ball, position: 3,
                                                                load_unit: :lb, female_load: 14, male_load: 20,
                                                                distance_unit: :foot, female_distance: 9, male_distance: 10)

    assert_equal 'Wall-ball Shot (♀14lb + 9ft / ♂20lb + 10ft)', measurable_message(exercise)
  end

  test 'renders timed max-rep station movements with duration prefix' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    exercise = workouts(:fran).segments.first.exercises.create!(movement: wall_ball, position: 3,
                                                                reps: 0, duration_seconds: 60,
                                                                load_unit: :lb, female_load: 14, male_load: 20,
                                                                distance_unit: :foot, female_distance: 9, male_distance: 10)

    assert_equal '1:00 Wall-ball Shots (♀14lb + 9ft / ♂20lb + 10ft)', measurable_message(exercise)
  end

  test 'renders untimed max-rep station movements with max reps prefix' do
    toes_to_bar = Movement.create!(name: 'Toes to Bar')
    exercise = workouts(:fran).segments.first.exercises.create!(movement: toes_to_bar, position: 3, reps: 0)

    assert_equal 'max reps Toes to Bar', measurable_message(exercise)
  end

  test 'renders untimed max-calorie station movements with max calories prefix' do
    row = Movement.find_or_create_by!(name: 'Row')
    exercise = workouts(:fran).segments.first.exercises.create!(movement: row, position: 3, calories: 0)

    assert_equal 'max calories Row', measurable_message(exercise)
  end

  test 'renders additional calories before load for exercises' do
    exercise = workouts(:fran).segments.first.exercises.create!(movement: movements(:row), position: 3,
                                                                reps: 10, calories: 20, load: 135, load_unit: :lb)

    assert_equal '10 Rows (20 calories / 135 lbs)', measurable_message(exercise)
  end

  test 'renders a max-load test from columns' do
    workout = Workout.create!(name: 'Back Squat Max', score_type: :weight)
    exercise = workout.segments.create!(position: 1).exercises.create!(movement: movements(:back_squat), position: 1,
                                                                       reps: 4, duration_seconds: 240, load_unit: :lb)

    assert_equal '4:00 to find a 4-rep max Back Squat', measurable_message(exercise)
  end

  test 'renders a literal single rep on a plain for-time workout, unlike a ladder placeholder' do
    exercise = workouts(:murph).segments.first.exercises.create!(movement: movements(:rope_climb), position: 6, reps: 1)

    assert_equal '1 Rope Climb', measurable_message(exercise)
  end

  test 'does not render a numeral for a Fran-style ladder placeholder rep' do
    assert_equal 'Pull Up', measurable_message(exercises(:fran_pullup))
  end

  test 'renders timed station movements without pluralizing fixed single-rep movements' do
    exercise = workouts(:fran).segments.first.exercises.create!(movement: movements(:row), position: 3,
                                                                reps: 1, duration_seconds: 60, calories: 0)

    assert_equal '1:00 Row', measurable_message(exercise)
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

  test 'renders additional distance before load for movement logs' do
    movement_log = logs(:matt_amrap).movement_logs.build(movement: movements(:row),
                                                         reps: 10, distance: 400,
                                                         distance_unit: :meter, load: 135,
                                                         load_unit: :lb)

    assert_equal '10 Rows (400 meters / 135 lbs)', measurable_message(movement_log)
  end
end
