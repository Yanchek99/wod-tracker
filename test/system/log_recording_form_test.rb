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
end
