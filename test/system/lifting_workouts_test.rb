require 'application_system_test_case'

class LiftingWorkoutsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'logs set-based lifting workouts as one recording per set' do
    visit workout_url(workouts(:back_squat_5x5))

    click_on 'Log'

    assert_selector '#log_score_value:disabled'
    assert_field 'log_score_value', with: '', disabled: true
    assert_text 'Score will be calculated from the heaviest successful load.'
    assert_selector '.card.mb-3', count: 5
    movement_logs = all('.card.mb-3')
    movement_logs.each do |movement_log|
      values = movement_log.all('.recording-value').map(&:value)

      assert_equal ['5', ''], values # [reps, load] -- only prescribed dimensions are shown by default
    end

    [95, 115, 135, 145, 155].each.with_index do |load, index|
      movement_logs[index].all('.recording-value')[1].set(load)
    end
    assert_field 'log_score_value', with: '155', disabled: true

    movement_logs[4].first('.recording-value').set(2)
    assert_field 'log_score_value', with: '145', disabled: true

    click_on 'Save'

    assert_current_path %r{/logs/\d+}
    assert_text '145 lbs'
  end

  test 'calculates lifting score from each exercise prescribed reps' do
    workout = Workout.create!(name: 'Mixed Heavy Day', score_type: :weight)
    segment = workout.segments.create!(position: 1, rounds: 1)
    segment.exercises.create!(movement: movements(:back_squat), position: 1, reps: 5, load: 0)
    segment.exercises.create!(movement: movements(:deadlift), position: 2, reps: 3, load: 0)

    visit workout_url(workout)

    click_on 'Log'

    movement_logs = all('.card.mb-3')
    assert_equal(
      [['5', ''], ['3', '']],
      movement_logs.map { |movement_log| movement_log.all('.recording-value').map(&:value) }
    )

    movement_logs[0].all('.recording-value')[1].set(225)
    movement_logs[1].all('.recording-value')[1].set(315)
    assert_field 'log_score_value', with: '315', disabled: true

    movement_logs[1].first('.recording-value').set(2)
    assert_field 'log_score_value', with: '225', disabled: true

    click_on 'Save'

    assert_current_path %r{/logs/\d+}
    assert_text '225 lbs'
  end
end
