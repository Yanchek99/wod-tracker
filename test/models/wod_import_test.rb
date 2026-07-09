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
end
