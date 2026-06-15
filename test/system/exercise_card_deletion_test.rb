require 'application_system_test_case'

class ExerciseCardDeletionTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'deletes a collapsed exercise card from the summary row' do
    visit new_workout_url

    click_on 'Add Exercise'

    within '.exercise' do
      find('.ts-control input').set('Pull')
      find('.ts-dropdown .option', text: 'Pull Up').click
      click_on 'Save Exercise'

      assert_text 'Pull Up'
      find('[aria-label="Delete exercise"]').click
    end

    assert_no_selector '.exercise'
  end
end
