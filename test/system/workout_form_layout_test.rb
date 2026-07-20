require 'application_system_test_case'

module WorkoutFormLayoutSystemHelpers
  WORKOUT_FORM_LAYOUT_SCRIPT = <<~JS.freeze
    (() => {
      return {
        scoreTypeTop: rowTop('#workout_score_type'),
        teamSizeTop: rowTop('#workout_team_size'),
        timeCapTop: rowTop('#workout_time_cap'),
        segmentRoundsTop: rowTop('input[name$="[rounds]"]'),
        segmentTimeTop: rowTop('input[name$="[time_seconds]"]'),
        segmentRestTop: rowTop('input[name$="[rest_seconds]"]'),
        overflowingControls: overflowingControls()
      }

      function rowTop(selector) {
        const control = document.querySelector(selector)
        const field = control.closest('.mb-3, [class*="col-"]')

        return Math.round(field.getBoundingClientRect().top)
      }

      function overflowingControls() {
        return Array.from(
          document.querySelectorAll('.workout-form input, .workout-form select, .workout-form textarea, .workout-form trix-toolbar, .workout-form trix-editor')
        ).filter((control) => {
          const rect = control.getBoundingClientRect()
          return rect.left < 0 || rect.right > document.documentElement.clientWidth
        }).length
      }
    })()
  JS

  EXERCISE_FORM_LAYOUT_SCRIPT = <<~JS.freeze
    (() => {
      return {
        repsTop: rowTop('input[name$="[reps]"]'),
        durationTop: rowTop('input[name$="[duration_seconds]"]')
      }

      function rowTop(selector) {
        const control = document.querySelector(selector)
        const field = control.closest('.mb-3, [class*="col-"]')

        return Math.round(field.getBoundingClientRect().top)
      }
    })()
  JS

  def workout_form_layout
    evaluate_script(WORKOUT_FORM_LAYOUT_SCRIPT)
  end

  def exercise_form_layout
    evaluate_script(EXERCISE_FORM_LAYOUT_SCRIPT)
  end
end

class WorkoutFormLayoutTest < ApplicationSystemTestCase
  include WorkoutFormLayoutSystemHelpers
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'lays out workout form fields densely on mobile' do
    page.driver.browser.manage.window.resize_to(390, 900)
    visit new_workout_url

    layout = workout_form_layout

    assert_equal layout['scoreTypeTop'], layout['teamSizeTop']
    assert_equal layout['scoreTypeTop'], layout['timeCapTop']
    assert_equal layout['segmentRoundsTop'], layout['segmentTimeTop']
    assert_equal layout['segmentRoundsTop'], layout['segmentRestTop']
    assert_equal 0, layout['overflowingControls']

    click_on 'Add Exercise', match: :first

    exercise_layout = exercise_form_layout

    assert_equal exercise_layout['repsTop'], exercise_layout['durationTop']
  ensure
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test 'collapses optional exercise prescription groups on mobile' do
    page.driver.browser.manage.window.resize_to(390, 900)
    visit new_workout_url

    click_on 'Add Exercise', match: :first

    within '.exercise' do
      assert_field 'Duration', placeholder: '1:30'
      assert_no_field 'Load (lb)'
      assert_no_field 'Female load (lb)'
      assert_no_field 'Distance'
      assert_no_field 'Calories'

      click_on 'Load'
      assert_field 'Load (lb)'
      assert_field 'Female load (lb)'

      click_on 'Distance'
      assert_field 'Distance'
      assert_field 'Female distance'

      click_on 'Calories'
      assert_field 'Calories'
      assert_field 'Female calories'
    end
  ensure
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test 'opens optional exercise prescription groups when existing values are present' do
    page.driver.browser.manage.window.resize_to(390, 900)
    visit edit_workout_url(workouts(:fran))

    find('.segment-summary__button').click
    exercise = first('.exercise', text: 'Thruster')
    within exercise do
      find('.exercise-summary__button').click

      assert_field 'Load (lb)', with: '95'
      assert_no_field 'Distance'
      assert_no_field 'Calories'
    end
  ensure
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test 'uses duration strings for exercise duration inputs' do
    visit new_workout_url

    click_on 'Add Exercise', match: :first

    within '.exercise' do
      find('.ts-control input').set('Run')
      find('.ts-dropdown .option', text: 'Run').click
      fill_in 'Duration', with: '1:30'
      click_on 'Done'

      assert_text '1:30 Run'
    end
  end
end
