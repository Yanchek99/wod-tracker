require 'application_system_test_case'

class WorkoutShowPanelsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @workout = workouts(:fran)
    @workout.update!(notes: 'Unbroken thrusters if you can.', intended_stimulus_notes: 'Fast and unbroken.')
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test 'on a phone Notes and Intended stimulus start collapsed and open when tapped' do
    page.driver.browser.manage.window.resize_to(390, 900)
    visit workout_path(@workout)

    assert_selector '.workout-notes .workout-collapsible-body', visible: :hidden
    assert_selector '.workout-stimulus .workout-collapsible-body', visible: :hidden

    within('.workout-notes') { click_button class: 'workout-collapsible-header' }

    assert_selector '.workout-notes .workout-collapsible-body', visible: :visible
    assert_equal 'true', find('.workout-notes button')['aria-expanded']
  end

  test 'on desktop Notes start open and can collapse, and Intended stimulus stays open' do
    visit workout_path(@workout)

    assert_selector '.workout-notes .workout-collapsible-body', visible: :visible
    within('.workout-notes') { click_button class: 'workout-collapsible-header' }
    assert_selector '.workout-notes .workout-collapsible-body', visible: :hidden

    page.execute_script("document.querySelector('.workout-stimulus button').click()")

    assert_selector '.workout-stimulus .workout-collapsible-body', visible: :visible
  end

  test 'rotating a phone to landscape opens a locked Intended stimulus panel and disables its toggle' do
    page.driver.browser.manage.window.resize_to(390, 900)
    visit workout_path(@workout)
    assert_selector '.workout-stimulus .workout-collapsible-body', visible: :hidden

    page.driver.browser.manage.window.resize_to(900, 700)

    assert_selector '.workout-stimulus .workout-collapsible-body', visible: :visible
    assert_selector '.workout-stimulus button[disabled]'
  end
end
