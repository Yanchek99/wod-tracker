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

    layout = page.evaluate_script(<<~JS)
      (() => {
      const card = document.querySelectorAll('.card.mb-3')[1]
      const inputs = Array.from(card.querySelectorAll('.recording-value')).filter((input) => input.offsetParent !== null)
      return inputs.map((input) => ({
        columnTop: Math.round(input.closest('.col').getBoundingClientRect().top),
        inputTop: Math.round(input.getBoundingClientRect().top)
      }))
      })()
    JS

    layout.group_by { |field| field['columnTop'] }.each_value do |row|
      input_tops = row.map { |field| field['inputTop'] }

      assert_equal 1, input_tops.uniq.size, "expected mobile recording inputs in each row to align, got: #{layout.inspect}"
    end
  ensure
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end
end
