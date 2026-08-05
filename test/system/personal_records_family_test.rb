require 'application_system_test_case'

class PersonalRecordsFamilyTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'expanding a movement reveals every rep-max, each linking to its log' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 315, reps: 1)
    log.movement_logs.create!(movement: back_squat, load: 275, reps: 3)

    visit family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_selector '[data-rep-max-row-target="details"]', visible: false
    click_button 'Back Squat'
    assert_selector '[data-rep-max-row-target="details"]', visible: true
    assert_selector "[data-rep-max-row-target='details'] a[href='#{log_path(log)}']"
  end

  test 'a movement with a single rep-max has no expand button' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 315, reps: 1)

    visit family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_no_selector 'button'
  end

  test 'the gymnastics tab renders a flat list, not the expand/collapse format' do
    pullup = movements(:pullup)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: pullup, reps: 5)

    visit family_user_personal_records_url(users(:mathew), family: 'gymnastics')

    assert_text 'Pull Up'
    assert_no_selector 'button'
  end
end
