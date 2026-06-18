require 'application_system_test_case'

module WorkoutDragOrderingSystemHelpers
  def fill_required_workout_fields(name)
    fill_in 'Name', with: name
    select 'time', from: 'For'
  end

  def add_top_level_exercise(movement:, reps: nil, distance: nil)
    within '.workout-builder-toolbar' do
      click_on 'Add Exercise'
    end

    exercise = all('#workout-parts > .fields > .exercise').last
    fill_exercise(exercise, movement:, reps:, distance:)
  end

  def add_segment(name: nil)
    within '.workout-builder-toolbar' do
      click_on 'Add Segment'
    end

    segment = all('#workout-parts > .fields > .nested-fields').last
    within segment do
      fill_in 'Name', with: name if name.present?
    end
    segment
  end

  def add_segment_exercise(movement:, reps: nil, distance: nil)
    click_on 'Add Exercise'
    fill_exercise(all('.exercise').last, movement:, reps:, distance:)
  end

  def fill_exercise(exercise, movement:, reps: nil, distance: nil)
    within exercise do
      find('.ts-control input').set(movement)
      find('.ts-dropdown .option', exact_text: movement).click
      fill_in 'Reps', with: reps if reps.present?
      fill_in 'Distance', with: distance, exact: true if distance.present?
      select 'meter', from: 'Distance unit' if distance.present?
      done_button = find_button('Done')
      scroll_to done_button, align: :center
      done_button.click
    end
  end

  def reorder_sortable_list(root, from:, to:)
    root = find(root) if root.is_a?(String)

    page.execute_script(<<~JS, root, from, to)
      const root = arguments[0]
      const fromIndex = arguments[1]
      const toIndex = arguments[2]
      const container = root.querySelector('[data-sortable-list-target="container"]')
      const items = Array.from(container.querySelectorAll(':scope > .nested-fields:not([hidden])'))
      container.insertBefore(items[fromIndex], items[toIndex])
      window.Stimulus.getControllerForElementAndIdentifier(root, 'sortable-list').refresh()
    JS
  end

  def assert_text_order(*texts)
    list_text = find('ul.list-unstyled.mb-3').text
    indexes = texts.map { |text| list_text.index(text) }

    assert indexes.all?, "expected #{list_text.inspect} to include #{texts.inspect}"
    assert_equal indexes.sort, indexes, "expected #{texts.inspect} to appear in order within #{list_text.inspect}"
  end
end

class WorkoutDragOrderingTest < ApplicationSystemTestCase
  include WorkoutDragOrderingSystemHelpers
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'creates a workout with reordered top-level exercises' do
    visit new_workout_url

    fill_required_workout_fields('Dragged Exercises')
    add_top_level_exercise(movement: 'Pull Up', reps: '10')
    add_top_level_exercise(movement: 'Run', distance: '400')

    reorder_sortable_list('#workout-parts', from: 1, to: 0)
    click_on 'Create Workout'

    assert_current_path %r{/workouts/\d+}
    assert_text_order '400 meter Run', '10 Pull Ups'
  end

  test 'creates a workout with reordered mixed top-level parts' do
    visit new_workout_url

    fill_required_workout_fields('Dragged Mixed Parts')
    add_top_level_exercise(movement: 'Pull Up', reps: '10')
    add_top_level_exercise(movement: 'Run', distance: '400')
    add_segment(name: 'Middle')

    reorder_sortable_list('#workout-parts', from: 2, to: 1)
    click_on 'Create Workout'

    assert_current_path %r{/workouts/\d+}
    assert_text_order '10 Pull Ups', 'Then, Middle:', '400 meter Run'
  end

  test 'creates a workout with reordered segment exercises' do
    visit new_workout_url

    fill_required_workout_fields('Dragged Segment Exercises')
    segment = add_segment
    within segment do
      add_segment_exercise(movement: 'Pull Up', reps: '10')
      add_segment_exercise(movement: 'Run', distance: '400')
    end

    reorder_sortable_list(all('#segmented_exercises').last, from: 1, to: 0)
    click_on 'Create Workout'

    assert_current_path %r{/workouts/\d+}
    assert_text_order 'Segment:', '400 meter Run', '10 Pull Ups'
  end

  test 'edits a workout with reordered existing parts' do
    visit edit_workout_url(workouts(:murph))

    reorder_sortable_list('#workout-parts', from: 1, to: 0)
    click_on 'Update Workout'

    assert_current_path workout_path(workouts(:murph))
    assert_text_order '100 Pull Ups', '1600 distance Run'
  end

  test 'edits a tabata workout with rest moved before the first segment' do
    workout = create_tabata_workout
    visit edit_workout_url(workout)

    reorder_sortable_list('#workout-parts', from: 1, to: 0)
    click_on 'Update Workout'

    assert_current_path workout_path(workout)
    assert_text_order '1:00 Rest', '8 rounds of'
  end

  test 'normalizes positions after reorder and delete' do
    visit new_workout_url

    fill_required_workout_fields('Dragged Deleted Exercise')
    add_top_level_exercise(movement: 'Pull Up', reps: '10')
    add_top_level_exercise(movement: 'Push Up', reps: '20')
    add_top_level_exercise(movement: 'Run', distance: '400')

    reorder_sortable_list('#workout-parts', from: 2, to: 0)
    within all('#workout-parts > .fields > .exercise').last do
      find('[aria-label="Delete exercise"]').click
    end

    positions = all('#workout-parts > .fields > .exercise:not([hidden]) input[name$="[position]"]',
                    visible: false).map(&:value)
    assert_equal %w[1 2], positions

    click_on 'Create Workout'

    assert_current_path %r{/workouts/\d+}
    assert_text_order '400 meter Run', '10 Pull Ups'
    assert_no_text '20 Push Ups'
  end

  private

  def create_tabata_workout
    rest = Movement.find_or_create_by!(name: 'Rest')
    workout = Workout.create!(name: 'CFJ-181226 Reorder Test', score_type: :rep)
    first_segment = workout.segments.create!(rounds: 8, position: 1)
    first_segment.exercises.create!(workout:, movement: movements(:hspu), position: 1, duration_seconds: 20)
    first_segment.exercises.create!(workout:, movement: rest, position: 2, duration_seconds: 10)
    workout.exercises.create!(movement: rest, position: 2, duration_seconds: 60)
    second_segment = workout.segments.create!(rounds: 8, position: 3)
    second_segment.exercises.create!(workout:, movement: movements(:pistol), position: 1, duration_seconds: 20)
    workout
  end
end
