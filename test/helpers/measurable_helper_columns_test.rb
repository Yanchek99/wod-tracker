require 'test_helper'

# measurable_message rendered from the direct prescription columns (the #1651 read path).
# The metric-backed equivalents live in measurable_helper_test.rb and exercise the fallback.
class MeasurableHelperColumnsTest < ActionView::TestCase
  include MeasurableHelper
  include MetricsHelper

  test 'renders a sex-specific box jump from columns with the length parenthesized' do
    box_jump = Movement.create!(name: 'Box Jump')
    exercise = workouts(:fran).exercises.build(movement: box_jump, position: 3,
                                               reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)

    assert_equal '30 Box Jumps (♀20-inch / ♂24-inch)', measurable_message(exercise)
  end

  test 'groups load and target height from columns by sex' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    exercise = workouts(:fran).exercises.build(movement: wall_ball, position: 3,
                                               reps: 0, duration_seconds: 60,
                                               female_load: 14, male_load: 20, load_unit: :lb,
                                               female_distance: 9, male_distance: 10, distance_unit: :foot)

    assert_equal '1:00 Wall-ball Shots (♀14lb + 9ft / ♂20lb + 10ft)', measurable_message(exercise)
  end

  test 'renders a leading distance from columns before the movement' do
    exercise = workouts(:fran).exercises.build(movement: movements(:run), position: 3,
                                               reps: 1, distance: 1600, distance_unit: :meter)

    assert_equal '1600 meter Run', measurable_message(exercise)
  end

  test 'renders the max-reps sentinel from columns' do
    toes_to_bar = Movement.create!(name: 'Toes to Bar')
    exercise = workouts(:fran).exercises.build(movement: toes_to_bar, position: 3, reps: 0)

    assert_equal 'max reps Toes to Bar', measurable_message(exercise)
  end

  test 'prefers direct columns over legacy metrics when both are present' do
    exercise = exercises(:fran_pullup) # carries a rep metric in fixtures
    exercise.assign_attributes(reps: 5)

    assert_equal '5 Pull Ups', measurable_message(exercise)
  end
end
