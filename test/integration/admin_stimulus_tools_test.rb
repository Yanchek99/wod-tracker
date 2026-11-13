require 'test_helper'

class AdminStimulusToolsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    users(:brooke).update!(role: :admin)
    Program.create!(name: 'Crossfit.com').schedules.create!(workout: workouts(:murph), posted_at: 1.day.ago)
  end

  test 'admin sees the action on the workout list without missing translations' do
    sign_in users(:brooke)

    get rails_admin.index_path(model_name: 'workout')
    assert_select 'a[href$=?]', '/stimulus_tools'

    get rails_admin.stimulus_tools_path(model_name: 'workout')
    assert_response :success
    assert_select 'form[method=post]'
    assert_no_match(/translation missing/i, response.body)
  end

  test 'a recalculate dry run shows counts and writes nothing' do
    sign_in users(:brooke)

    assert_no_difference('StimulusPrediction.count') do
      assert_no_enqueued_jobs do
        post rails_admin.stimulus_tools_path(model_name: 'workout'), params: { step: 'recalculate', dry_run: '1' }
      end
    end

    assert_response :success
    assert_match(/would get new calculated values/, response.body)
  end

  test 'a fetch_text dry run shows the target count and enqueues nothing' do
    sign_in users(:brooke)

    assert_no_enqueued_jobs do
      post rails_admin.stimulus_tools_path(model_name: 'workout'), params: { step: 'fetch_text', dry_run: '1' }
    end

    assert_match(/1 existing workout/, response.body)
  end

  test 'recalculate queues the job' do
    sign_in users(:brooke)

    assert_enqueued_with(job: RecalculateStimulusJob) do
      post rails_admin.stimulus_tools_path(model_name: 'workout'), params: { step: 'recalculate' }
    end
    assert_redirected_to rails_admin.index_path(model_name: 'workout')
  end

  test 'fetch_text queues fetches for existing workouts only' do
    sign_in users(:brooke)

    assert_enqueued_jobs(1, only: FetchStimulusTextJob) do
      post rails_admin.stimulus_tools_path(model_name: 'workout'), params: { step: 'fetch_text' }
    end
    assert_no_enqueued_jobs(only: ScrapeCfWodJob)
  end

  test 'non-admins are denied' do
    users(:brooke).update!(role: :user)
    sign_in users(:brooke)

    assert_raises(CanCan::AccessDenied) do
      post rails_admin.stimulus_tools_path(model_name: 'workout'), params: { step: 'recalculate' }
    end
  end
end
