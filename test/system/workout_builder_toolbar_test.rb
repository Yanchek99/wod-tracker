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

  test 'lays out workout form fields densely on mobile' do
    page.driver.browser.manage.window.resize_to(390, 900)
    visit new_workout_url

    layout = evaluate_script(<<~JS)
      (() => {
        const rowTop = (selector) => {
          const control = document.querySelector(selector)
          const field = control.closest('.mb-3, [class*="col-"]')

          return Math.round(field.getBoundingClientRect().top)
        }
        const overflowingControls = Array.from(
          document.querySelectorAll('.workout-form input, .workout-form select, .workout-form textarea, .workout-form trix-toolbar, .workout-form trix-editor')
        ).filter((control) => {
          const rect = control.getBoundingClientRect()
          return rect.left < 0 || rect.right > document.documentElement.clientWidth
        }).length

        return {
          scoreTypeTop: rowTop('#workout_score_type'),
          teamSizeTop: rowTop('#workout_team_size'),
          timeCapTop: rowTop('#workout_time_cap'),
          segmentRoundsTop: rowTop('input[name$="[rounds]"]'),
          segmentTimeTop: rowTop('input[name$="[time_seconds]"]'),
          segmentRestTop: rowTop('input[name$="[rest_seconds]"]'),
          overflowingControls
        }
      })()
    JS

    assert_equal layout['scoreTypeTop'], layout['teamSizeTop']
    assert_equal layout['scoreTypeTop'], layout['timeCapTop']
    assert_equal layout['segmentRoundsTop'], layout['segmentTimeTop']
    assert_equal layout['segmentRoundsTop'], layout['segmentRestTop']
    assert_equal 0, layout['overflowingControls']

    click_on 'Add Exercise', match: :first

    exercise_layout = evaluate_script(<<~JS)
      (() => {
        const rowTop = (selector) => {
          const control = document.querySelector(selector)
          const field = control.closest('.mb-3, [class*="col-"]')

          return Math.round(field.getBoundingClientRect().top)
        }

        return {
          repsTop: rowTop('input[name$="[reps]"]'),
          durationTop: rowTop('input[name$="[duration_seconds]"]'),
          caloriesTop: rowTop('input[name$="[calories]"]')
        }
      })()
    JS

    assert_equal exercise_layout['repsTop'], exercise_layout['durationTop']
    assert_equal exercise_layout['repsTop'], exercise_layout['caloriesTop']
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

  test 'stacks movement dropdowns above the workout builder toolbar' do
    visit new_workout_url

    click_on 'Add Exercise', match: :first
    find('.ts-control').click

    assert_selector '.ts-dropdown'
    z_indexes = evaluate_script(<<~JS)
      (() => {
        const dropdown = document.querySelector('.workout-form .ts-dropdown')
        const toolbar = document.querySelector('.workout-builder-toolbar')

        return {
          dropdown: Number(window.getComputedStyle(dropdown).zIndex),
          toolbar: Number(window.getComputedStyle(toolbar).zIndex)
        }
      })()
    JS

    assert_operator z_indexes['dropdown'], :>, z_indexes['toolbar']
  end
end
