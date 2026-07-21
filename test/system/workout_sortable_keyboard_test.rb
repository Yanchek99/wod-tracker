require 'application_system_test_case'

class WorkoutSortableKeyboardTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'reorders collapsed workout cards with keyboard handles' do
    visit new_workout_url

    fill_in 'Name *', with: 'Keyboard Ordered Parts'
    select 'time', from: 'For'

    # Filling the workout's own Name/For fields collapses the default segment
    # (segment-card#handleDocumentClick fires on any click outside its card) --
    # re-expand it to add an exercise, then collapse it back with its own Done.
    default_segment = all('#workout-parts > .fields > .workout-part').last
    add_pull_up_exercise(default_segment)

    click_on 'Add Segment'
    segment = all('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]').last
    within segment do
      fill_in 'Name', with: 'Moved Segment'
      click_on 'Done'
      find('[aria-label="Drag segment"]').send_keys(:arrow_up)
    end

    assert_text_order 'Moved Segment:', '10 Pull Ups'
    # `>` scopes to each segment's own hidden position field, not the position fields
    # of exercises nested inside it (which also end in "[position]").
    assert_equal %w[1 2], all(
      '#workout-parts > .fields > .workout-part:not([hidden]) > input[name$="[position]"]',
      visible: false
    ).map(&:value)
  end

  private

  def add_pull_up_exercise(segment)
    within segment do
      click_on 'New segment'
      click_on 'Add Exercise'
    end
    within all('.exercise').last do
      find('.ts-control input').set('Pull')
      find('.ts-dropdown .option', text: 'Pull Up').click
      fill_in 'Reps', with: '10'
      click_on 'Done'
    end
    within segment do
      click_on 'Done'
    end
  end

  def assert_text_order(*texts)
    parts_text = find('#workout-parts > .fields').text
    indexes = texts.map { |text| parts_text.index(text) }

    assert indexes.all?, "expected #{parts_text.inspect} to include #{texts.inspect}"
    assert_equal indexes.sort, indexes, "expected #{texts.inspect} to appear in order within #{parts_text.inspect}"
  end
end
