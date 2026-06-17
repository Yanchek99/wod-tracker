require 'test_helper'
require Rails.root.join('db/migrate/20260615120000_add_movement_log_performance_fields').to_s

# Unit-tests the backfill mapping in isolation. The mapper reads raw integer measurements, so we
# feed it lightweight stubs rather than real Metric records. Movement-log performance is
# value-only (no sex-specific variants).
class AddMovementLogPerformanceFieldsTest < ActiveSupport::TestCase
  M = AddMovementLogPerformanceFields
  Stub = Struct.new(:measurement, :value)

  # Applies one metric; returns [attrs, mapped?].
  def apply(measurement, value: nil, attrs: {}, filled: [])
    [attrs, M.new.send(:apply_metric, Stub.new(measurement, value), attrs, filled)]
  end

  test 'rep maps to reps' do
    attrs, mapped = apply(M::REP, value: 45)
    assert mapped
    assert_equal({ reps: 45 }, attrs)
  end

  test 'seconds and time map to duration_seconds' do
    assert_equal({ duration_seconds: 60 }, apply(M::SECONDS, value: 60).first)
    assert_equal({ duration_seconds: 90 }, apply(M::TIME, value: 90).first)
  end

  test 'lb and kg map to load with their unit' do
    assert_equal({ load_unit: M::LOAD_UNITS[:lb], load: 95 }, apply(M::LB, value: 95).first)
    assert_equal({ load_unit: M::LOAD_UNITS[:kg], load: 60 }, apply(M::KG, value: 60).first)
  end

  test 'weight assumes lb' do
    assert_equal({ load_unit: M::LOAD_UNITS[:lb], load: 100 }, apply(M::WEIGHT, value: 100).first)
  end

  test 'length measurements map to the single distance column' do
    assert_equal({ distance_unit: M::DISTANCE_UNITS[:meter], distance: 300 }, apply(M::METER, value: 300).first)
    assert_equal({ distance_unit: M::DISTANCE_UNITS[:foot], distance: 10 }, apply(M::FOOT, value: 10).first)
    assert_equal({ distance_unit: M::DISTANCE_UNITS[:inch], distance: 24 }, apply(M::INCH, value: 24).first)
    assert_equal({ distance: 1600 }, apply(M::DISTANCE, value: 1600).first) # generic, no unit
  end

  test 'calorie maps to calories' do
    assert_equal({ calories: 20 }, apply(M::CALORIE, value: 20).first)
  end

  test 'non-positive values set unit markers but not the numeric column' do
    assert_equal({ load_unit: M::LOAD_UNITS[:lb] }, apply(M::LB).first)
    assert_equal({ distance_unit: M::DISTANCE_UNITS[:meter] }, apply(M::METER).first)
  end

  test 'a second metric in a filled dimension is unmapped' do
    attrs = {}
    filled = []
    apply(M::LB, value: 95, attrs: attrs, filled: filled)
    _, mapped = apply(M::KG, value: 60, attrs: attrs, filled: filled)
    assert_not mapped
  end

  test 'an unexpected measurement is unmapped' do
    _, mapped = apply(M::ROUND, value: 5)
    assert_not mapped
  end
end
