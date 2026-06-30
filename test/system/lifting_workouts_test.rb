require 'application_system_test_case'

class LiftingWorkoutsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'logs set-based lifting workouts as one recording per set' do
    visit workout_url(workouts(:back_squat_5x5))

    click_on 'Log'

    assert_no_selector '#log_score_value'
    assert_text 'Score will be calculated from the heaviest successful load.'
    assert_selector '.card.mb-3', count: 5
    movement_logs = all('.card.mb-3')
    movement_logs.each do |movement_log|
      values = movement_log.all('.recording-value').map(&:value)

      assert_equal ['5', '', '', '', ''], values # [reps, duration, load, distance, calories]
    end

    [95, 115, 135, 145, 155].each.with_index do |load, index|
      movement_logs[index].all('.recording-value')[2].set(load)
    end
    movement_logs[4].first('.recording-value').set(2)

    click_on 'Save'

    assert_current_path %r{/logs/\d+}
    assert_text '145 lbs'
  end
end
