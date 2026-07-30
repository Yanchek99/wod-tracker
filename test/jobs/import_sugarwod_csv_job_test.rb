require 'test_helper'

class ImportSugarwodCsvJobTest < ActiveJob::TestCase
  setup { @user = users(:mathew) }

  test 'processes each row and marks the import completed with counts' do
    sugarwod_import = SugarwodImport.create!(user: @user, status: :pending)
    rows = [
      { 'date' => '01/02/2018', 'title' => 'Fran', 'description' => '21-15-9 reps for time of:• Thruster 95/65#• Pull-ups',
        'best_result_raw' => '378', 'best_result_display' => '6:18', 'score_type' => '', 'barbell_lift' => '',
        'notes' => 'good' },
      { 'date' => '01/03/2018', 'title' => 'Daily Check-in', 'description' => 'Stretched?', 'best_result_raw' => '1',
        'best_result_display' => 'Yes', 'score_type' => 'Checkbox', 'barbell_lift' => '', 'notes' => '' },
      { 'date' => '01/04/2018', 'title' => 'Totally Novel', 'description' => 'Some totally novel coaching shorthand',
        'best_result_raw' => '5', 'best_result_display' => '5', 'score_type' => 'Reps', 'barbell_lift' => '', 'notes' => '' }
    ]

    stub_llm_parser(->(*, **) { raise WorkoutExtraction::LlmParser::ExtractionError, 'llm boom' }) do
      perform_enqueued_jobs { ImportSugarwodCsvJob.perform_later(sugarwod_import.id, rows) }
    end

    sugarwod_import.reload
    assert sugarwod_import.completed?
    assert_equal 1, sugarwod_import.imported_count
    assert_equal 0, sugarwod_import.already_imported_count
    assert_equal 2, sugarwod_import.skipped_count
    assert_equal(['not a workout score type', 'llm boom'], sugarwod_import.skipped_rows.pluck('reason'))
  end

  test 'a malformed date in one row does not abort the rest of the batch' do
    sugarwod_import = SugarwodImport.create!(user: @user, status: :pending)
    rows = [
      { 'date' => '01/02/2018', 'title' => 'Fran', 'description' => '21-15-9 reps for time of:• Thruster 95/65#• Pull-ups',
        'best_result_raw' => '378', 'best_result_display' => '6:18', 'score_type' => '', 'barbell_lift' => '',
        'notes' => 'good' },
      { 'date' => 'not-a-date', 'title' => 'Bad Date Row', 'description' => 'whatever', 'best_result_raw' => '1',
        'best_result_display' => '1', 'score_type' => 'Reps', 'barbell_lift' => '', 'notes' => '' },
      { 'date' => '01/04/2018', 'title' => 'Daily Check-in', 'description' => 'Stretched?', 'best_result_raw' => '1',
        'best_result_display' => 'Yes', 'score_type' => 'Checkbox', 'barbell_lift' => '', 'notes' => '' }
    ]

    perform_enqueued_jobs { ImportSugarwodCsvJob.perform_later(sugarwod_import.id, rows) }

    sugarwod_import.reload
    assert sugarwod_import.completed?
    assert_equal 1, sugarwod_import.imported_count
    assert_equal 0, sugarwod_import.already_imported_count
    assert_equal 2, sugarwod_import.skipped_count

    bad_row = sugarwod_import.skipped_rows.find { |r| r['title'] == 'Bad Date Row' }
    assert bad_row.present?, 'expected the malformed-date row to be recorded as skipped'
    assert_match(/invalid date/i, bad_row['reason'])

    checkin_row = sugarwod_import.skipped_rows.find { |r| r['title'] == 'Daily Check-in' }
    assert_equal 'not a workout score type', checkin_row['reason']
  end
end
