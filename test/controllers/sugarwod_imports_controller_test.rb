require 'test_helper'

class SugarwodImportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup { sign_in users(:mathew) }

  test 'uploading a valid CSV creates a SugarwodImport and enqueues the import job' do
    csv = "date,title,description,best_result_raw,best_result_display,score_type,barbell_lift,notes\n" \
          "01/02/2018,Fran,21-15-9 reps for time of:,378,6:18,,,\n"
    file = Rack::Test::UploadedFile.new(StringIO.new(csv), 'text/csv', original_filename: 'workouts.csv')

    assert_enqueued_with(job: ImportSugarwodCsvJob) do
      post sugarwod_imports_path, params: { file: file }
    end

    sugarwod_import = SugarwodImport.last
    assert_redirected_to sugarwod_import_path(sugarwod_import)
    assert sugarwod_import.pending?
    assert_equal users(:mathew), sugarwod_import.user
  end

  test 'uploading a CSV with missing headers re-renders the form with an error' do
    file = Rack::Test::UploadedFile.new(StringIO.new("not,the,right,headers\n1,2,3,4\n"), 'text/csv',
                                        original_filename: 'bad.csv')

    post sugarwod_imports_path, params: { file: file }

    assert_response :unprocessable_content
    assert_match(/missing required columns/, flash[:alert])
  end

  test 'show renders the results once the import completes' do
    sugarwod_import = users(:mathew).sugarwod_imports.create!(
      status: :completed, imported_count: 3, already_imported_count: 1, skipped_count: 1,
      skipped_rows: [{ 'date' => '01/01/2020', 'title' => 'Bubbles', 'reason' => 'llm boom' }]
    )

    get sugarwod_import_path(sugarwod_import)

    assert_response :success
    assert_match(/Bubbles/, response.body)
    assert_match(/llm boom/, response.body)
  end

  test "show cannot be accessed for another user's import" do
    other_import = users(:brooke).sugarwod_imports.create!(status: :pending)

    get sugarwod_import_path(other_import)

    assert_response :not_found
  end
end
