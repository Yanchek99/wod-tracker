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
    assert_text 'Score will be calculated from the heaviest successful set.'
    assert_selector '.card.mb-3', count: 5
    movement_logs = all('.card.mb-3')
    movement_logs.each do |movement_log|
      values = movement_log.all('input[name$="[value]"]').map(&:value)

      assert_equal ['5', ''], values
    end

    [95, 115, 135, 145, 155].each.with_index do |load, index|
      movement_logs[index].all('input[name$="[value]"]')[1].set(load)
    end
    movement_logs[4].first('input[name$="[value]"]').set(2)

    click_on 'Save'

    assert_current_path %r{/logs/\d+}
    assert_text '145 lbs'
  end
end
