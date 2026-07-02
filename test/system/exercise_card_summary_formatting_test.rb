require 'application_system_test_case'

class ExerciseCardSummaryFormattingTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'orders additional distance before load after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Run'
      fill_in 'Reps', with: '1'
      fill_in 'Distance', with: '10', exact: true
      select 'meter', from: 'Distance unit'
      fill_in 'Load (lb)', with: '95'
      click_on 'Done'

      assert_text 'Run (10 meters / 95 lbs)'
    end
  end

  test 'groups sex-specific additional metrics after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Run'
      fill_in 'Reps', with: '1'
      fill_in 'Female load (lb)', with: '65'
      fill_in 'Male load (lb)', with: '95'
      fill_in 'Female distance', with: '80'
      fill_in 'Male distance', with: '100'
      select 'meter', from: 'Distance unit'
      click_on 'Done'

      assert_text 'Run (♀65lb + 80-meter / ♂95lb + 100-meter)'
    end
  end

  test 'uses sex-specific distance as leading work after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Run'
      fill_in 'Reps', with: '1'
      fill_in 'Female distance', with: '80'
      fill_in 'Male distance', with: '100'
      select 'meter', from: 'Distance unit'
      click_on 'Done'

      assert_text '100/80 meter Run'
    end
  end

  test 'omits zero calories from the local summary' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Row'
      fill_in 'Calories', with: '0'
      click_on 'Done'

      assert_text 'Row'
    end
  end

  private

  def select_movement(name)
    find('.ts-control input').set(name)
    find('.ts-dropdown .option', text: name).click
  end
end
