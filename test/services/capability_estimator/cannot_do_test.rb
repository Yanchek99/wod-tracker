require_relative 'helper'

class CapabilityEstimatorCannotDoTest < ActiveSupport::TestCase
  include CapabilityEstimatorHelper

  setup do
    setup_estimator_user
    @fran = workouts(:fran)
    @prescribed = @fran.exercises_for_log_recording.first.movement
    @substitute = movements(:row)
    MovementSubstitution.create!(movement: @prescribed, substitute_movement: @substitute, direction: :easier)
  end

  def rows = CapabilityEstimator::CannotDo.call(samples)

  # A Fran log with every exercise logged as prescribed, except the first replaced by `with`.
  def substituted_log(with: @substitute, created_at: Time.current)
    attrs = @fran.exercises_for_log_recording.map { |exercise| { movement: exercise.movement } }
    attrs.first[:movement] = with
    create_log(@fran, *attrs, created_at:)
  end

  def fill_to_minimum
    CapabilityEstimator::MIN_TOTAL_LOGS.times { create_log(workouts(:murph)) }
  end

  test 'fewer than the minimum number of logs overall writes nothing' do
    2.times { substituted_log }

    assert_empty rows
  end

  test 'a substitute logged in two logs marks the prescribed movement, one log does not' do
    fill_to_minimum
    substituted_log
    assert_empty rows

    substituted_log
    row = rows.sole
    assert_equal [@prescribed.id, :cannot_do, 2], [row[:movement_id], row[:kind], row[:sample_count]]
  end

  test 'the inverse harder row counts as an easier substitution' do
    MovementSubstitution.where(movement: @prescribed).delete_all
    MovementSubstitution.create!(movement: @substitute, substitute_movement: @prescribed, direction: :harder)
    fill_to_minimum
    2.times { substituted_log }

    assert_equal [@prescribed.id], rows.map { |row| row[:movement_id] }
  end

  test 'a later success on the prescribed movement clears it' do
    fill_to_minimum
    2.times { |i| substituted_log(created_at: (10 - i).days.ago) }
    create_log(@fran, { movement: @prescribed, reps: 1 }, created_at: 1.day.ago)

    assert_empty rows
  end

  test 'every log of a movement being singles when volume was prescribed marks it' do
    fill_to_minimum
    create_log(@fran, { movement: movements(:burpee), reps: 5, set_breakdown: [1, 1, 1, 1, 1] })

    assert_equal [movements(:burpee).id], rows.map { |row| row[:movement_id] }
  end

  test 'one log with a bigger set prevents the singles rule' do
    fill_to_minimum
    create_log(@fran, { movement: movements(:burpee), reps: 5, set_breakdown: [1, 1, 1, 1, 1] })
    create_log(@fran, { movement: movements(:burpee), reps: 5, set_breakdown: [3, 2] })

    assert_empty rows
  end

  test 'reps with no captured set_breakdown are unverifiable, not tiny' do
    fill_to_minimum
    create_log(@fran, { movement: movements(:pullup), reps: 21 })

    assert_empty rows
  end

  test 'a workout with no exercises is skipped without error' do
    fill_to_minimum
    empty = Workout.create!(name: 'Empty', score_type: :time)
    create_log(empty, { movement: @substitute, reps: 5 })

    assert_empty rows
  end
end
