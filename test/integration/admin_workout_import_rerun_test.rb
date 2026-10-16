require 'test_helper'

class AdminWorkoutImportRerunTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @import = WorkoutImport.create!(workout_date: Date.new(2026, 6, 20), status: :failed, error_message: 'boom')
    users(:brooke).update!(role: :admin)
  end

  test 'GET renders a confirmation page without enqueueing' do
    sign_in users(:brooke)

    assert_no_enqueued_jobs do
      get rails_admin.rerun_heuristic_path(model_name: 'workout_import', id: @import.id)
    end

    assert_response :success
    assert_select 'form[method=post]'
  end

  test 'POST rerun_heuristic enqueues the scrape with the heuristic parser and no fallback' do
    sign_in users(:brooke)

    assert_enqueued_with(job: ScrapeCfWodJob, args: [Date.new(2026, 6, 20), :heuristic, nil]) do
      post rails_admin.rerun_heuristic_path(model_name: 'workout_import', id: @import.id)
    end

    assert_redirected_to rails_admin.index_path(model_name: 'workout_import')
  end

  test 'POST rerun_llm enqueues the scrape with the llm parser and no fallback' do
    sign_in users(:brooke)

    assert_enqueued_with(job: ScrapeCfWodJob, args: [Date.new(2026, 6, 20), :llm, nil]) do
      post rails_admin.rerun_llm_path(model_name: 'workout_import', id: @import.id)
    end
  end

  test 'non-admins cannot re-run' do
    users(:brooke).update!(role: :user)
    sign_in users(:brooke)

    assert_no_enqueued_jobs do
      assert_raises(CanCan::AccessDenied) do
        post rails_admin.rerun_llm_path(model_name: 'workout_import', id: @import.id)
      end
    end
  end
end
