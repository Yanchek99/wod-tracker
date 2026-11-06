require 'test_helper'

class SugarwodImportTest < ActiveSupport::TestCase
  test 'defaults to pending status' do
    sugarwod_import = SugarwodImport.create!(user: users(:mathew))
    assert sugarwod_import.pending?
  end

  test 'belongs to a user' do
    sugarwod_import = SugarwodImport.create!(user: users(:mathew))
    assert_equal users(:mathew), sugarwod_import.user
  end

  test 'is invalid without a user' do
    sugarwod_import = SugarwodImport.new(status: :pending)
    assert_not sugarwod_import.valid?
  end

  test 'stores skipped_rows as an array of hashes' do
    sugarwod_import = SugarwodImport.create!(
      user: users(:mathew), status: :completed,
      skipped_rows: [{ date: '01/01/2020', title: 'Bubbles', reason: 'llm boom' }]
    )
    sugarwod_import.reload
    assert_equal [{ 'date' => '01/01/2020', 'title' => 'Bubbles', 'reason' => 'llm boom' }], sugarwod_import.skipped_rows
  end
end
