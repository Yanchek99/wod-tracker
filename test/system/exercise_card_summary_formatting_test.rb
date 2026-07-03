require 'application_system_test_case'

class ExerciseCardSummaryFormattingTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
    Movement.find_or_create_by!(name: 'Dumbbell Overhead Walking Lunge')
  end

  teardown do
    Warden.test_reset!
  end

  test 'renders distance before movement with load after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Run'
      fill_in 'Reps', with: '1'
      fill_in 'Distance', with: '10', exact: true
      select 'meter', from: 'Distance unit'
      fill_in 'Load', with: '95'
      select 'lb', from: 'Load unit'
      click_on 'Done'

      assert_text '10 meter Run (95 lbs)'
    end
  end

  test 'renders sex-specific distance before movement with sex-specific load after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Run'
      fill_in 'Reps', with: '1'
      fill_in 'Female load', with: '65'
      fill_in 'Male load', with: '95'
      select 'lb', from: 'Load unit'
      fill_in 'Female distance', with: '80'
      fill_in 'Male distance', with: '100'
      select 'meter', from: 'Distance unit'
      click_on 'Done'

      assert_text '100/80 meter Run (♀65lb / ♂95lb)'
    end
  end

  test 'renders sex-specific distance before movement after local save' do
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

  test 'renders distance before movement for loaded lunges after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Dumbbell Overhead Walking Lunge'
      fill_in 'Reps', with: '1'
      fill_in 'Distance', with: '80', exact: true
      select 'foot', from: 'Distance unit'
      fill_in 'Female load', with: '35'
      fill_in 'Male load', with: '50'
      select 'lb', from: 'Load unit'
      click_on 'Done'

      assert_text '80ft Dumbbell Overhead Walking Lunge (♀35lb / ♂50lb)'
    end
  end

  test 'renders sex-specific foot distance before movement for loaded lunges after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Dumbbell Overhead Walking Lunge'
      fill_in 'Reps', with: '1'
      fill_in 'Female distance', with: '30'
      fill_in 'Male distance', with: '40'
      select 'foot', from: 'Distance unit'
      fill_in 'Female load', with: '35'
      fill_in 'Male load', with: '50'
      select 'lb', from: 'Load unit'
      click_on 'Done'

      assert_text '40/30ft Dumbbell Overhead Walking Lunge (♀35lb / ♂50lb)'
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
