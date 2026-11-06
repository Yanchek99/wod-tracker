require 'application_system_test_case'

class WorkoutHistoryTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'history feed lists logged workouts with scores' do
    visit logs_url

    assert_selector 'h1', text: 'History'
    assert_selector '.card', text: workouts(:murph).name
    assert_link workouts(:murph).name, href: workout_path(workouts(:murph))
  end

  test 'clicking a history item navigates to the log instead of showing a missing turbo frame' do
    visit logs_url

    find(%(a[aria-label="View #{workouts(:murph).name} log"])).click

    assert_current_path log_path(logs(:matt_murph))
    assert_no_text 'Content missing'
  end
end
