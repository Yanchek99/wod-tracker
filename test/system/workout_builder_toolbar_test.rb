require 'application_system_test_case'

class WorkoutBuilderToolbarTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'keeps workout builder toolbar fixed to the bottom while scrolling' do
    visit new_workout_url

    8.times { click_on 'Add Exercise', match: :first }
    execute_script('window.scrollTo(0, Math.floor(document.body.scrollHeight / 2))')

    assert_selector '.workout-builder-toolbar'
    toolbar_bottom = evaluate_script(<<~JS)
      window.innerHeight - document.querySelector('.workout-builder-toolbar').getBoundingClientRect().bottom
    JS
    assert_operator toolbar_bottom, :>=, 0
    assert_operator toolbar_bottom, :<=, 16
  end

  test 'lays out workout builder toolbar on mobile' do
    page.driver.browser.manage.window.resize_to(390, 900)
    visit new_workout_url

    assert_selector '.workout-builder-toolbar'
    overflowing_buttons = evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('.workout-builder-toolbar .btn')).filter((button) => {
        const rect = button.getBoundingClientRect()
        return rect.left < 0 || rect.right > window.innerWidth || button.scrollWidth > button.clientWidth
      }).length
    JS

    assert_equal 0, overflowing_buttons
  ensure
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test 'uses a full-width toolbar bar with container-width actions' do
    page.driver.browser.manage.window.resize_to(1400, 900)
    visit new_workout_url

    assert_selector '.workout-builder-toolbar__actions'
    layout = evaluate_script(<<~JS)
      (() => {
        const toolbar = document.querySelector('.workout-builder-toolbar').getBoundingClientRect()
        const actions = document.querySelector('.workout-builder-toolbar__actions').getBoundingClientRect()

        return {
          toolbarLeft: toolbar.left,
          toolbarRight: toolbar.right,
          viewportWidth: document.documentElement.clientWidth,
          actionsWidth: actions.width,
          actionsCenter: actions.left + (actions.width / 2)
        }
      })()
    JS

    assert_in_delta 0, layout['toolbarLeft'], 1
    assert_in_delta layout['viewportWidth'], layout['toolbarRight'], 1
    assert_operator layout['actionsWidth'], :<=, 1320
    assert_in_delta layout['viewportWidth'] / 2, layout['actionsCenter'], 1
  ensure
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end
end
