require 'application_system_test_case'

class WorkoutBuilderToolbarTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'keeps workout builder toolbar visible while scrolling' do
    visit new_workout_url

    8.times { click_on 'Add Exercise', match: :first }
    execute_script('window.scrollTo(0, document.body.scrollHeight)')

    assert_selector '.workout-builder-toolbar'
    toolbar_top = evaluate_script("document.querySelector('.workout-builder-toolbar').getBoundingClientRect().top")
    assert_operator toolbar_top, :>=, 0
    assert_operator toolbar_top, :<=, 16
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
end
