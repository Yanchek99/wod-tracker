require 'test_helper'
require_relative '../support/athlete_capability_rows'

class AthleteCapabilityValidationsTest < ActiveSupport::TestCase
  include AthleteCapabilityRows

  NON_POSITIVE = [0, -5].freeze

  test 'every fixture is valid' do
    AthleteCapability.find_each { |row| assert_predicate row, :valid?, "#{row.kind}: #{row.errors.full_messages}" }
  end

  test 'max_effort is valid with a load alone or a distance alone' do
    assert_predicate build_row(kind: :max_effort, load: 185), :valid?
    assert_predicate build_row(kind: :max_effort, distance: 30, distance_unit: :inch), :valid?
  end

  test 'max_effort is invalid with both load and distance, with neither, or with reps or duration' do
    assert_not_predicate build_row(kind: :max_effort, load: 185, distance: 30, distance_unit: :inch), :valid?
    assert_not_predicate build_row(kind: :max_effort), :valid?
    assert_not_predicate build_row(kind: :max_effort, load: 185, reps: 1), :valid?
    assert_not_predicate build_row(kind: :max_effort, load: 185, duration_seconds: 10), :valid?
  end

  test 'unbroken is valid with reps alone, at a load, or at a height' do
    assert_predicate build_row(kind: :unbroken, reps: 15), :valid?
    assert_predicate build_row(kind: :unbroken, reps: 10, load: 95), :valid?
    assert_predicate build_row(kind: :unbroken, reps: 12, distance: 24, distance_unit: :inch), :valid?
  end

  test 'unbroken is invalid without reps or with a duration' do
    assert_not_predicate build_row(kind: :unbroken, load: 95), :valid?
    assert_not_predicate build_row(kind: :unbroken, reps: 10, duration_seconds: 60), :valid?
  end

  test 'timed is valid for a distance, for reps, and for reps at a height' do
    assert_predicate build_row(kind: :timed, distance: 1609, distance_unit: :meter, duration_seconds: 302), :valid?
    assert_predicate build_row(kind: :timed, reps: 30, duration_seconds: 60), :valid?
    assert_predicate build_row(kind: :timed, reps: 50, distance: 24, distance_unit: :inch, duration_seconds: 130),
                     :valid?
  end

  test 'timed is invalid without a duration or without reps and distance' do
    assert_not_predicate build_row(kind: :timed, distance: 1609, distance_unit: :meter), :valid?
    assert_not_predicate build_row(kind: :timed, duration_seconds: 302), :valid?
  end

  test 'cannot_do is valid with no measurements and invalid with any measurement' do
    assert_predicate build_row(kind: :cannot_do), :valid?
    assert_not_predicate build_row(kind: :cannot_do, load: 95), :valid?
    assert_not_predicate build_row(kind: :cannot_do, reps: 1), :valid?
    assert_not_predicate build_row(kind: :cannot_do, distance: 400, distance_unit: :meter), :valid?
    assert_not_predicate build_row(kind: :cannot_do, duration_seconds: 60), :valid?
  end

  test 'changing a saved max_effort to cannot_do without clearing its load is invalid' do
    row = athlete_capabilities(:brooke_back_squat_max_effort)
    row.kind = :cannot_do

    assert_not_predicate row, :valid?
  end

  test 'distance and distance_unit must be given together' do
    assert_not_predicate build_row(kind: :timed, reps: 30, duration_seconds: 60, distance: 24), :valid?
    assert_not_predicate build_row(kind: :timed, reps: 30, duration_seconds: 60, distance_unit: :inch), :valid?
  end

  test 'measurements must be positive integers' do
    %i[load reps distance duration_seconds].each do |column|
      NON_POSITIVE.each do |value|
        row = build_row(kind: :timed, reps: 30, duration_seconds: 60)
        row[column] = value
        row.distance_unit = :meter if column == :distance

        assert_not_predicate row, :valid?, "#{column} #{value} should be invalid"
      end
    end
    assert_not_predicate build_row(kind: :unbroken, reps: 1.5), :valid?
  end

  test 'confidence must be within 0..1 when present' do
    assert_not_predicate build_row(kind: :cannot_do, confidence: 1.5), :valid?
    assert_not_predicate build_row(kind: :cannot_do, confidence: -0.1), :valid?
    assert_predicate build_row(kind: :cannot_do, confidence: 0.5), :valid?
    assert_predicate build_row(kind: :cannot_do, confidence: nil), :valid?
  end

  test 'requires model_version and computed_at, and a non-negative sample_count' do
    assert_not_predicate build_row(kind: :cannot_do, model_version: ''), :valid?
    assert_not_predicate build_row(kind: :cannot_do, computed_at: nil), :valid?
    assert_not_predicate build_row(kind: :cannot_do, sample_count: -1), :valid?
  end
end
