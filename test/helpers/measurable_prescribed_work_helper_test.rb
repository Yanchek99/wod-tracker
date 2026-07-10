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

class MeasurableLeadingPrescriptionTest < ActiveSupport::TestCase
  test 'selects fixed rep as leading prescription' do
    rep = Metric.new(measurement: :rep, value: 21)
    leading = Measurable::LeadingPrescription.new([rep])

    assert_same rep, leading.metric
    assert_equal '21', leading.text
    assert_empty leading.additional_metrics
  end

  test 'selects max rep as leading prescription' do
    rep = Metric.new(measurement: :rep)
    leading = Measurable::LeadingPrescription.new([rep])

    assert_same rep, leading.metric
    assert_equal 'max reps', leading.text
  end

  test 'selects fixed calories as leading prescription' do
    calorie = Metric.new(measurement: :calorie, value: 20)
    leading = Measurable::LeadingPrescription.new([calorie])

    assert_same calorie, leading.metric
    assert_equal '20 calorie', leading.text
  end

  test 'selects max calories as leading prescription' do
    calorie = Metric.new(measurement: :calorie)
    leading = Measurable::LeadingPrescription.new([calorie])

    assert_same calorie, leading.metric
    assert_equal 'max calories', leading.text
  end

  test 'selects distance with structural single rep and load detail' do
    rep = Metric.new(measurement: :rep, value: 1)
    distance = Metric.new(measurement: :foot, value: 80)
    load = Metric.new(measurement: :lb, female_value: 35, male_value: 50)
    leading = Measurable::LeadingPrescription.new([rep, load, distance])

    assert_same distance, leading.metric
    assert_equal '80ft', leading.text
    assert_equal [load], leading.additional_metrics
  end

  test 'does not select distance when fixed reps are visible work' do
    rep = Metric.new(measurement: :rep, value: 10)
    distance = Metric.new(measurement: :meter, value: 400)
    leading = Measurable::LeadingPrescription.new([rep, distance])

    assert_same rep, leading.metric
    assert_equal '10', leading.text
    assert_equal [distance], leading.additional_metrics
  end
end
