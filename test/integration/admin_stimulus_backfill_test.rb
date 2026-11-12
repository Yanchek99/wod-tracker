require 'test_helper'

class AdminStimulusBackfillTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    users(:brooke).update!(role: :admin)
    Workout.create!(name: 'Pending Stimulus', score_type: :time, intended_stimulus_notes: 'Keep it fast.')
  end

  test 'admin sees the action on the workout list without missing translations' do
    sign_in users(:brooke)

    get rails_admin.index_path(model_name: 'workout')

    assert_select 'a[href$=?]', '/stimulus_backfill'
    get rails_admin.stimulus_backfill_path(model_name: 'workout')
    assert_response :success
    assert_select 'form[method=post]'
    assert_no_match(/translation missing/i, response.body)
  end

  test 'the scrape range defaults to when CrossFit.com began posting Stimulus and Strategy' do
    sign_in users(:brooke)

    get rails_admin.stimulus_backfill_path(model_name: 'workout')

    assert_select 'input[name=start_date][value=?]', '2024-12-01'
  end

  test 'a dry run shows counts and enqueues nothing' do
    sign_in users(:brooke)

    assert_no_enqueued_jobs do
      post rails_admin.stimulus_backfill_path(model_name: 'workout'),
           params: { step: 'extract', dry_run: '1' }
    end

    assert_response :success
    assert_match(/1 workout.* to extract/, response.body)
  end

  test 'POST enqueues the chosen step' do
    sign_in users(:brooke)

    assert_enqueued_with(job: StimulusBackfillJob, args: ['predict', { start_date: nil, end_date: nil, force: false }]) do
      post rails_admin.stimulus_backfill_path(model_name: 'workout'), params: { step: 'predict' }
    end

    assert_redirected_to rails_admin.index_path(model_name: 'workout')
  end

  test 'non-admins are denied' do
    users(:brooke).update!(role: :user)
    sign_in users(:brooke)

    assert_no_enqueued_jobs do
      assert_raises(CanCan::AccessDenied) do
        post rails_admin.stimulus_backfill_path(model_name: 'workout'), params: { step: 'predict' }
      end
    end
  end
end
