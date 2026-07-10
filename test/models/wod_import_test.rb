require 'test_helper'

class WodImportTest < ActiveSupport::TestCase
  test 'requires a wod_date' do
    wod_import = WodImport.new(status: :failed)

    assert_not wod_import.valid?
    assert_includes wod_import.errors[:wod_date], "can't be blank"
  end

  test 'requires a status' do
    wod_import = WodImport.new(wod_date: Date.new(2026, 7, 9))

    assert_not wod_import.valid?
    assert_includes wod_import.errors[:status], "can't be blank"
  end

  test 'rejects a duplicate wod_date' do
    WodImport.create!(wod_date: Date.new(2026, 7, 9), status: :failed)
    duplicate = WodImport.new(wod_date: Date.new(2026, 7, 9), status: :partial)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:wod_date], 'has already been taken'
  end

  test 'accepts failed and partial as status values' do
    failed = WodImport.new(wod_date: Date.new(2026, 7, 9), status: :failed)
    partial = WodImport.new(wod_date: Date.new(2026, 7, 10), status: :partial)

    assert failed.valid?
    assert partial.valid?
  end

  test 'rejects an unrecognized status value' do
    assert_raises(ArgumentError) { WodImport.new(status: :imported) }
  end

  test 'log_failure! creates a failed row with the given message and raw_text' do
    WodImport.log_failure!(Date.new(2026, 7, 9), 'boom', raw_text: 'raw prose')

    wod_import = WodImport.find_by!(wod_date: Date.new(2026, 7, 9))
    assert wod_import.failed?
    assert_equal 'boom', wod_import.error_message
    assert_equal 'raw prose', wod_import.raw_text
  end

  test 'log_failure! updates an existing row for the same date rather than creating a duplicate' do
    WodImport.create!(wod_date: Date.new(2026, 7, 9), status: :failed, error_message: 'first failure')

    WodImport.log_failure!(Date.new(2026, 7, 9), 'second failure')

    assert_equal 1, WodImport.count
    assert_equal 'second failure', WodImport.find_by!(wod_date: Date.new(2026, 7, 9)).error_message
  end

  test 'log_failure! retries once when it loses a race against a concurrent writer' do
    date = Date.new(2026, 7, 9)
    attempts = 0
    original = WodImport.method(:find_or_initialize_by)
    WodImport.define_singleton_method(:find_or_initialize_by) do |*args|
      attempts += 1
      raise ActiveRecord::RecordNotUnique, 'duplicate key value violates unique constraint' if attempts == 1

      original.call(*args)
    end

    begin
      WodImport.log_failure!(date, 'boom')
    ensure
      WodImport.define_singleton_method(:find_or_initialize_by, original)
    end

    assert_equal 1, WodImport.where(wod_date: date).count
    assert_equal 'boom', WodImport.find_by!(wod_date: date).error_message
  end

  test 'log_failure! gives up after exhausting its retries' do
    original = WodImport.method(:find_or_initialize_by)
    WodImport.define_singleton_method(:find_or_initialize_by) do |*_args|
      raise ActiveRecord::RecordNotUnique, 'duplicate key'
    end

    begin
      assert_raises(ActiveRecord::RecordNotUnique) { WodImport.log_failure!(Date.new(2026, 7, 9), 'boom') }
    ensure
      WodImport.define_singleton_method(:find_or_initialize_by, original)
    end
  end

  test 'clear! destroys the row for that date if present' do
    WodImport.create!(wod_date: Date.new(2026, 7, 9), status: :failed)

    WodImport.clear!(Date.new(2026, 7, 9))

    assert_equal 0, WodImport.where(wod_date: Date.new(2026, 7, 9)).count
  end

  test 'clear! is a no-op when no row exists for that date' do
    assert_nothing_raised { WodImport.clear!(Date.new(2026, 7, 9)) }
  end
end
