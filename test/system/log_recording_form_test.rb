require 'application_system_test_case'

class LogRecordingFormTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'Edit button reveals the fields the workout does not prescribe' do
    visit workout_url(workouts(:fran))
    click_on 'Log'

    pullup_card = all('.card.mb-3')[1] # Pullups: reps only -- see test/fixtures/exercises.yml

    assert_no_selector "input[name$='[duration_seconds]']", visible: true
    within pullup_card do
      click_on 'Edit'
    end

    assert_selector "input[name$='[duration_seconds]']", visible: true
  end

  test 'changing the movement reveals the fields the original prescription did not need' do
    visit workout_url(workouts(:fran))
    click_on 'Log'

    pullup_card = all('.card.mb-3')[1] # Pullups: reps only -- see test/fixtures/exercises.yml

    assert_no_selector "input[name$='[duration_seconds]']", visible: true
    within pullup_card do
      find('select.movement').find('option', text: 'Push Up', exact_text: true).select_option
    end

    assert_selector "input[name$='[duration_seconds]']", visible: true
  end

  test 'mobile recording inputs stay aligned when all metrics are visible' do
    page.driver.browser.manage.window.resize_to(390, 900)
    visit workout_url(workouts(:fran))
    click_on 'Log'

    pullup_card = all('.card.mb-3')[1] # Pullups: reps only -- see test/fixtures/exercises.yml
    within pullup_card do
      click_on 'Edit'
    end

    layout = recording_field_layout(pullup_card)

    assert layout.all? { |field| field['fieldWidth'] >= 130 }, layout.inspect
    assert layout.none? { |field| field['inputOverflows'] || field['overflowsViewport'] }, layout.inspect
    assert_recording_inputs_align_by_row(layout)
  ensure
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  private

  def recording_field_layout(card)
    card.evaluate_script(<<~JS)
      Array.from(this.querySelectorAll('[data-log-exercise-target~="field"]:not([hidden])')).map((field) => {
        const rect = field.getBoundingClientRect()
        const input = field.querySelector('.recording-value')
        return {
          fieldWidth: rect.width,
          fieldTop: Math.round(rect.top),
          inputTop: Math.round(input.getBoundingClientRect().top),
          inputOverflows: input.scrollWidth > input.clientWidth,
          overflowsViewport: rect.left < 0 || rect.right > window.innerWidth
        }
      })
    JS
  end

  def assert_recording_inputs_align_by_row(layout)
    layout.group_by { |field| field['fieldTop'] }.each_value do |row|
      input_tops = row.map { |field| field['inputTop'] }

      assert_equal 1, input_tops.uniq.size, "expected mobile recording inputs in each row to align, got: #{layout.inspect}"
    end
  end
end
