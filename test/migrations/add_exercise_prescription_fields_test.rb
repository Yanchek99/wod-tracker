require 'test_helper'
require Rails.root.join('db/migrate/20260612130000_add_exercise_prescription_fields').to_s

# Unit-tests the backfill mapping in isolation. The mapper reads raw integer measurements
# (like the migration's MigrationMetric), so we feed it lightweight stubs rather than real
# Metric records.
class AddExercisePrescriptionFieldsTest < ActiveSupport::TestCase
  M = AddExercisePrescriptionFields
  Stub = Struct.new(:measurement, :value, :female_value, :male_value)

  # Applies one metric and returns [attrs, status, reason]. Pass `into:` to accumulate across
  # metrics on a single exercise (for duplicate-dimension checks).
  def apply(measurement, value: nil, female_value: nil, male_value: nil, into: nil)
    ctx = into || { attrs: {}, filled: [] }
    stub = Stub.new(measurement, value, female_value, male_value)
    status, reason = M.new.send(:apply_metric, stub, ctx[:attrs], ctx[:filled])
    [ctx[:attrs], status, reason]
  end

  test 'reps: value kept, blank becomes 0 (max), sex-specific left unmapped' do
    assert_equal({ reps: 21 }, apply(M::REP, value: 21).first)
    assert_equal({ reps: 0 }, apply(M::REP).first)
    attrs, status, reason = apply(M::REP, female_value: 5, male_value: 7)
    assert_empty attrs
    assert_equal :unmapped, status
    assert_match(/sex-specific reps/, reason)
  end

  test 'seconds and time map to duration_seconds' do
    assert_equal({ duration_seconds: 60 }, apply(M::SECONDS, value: 60).first)
    assert_equal({ duration_seconds: 90 }, apply(M::TIME, value: 90).first)
  end

  test 'load: lb/kg units, sex loads, and blank marker' do
    assert_equal({ load_unit: M::LOAD_UNITS[:lb], load: 95 }, apply(M::LB, value: 95).first)
    assert_equal({ load_unit: M::LOAD_UNITS[:kg], load: 60 }, apply(M::KG, value: 60).first)
    assert_equal({ load_unit: M::LOAD_UNITS[:lb], female_load: 65, male_load: 95 },
                 apply(M::LB, female_value: 65, male_value: 95).first)
    assert_equal({ load_unit: M::LOAD_UNITS[:lb] }, apply(M::LB).first) # blank "record a load" marker
  end

  test 'weight assumes lb, notes, and never stores a zero load' do
    attrs, status, reason = apply(M::WEIGHT, value: 0)
    assert_equal({ load_unit: M::LOAD_UNITS[:lb] }, attrs)
    assert_equal :note, status
    assert_match(/implicit unit assumed lb/, reason)
    assert_equal({ load_unit: M::LOAD_UNITS[:lb], load: 3 }, apply(M::WEIGHT, value: 3).first)
  end

  test 'length: meter/foot/inch units, generic distance, and unitless height note' do
    assert_equal({ distance_unit: M::DISTANCE_UNITS[:meter], distance: 400 }, apply(M::METER, value: 400).first)
    assert_equal({ distance_unit: M::DISTANCE_UNITS[:foot], female_distance: 9, male_distance: 10 },
                 apply(M::FOOT, female_value: 9, male_value: 10).first)
    assert_equal({ distance_unit: M::DISTANCE_UNITS[:inch], distance: 20 }, apply(M::INCH, value: 20).first)
    assert_equal({ distance: 1600 }, apply(M::DISTANCE, value: 1600).first)
    _, status, = apply(M::HEIGHT, value: 24)
    assert_equal :note, status
  end

  test 'calories: value, blank becomes 0 (max), and sex calories' do
    assert_equal({ calories: 20 }, apply(M::CALORIE, value: 20).first)
    assert_equal({ calories: 0 }, apply(M::CALORIE).first)
    assert_equal({ female_calories: 20, male_calories: 30 }, apply(M::CALORIE, female_value: 20, male_value: 30).first)
  end

  test 'a second metric in a filled dimension is unmapped' do
    ctx = { attrs: {}, filled: [] }
    apply(M::LB, value: 95, into: ctx)
    _, status, reason = apply(M::KG, value: 60, into: ctx)
    assert_equal :unmapped, status
    assert_match(/duplicate load/, reason)
  end

  test 'an unexpected measurement (round) on an exercise is unmapped' do
    _, status, = apply(M::ROUND, value: 5)
    assert_equal :unmapped, status
  end

  # Completeness guard: every Metric measurement an exercise could carry must be handled by the
  # backfill (mapped or noted), except the explicitly structural ones. A new measurement that is
  # not handled fails this test, forcing a deliberate decision.
  EXERCISE_UNSUPPORTED_MEASUREMENTS = %w[round].freeze # structural; live on workout/segment

  test 'every Metric measurement is handled by the backfill or explicitly excluded' do
    Metric.measurements.each do |name, int|
      next if EXERCISE_UNSUPPORTED_MEASUREMENTS.include?(name)

      _, status, reason = apply(int, value: 1)
      assert_not_equal :unmapped, status, "Metric measurement #{name} (#{int}) is not handled: #{reason}"
    end
  end
end
