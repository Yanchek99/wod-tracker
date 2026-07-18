require 'application_system_test_case'

class ExerciseCardMetricDisplayTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'renders the local summary in kilograms for a metric athlete' do
    users(:mathew).update!(unit_system: :metric)
    visit new_manual_workouts_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Thruster'
      fill_in 'Reps', with: '21'
      fill_in 'Load (kg)', with: '43'
      click_on 'Done'

      assert_text '21 Thrusters (43 kgs)'
    end
  end

  private

  def select_movement(name)
    find('.ts-control input').set(name)
    find('.ts-dropdown .option', text: name).click
  end
end
