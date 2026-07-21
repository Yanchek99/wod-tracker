require 'application_system_test_case'

module ExerciseCardSummaryFormattingSystemHelpers
  def setup_summary_formatting_test
    login_as users(:mathew), scope: :user
    Movement.find_or_create_by!(name: 'Dumbbell Overhead Walking Lunge')
  end

  def open_optional_group(name)
    execute_script("document.querySelectorAll('select.movement').forEach((select) => select.tomselect?.close())")
    toggle = find('button.exercise-editor__optional-toggle', text: name)

    click_optional_group_toggle(toggle) if toggle['aria-expanded'] == 'false'
    assert_selector 'button.exercise-editor__optional-toggle[aria-expanded="true"]', text: name
  end

  def click_optional_group_toggle(toggle)
    toggle.click
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError
    execute_script('arguments[0].click()', toggle)
  end
end

class ExerciseCardSummaryFormattingTest < ApplicationSystemTestCase
  include ExerciseCardSummaryFormattingSystemHelpers
  include Warden::Test::Helpers

  setup { setup_summary_formatting_test }

  teardown { Warden.test_reset! }

  test 'renders distance before movement with load after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Run'
      fill_in 'Reps', with: '1'
      open_optional_group 'Distance'
      fill_in 'Distance', with: '10', exact: true
      select 'meter', from: 'Distance unit'
      open_optional_group 'Load'
      fill_in 'Load (lb)', with: '95'
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
      open_optional_group 'Load'
      fill_in 'Female load (lb)', with: '65'
      fill_in 'Male load (lb)', with: '95'
      open_optional_group 'Distance'
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
      open_optional_group 'Distance'
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
      open_optional_group 'Distance'
      fill_in 'Distance', with: '80', exact: true
      select 'foot', from: 'Distance unit'
      open_optional_group 'Load'
      fill_in 'Female load (lb)', with: '35'
      fill_in 'Male load (lb)', with: '50'
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
      open_optional_group 'Distance'
      fill_in 'Female distance', with: '30'

      # Typing into Female distance is what flips exercise-form#toggleDistanceUnits' hasDistance
      # check from false to true for the first time (both distance fields share the same
      # exercise-form-target: distanceValue binding), which un-hides the "Distance units per rep"
      # field further down the card. Waiting for Female distance to visibly settle here gives that
      # DOM change a chance to finish before Capybara moves on to click into Male distance right
      # after it -- without this, Male distance intermittently ends up empty (reproduced locally
      # ~1 in 6-8 runs before this fix; 30/30 clean after it).
      assert_field 'Female distance', with: '30'

      fill_in 'Male distance', with: '40'
      select 'foot', from: 'Distance unit'
      open_optional_group 'Load'
      fill_in 'Female load (lb)', with: '35'
      fill_in 'Male load (lb)', with: '50'
      assert_field 'Female distance', with: '30'
      assert_field 'Male distance', with: '40'
      assert_select 'Distance unit', selected: 'foot'
      click_on 'Done'

      assert_text '40/30ft Dumbbell Overhead Walking Lunge (♀35lb / ♂50lb)'
    end
  end

  test 'renders max calories before movement after local save' do
    visit new_workout_url
    click_on 'Add Exercise'

    within '.exercise' do
      select_movement 'Row'
      open_optional_group 'Calories'
      fill_in 'Calories', with: '0'
      click_on 'Done'

      assert_equal 'max calories Row', find('.exercise-summary__text').text
    end
  end

  private

  def select_movement(name)
    find('.ts-control input').set(name)
    find('.ts-dropdown .option', text: name).click
  end
end
