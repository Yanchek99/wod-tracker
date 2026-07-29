require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def save_exercise_card(expected_summary)
    done_button = find_button('Done')
    scroll_to done_button, align: :center
    done_button.click

    begin
      assert_selector '.exercise-summary__button[aria-expanded="false"]', text: expected_summary
    rescue Minitest::Assertion
      # Selenium's click on Done occasionally doesn't register even though the button is stable and
      # correctly positioned (reproduced locally by shrinking Capybara's wait time -- the click call
      # itself never raises, but the exercise-card#save Stimulus action never fires). Retrying once
      # is a safe no-op if the first click actually worked, since Done would no longer be present.
      click_on 'Done'
      assert_selector '.exercise-summary__button[aria-expanded="false"]', text: expected_summary
    end

    assert_no_selector '.exercise-editor', visible: :visible
  end
end
