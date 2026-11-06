require 'test_helper'

class AppShellTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:mathew) }

  test 'sidebar and tab bar link every destination' do
    get workouts_url

    assert_response :success
    [schedules_path, workouts_path, programs_path, logs_path,
     family_user_personal_records_path(users(:mathew), family: 'weightlifting')].each do |path|
      assert_select 'nav.app-sidebar a[href=?]', path
      assert_select 'nav.app-tabbar a[href=?]', path
    end
    assert_select 'nav.app-tabbar a', count: 5
  end

  test 'tab bar has four tabs when the user has no schedules' do
    Schedule.delete_all

    get workouts_url

    assert_select 'nav.app-tabbar a', count: 4
    assert_select 'nav.app-tabbar a[href=?]', schedules_path, count: 0
    assert_select 'nav.app-sidebar a[href=?]', schedules_path, count: 0
  end

  test 'current destination is marked with aria-current' do
    get workouts_url

    assert_select 'nav.app-sidebar a[aria-current="page"][href=?]', workouts_path
    assert_select 'nav.app-tabbar a[aria-current="page"][href=?]', workouts_path
    assert_select 'a[aria-current="page"]', count: 2
  end

  test 'sidebar shows the user initials and name' do
    get workouts_url

    assert_select '.app-avatar', text: 'MF'
    assert_select '.app-user-name', text: 'Mathew Fraser'
    assert_select '.app-user-sub', text: 'Account & sign out'
  end

  test 'old bootstrap navbar is gone' do
    get workouts_url

    assert_select '.navbar', count: 0
  end

  test 'account menu offers profile and logout but no admin link to regular users' do
    users(:mathew).update!(role: :user)

    get workouts_url

    assert_select '.app-account-menu a[href=?]', edit_user_registration_path
    assert_select '.app-account-menu a[href=?]', destroy_user_session_path
    assert_select 'a[href=?]', rails_admin_path, count: 0
  end

  test 'viewport covers the safe area for the installed app' do
    get workouts_url

    assert_select 'meta[name=viewport][content*="viewport-fit=cover"]'
  end

  test 'workout builder pages opt out of the constrained content width' do
    get new_workout_url

    assert_select 'main.app-content.app-content--wide'
  end

  test 'regular pages use the constrained content area' do
    get workouts_url

    assert_select 'main.app-content'
    assert_select 'main.app-content--wide', count: 0
  end

  test 'phone title bar shows the page title fallback from the controller name' do
    get programs_url

    assert_select '.app-topbar', text: /Programs/
  end
end
