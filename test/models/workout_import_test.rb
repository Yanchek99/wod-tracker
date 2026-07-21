require 'test_helper'

class WorkoutImportTest < ActiveSupport::TestCase
  test 'requires a workout_date' do
    workout_import = WorkoutImport.new(status: :failed)

    assert_not workout_import.valid?
    assert_includes workout_import.errors[:workout_date], "can't be blank"
  end

  test 'requires a status' do
    workout_import = WorkoutImport.new(workout_date: Date.new(2026, 7, 9))

    assert_not workout_import.valid?
    assert_includes workout_import.errors[:status], "can't be blank"
  end

  test 'rejects a duplicate workout_date' do
    WorkoutImport.create!(workout_date: Date.new(2026, 7, 9), status: :failed)
    duplicate = WorkoutImport.new(workout_date: Date.new(2026, 7, 9), status: :partial)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:workout_date], 'has already been taken'
  end

  test 'accepts failed and partial as status values' do
    failed = WorkoutImport.new(workout_date: Date.new(2026, 7, 9), status: :failed)
    partial = WorkoutImport.new(workout_date: Date.new(2026, 7, 10), status: :partial)

    assert failed.valid?
    assert partial.valid?
  end

  test 'rejects an unrecognized status value' do
    assert_raises(ArgumentError) { WorkoutImport.new(status: :imported) }
  end

  test 'log_failure! creates a failed row with the given message and raw_text' do
    WorkoutImport.log_failure!(Date.new(2026, 7, 9), 'boom', raw_text: 'raw prose')

    workout_import = WorkoutImport.find_by!(workout_date: Date.new(2026, 7, 9))
    assert workout_import.failed?
    assert_equal 'boom', workout_import.error_message
    assert_equal 'raw prose', workout_import.raw_text
  end

  test 'log_failure! updates an existing row for the same date rather than creating a duplicate' do
    WorkoutImport.create!(workout_date: Date.new(2026, 7, 9), status: :failed, error_message: 'first failure')

    WorkoutImport.log_failure!(Date.new(2026, 7, 9), 'second failure')

    assert_equal 1, WorkoutImport.count
    assert_equal 'second failure', WorkoutImport.find_by!(workout_date: Date.new(2026, 7, 9)).error_message
  end

  test 'log_failure! retries once when it loses a race against a concurrent writer' do
    date = Date.new(2026, 7, 9)
    attempts = 0
    original = WorkoutImport.method(:find_or_initialize_by)
    WorkoutImport.define_singleton_method(:find_or_initialize_by) do |*args|
      attempts += 1
      raise ActiveRecord::RecordNotUnique, 'duplicate key value violates unique constraint' if attempts == 1

      original.call(*args)
    end

    begin
      WorkoutImport.log_failure!(date, 'boom')
    ensure
      WorkoutImport.define_singleton_method(:find_or_initialize_by, original)
    end

    assert_equal 1, WorkoutImport.where(workout_date: date).count
    assert_equal 'boom', WorkoutImport.find_by!(workout_date: date).error_message
  end

  test 'log_failure! gives up after exhausting its retries' do
    original = WorkoutImport.method(:find_or_initialize_by)
    WorkoutImport.define_singleton_method(:find_or_initialize_by) do |*_args|
      raise ActiveRecord::RecordNotUnique, 'duplicate key'
    end

    begin
      assert_raises(ActiveRecord::RecordNotUnique) { WorkoutImport.log_failure!(Date.new(2026, 7, 9), 'boom') }
    ensure
      WorkoutImport.define_singleton_method(:find_or_initialize_by, original)
    end
  end

  test 'clear! destroys the row for that date if present' do
    WorkoutImport.create!(workout_date: Date.new(2026, 7, 9), status: :failed)

    WorkoutImport.clear!(Date.new(2026, 7, 9))

    assert_equal 0, WorkoutImport.where(workout_date: Date.new(2026, 7, 9)).count
  end

  test 'clear! is a no-op when no row exists for that date' do
    assert_nothing_raised { WorkoutImport.clear!(Date.new(2026, 7, 9)) }
  end
end
