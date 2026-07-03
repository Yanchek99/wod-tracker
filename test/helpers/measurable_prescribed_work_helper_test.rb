require 'test_helper'

class MeasurablePrescribedWorkHelperTest < ActionView::TestCase
  include MeasurableHelper
  include MetricsHelper

  test 'renders 1600 meter Run without reps' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3,
                                                 distance: 1600, distance_unit: :meter)

    assert_equal '1600 meter Run', measurable_message(exercise)
  end

  test 'renders 1600 meter Run with one structural rep' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3,
                                                 reps: 1, distance: 1600, distance_unit: :meter)

    assert_equal '1600 meter Run', measurable_message(exercise)
  end

  test 'renders 20 calorie Row' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:row), position: 3, calories: 20)

    assert_equal '20 calorie Row', measurable_message(exercise)
  end

  test 'renders 20/18 calorie Row' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:row), position: 3,
                                                 female_calories: 18, male_calories: 20)

    assert_equal '20/18 calorie Row', measurable_message(exercise)
  end

  test 'renders 500/450 meter Row' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:row), position: 3,
                                                 distance_unit: :meter, female_distance: 450, male_distance: 500)

    assert_equal '500/450 meter Row', measurable_message(exercise)
  end

  test 'renders 400 meter Run (20 lbs)' do
    exercise = workouts(:fran).exercises.create!(movement: movements(:run), position: 3,
                                                 distance: 400, distance_unit: :meter, load: 20, load_unit: :lb)

    assert_equal '400 meter Run (20 lbs)', measurable_message(exercise)
  end

  test 'renders 80ft Dumbbell Overhead Walking Lunge (♀35lb / ♂50lb)' do
    lunge = Movement.create!(name: 'Dumbbell Overhead Walking Lunge')
    exercise = workouts(:fran).exercises.create!(movement: lunge, position: 3,
                                                 reps: 1, distance: 80, distance_unit: :foot,
                                                 female_load: 35, male_load: 50, load_unit: :lb)

    assert_equal '80ft Dumbbell Overhead Walking Lunge (♀35lb / ♂50lb)', measurable_message(exercise)
  end

  test 'renders 40/30ft Dumbbell Overhead Walking Lunge (♀35lb / ♂50lb)' do
    lunge = Movement.create!(name: 'Dumbbell Overhead Walking Lunge')
    exercise = workouts(:fran).exercises.create!(movement: lunge, position: 3,
                                                 reps: 1, distance_unit: :foot,
                                                 female_distance: 30, male_distance: 40,
                                                 female_load: 35, male_load: 50, load_unit: :lb)

    assert_equal '40/30ft Dumbbell Overhead Walking Lunge (♀35lb / ♂50lb)', measurable_message(exercise)
  end
end
