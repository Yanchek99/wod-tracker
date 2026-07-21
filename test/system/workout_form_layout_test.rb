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

  def assert_optional_group_state(name, state)
    expanded = state == :shown

    assert_selector format('.exercise-editor__optional-toggle[aria-expanded="%<expanded>s"]',
                           expanded: expanded),
                    text: /\A#{Regexp.escape(name)}\z/
  end

  def assert_optional_groups_hidden
    assert_optional_group_state 'Load', :hidden
    assert_optional_group_state 'Distance', :hidden
    assert_optional_group_state 'Calories', :hidden
  end

  def assert_help_text_is_tooltipped
    assert_no_text '0 = max reps'
    assert_equal 0, evaluate_script("document.querySelectorAll('label .workout-form__help').length")
    assert_selector '.workout-form__help[data-bs-animation="false"]'
    assert(page.all('.workout-form__help', visible: :visible).all? { |button| button.text.blank? })
  end

  def assert_help_targets_are_large_enough
    sizes = evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('.workout-form__help')).map((button) => {
        const rect = button.getBoundingClientRect()

        return { width: Math.round(rect.width), height: Math.round(rect.height) }
      }).filter((size) => size.width > 0 && size.height > 0)
    JS

    assert_not_empty sizes, 'Expected at least one visible help target'
    assert sizes.all? { |size| size['width'] >= 24 && size['height'] >= 24 },
           "Expected help targets to be at least 24x24px, got #{sizes.inspect}"
  end

  def assert_optional_group_reveals_fields(name, fields)
    click_on name
    assert_optional_group_state name, :shown

    fields.each { |field| assert_field field }
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
    assert_no_text 'blank = individual'
    assert_selector '#workout_team_size'
    assert_selector '.workout-form__help[aria-label="blank = individual"]'

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
      assert_field 'Duration', placeholder: 'MM:SS'
      assert_help_text_is_tooltipped
      assert_help_targets_are_large_enough
      assert_optional_groups_hidden
      assert_no_field 'Load (lb)'
      assert_no_field 'Female load (lb)'
      assert_no_field 'Distance'
      assert_no_field 'Calories'

      assert_optional_group_reveals_fields 'Load', ['Load (lb)', 'Female load (lb)']
      assert_no_text '0 = find-a-max'
      assert_optional_group_reveals_fields 'Distance', ['Distance', 'Female distance']
      assert_optional_group_reveals_fields 'Calories', ['Calories', 'Female calories']
      assert_help_text_is_tooltipped
      assert_help_targets_are_large_enough
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

      assert_optional_group_state 'Load', :shown
      assert_optional_group_state 'Distance', :hidden
      assert_optional_group_state 'Calories', :hidden
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
