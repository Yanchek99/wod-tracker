require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def save_exercise_card(expected_summary)
    done_button = find_button('Done')
    scroll_to done_button, align: :center
    done_button.click

    assert_selector '.exercise-summary__button[aria-expanded="false"]', text: expected_summary
    assert_no_selector '.exercise-editor', visible: :visible
  end
end
