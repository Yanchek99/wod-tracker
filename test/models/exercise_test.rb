require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test 'requires distance units per rep to divide prescribed distance evenly' do
    exercise = exercises(:amrap_mixed_row)

    exercise.distance_units_per_rep = 40

    assert_not exercise.valid?
    assert_includes exercise.errors[:distance_units_per_rep], 'must divide the prescribed distance evenly'
  end

  test 'requires a distance metric when distance units per rep is configured' do
    exercise = exercises(:amrap_couplet_pullup)

    exercise.distance_units_per_rep = 10

    assert_not exercise.valid?
    assert_includes exercise.errors[:distance_units_per_rep], 'requires a distance metric'
  end
end
