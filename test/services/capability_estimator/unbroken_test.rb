require_relative 'helper'

class CapabilityEstimatorUnbrokenTest < ActiveSupport::TestCase
  include CapabilityEstimatorHelper

  setup do
    setup_estimator_user
    @pullup = movements(:pullup)
    @deadlift = movements(:deadlift)
    @fran = workouts(:fran)
  end

  def rows = CapabilityEstimator::Unbroken.call(samples)

  test 'uses the largest captured set, not the aggregated reps' do
    create_log(@fran, { movement: @deadlift, reps: 45, set_breakdown: [21, 15, 9] })

    assert_equal 21, rows.sole[:reps]
  end

  test 'a different load is a separate row with its own max' do
    create_log(@fran, { movement: @deadlift, reps: 10, load: 95, set_breakdown: [10] })
    create_log(@fran, { movement: @deadlift, reps: 5, load: 135, set_breakdown: [5] })

    by_load = rows.index_by { |row| row[:load] }
    assert_equal 10, by_load[95][:reps]
    assert_equal 5, by_load[135][:reps]
  end

  test 'a distance setting keys on distance and unit' do
    create_log(@fran, { movement: @deadlift, reps: 8, distance: 20, distance_unit: :meter, set_breakdown: [8] })

    row = rows.sole
    assert_equal [20, 'meter'], [row[:distance], row[:distance_unit].to_s]
  end

  test 'bodyweight rows have no load or distance and sample_count counts logs' do
    2.times { create_log(@fran, { movement: @pullup, reps: 1 }) }

    row = rows.sole
    assert_nil row[:load]
    assert_nil row[:distance]
    assert_equal 2, row[:sample_count]
  end

  test 'unbreakable movements, unverifiable reps and the reps 0 sentinel yield nothing' do
    @pullup.update!(breakable: false)
    create_log(@fran, { movement: @pullup, reps: 1 })
    create_log(@fran, { movement: @deadlift, reps: 21 })
    create_log(@fran, { movement: @deadlift, reps: 0 })

    assert_empty rows
  end

  test 'zero placeholders and unitless distances are dropped from the setting' do
    create_log(@fran, { movement: @deadlift, reps: 1, load: 0 })
    create_log(@fran, { movement: movements(:run), reps: 1, distance: 1600, distance_unit: nil })

    assert(rows.all? { |row| row[:load].nil? && row[:distance].nil? && row[:distance_unit].nil? })
    assert_equal 2, rows.size
  end
end
