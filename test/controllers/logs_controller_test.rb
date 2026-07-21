require 'test_helper'

class LogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @workout = workouts(:fran)
    sign_in users(:mathew)
  end

  test 'should create log with direct movement recordings' do
    assert_difference(['Log.count', 'MovementLog.count'], 1) do
      post workout_logs_url(@workout), params: { log: {
        score_type: :time,
        score_value: '5:30',
        movement_logs_attributes: {
          '0' => {
            movement_id: movements(:pullup).id,
            reps: 45
          }
        }
      } }
    end

    assert_redirected_to log_url(Log.last)
    assert_equal 'time', Log.last.score_type
    assert_equal 330, Log.last.score_value
    movement_log = Log.last.movement_logs.first
    assert_equal movements(:pullup), movement_log.movement
    assert_equal 45, movement_log.reps
  end

  test 'should not show another user log' do
    get log_url(logs(:brooke_fran))

    assert_response :not_found
  end

  test 'should not edit another user log' do
    get edit_workout_log_url(logs(:brooke_fran).workout, logs(:brooke_fran))

    assert_response :not_found
  end

  test 'should not update another user log' do
    patch workout_log_url(logs(:brooke_fran).workout, logs(:brooke_fran)), params: {
      log: { score_type: :time, score_value: '4:59' }
    }

    assert_response :not_found
  end

  test 'should not destroy another user log' do
    assert_no_difference('Log.count') do
      delete log_url(logs(:brooke_fran))
    end

    assert_response :not_found
  end

  test 'creates amrap log from rounds plus reps score' do
    assert_difference('Log.count') do
      post workout_logs_url(workouts(:amrap_couplet)), params: { log: {
        score_type: :rep, score_value: '20+2'
      } }
    end

    assert_redirected_to log_url(Log.last)
    assert_equal 502, Log.last.score_value
    assert_equal 25, Log.last.reps_per_round
  end

  test 'new log for fixed-rep round-scored amrap uses rep score input' do
    workout = workouts(:amrap_couplet)
    workout.update!(score_type: :round)

    get new_workout_log_url(workout)

    assert_response :success
    assert_select 'input[name="log[score_type]"][value="rep"]'
  end

  test 'new log form only shows recording fields the workout prescribes' do
    get new_workout_log_url(workouts(:fran))

    assert_response :success

    # Fran: Thrusters (reps + load) then Pullups (reps only) — see test/fixtures/exercises.yml
    cards = css_select('.card.mb-3')
    thruster_card = cards[0]
    pullup_card = cards[1]

    assert_select thruster_card, "input[name$='[reps]']", 1
    assert_select thruster_card, "input[name$='[reps]']" do |elements|
      assert_not elements.first.ancestors('[hidden]').any?
    end
    assert_select thruster_card, "input[name$='[load]']" do |elements|
      assert_not elements.first.ancestors('[hidden]').any?
    end
    assert_select thruster_card, "input[name$='[duration_seconds]']" do |elements|
      assert elements.first.ancestors('[hidden]').any?
    end
    assert_select thruster_card, "input[name$='[calories]']" do |elements|
      assert elements.first.ancestors('[hidden]').any?
    end

    assert_select pullup_card, "input[name$='[reps]']" do |elements|
      assert_not elements.first.ancestors('[hidden]').any?
    end
    assert_select pullup_card, "input[name$='[load]']" do |elements|
      assert elements.first.ancestors('[hidden]').any?
    end
  end

  test 'recording form exposes every performance dimension so scaled movements can be logged' do
    # Murph only prescribes reps and distance, but the form must still let an athlete record an
    # off-prescription dimension (e.g. calories from a scaled row) on any movement.
    get new_workout_log_url(workouts(:murph))

    %w[reps duration_seconds load distance calories].each do |dimension|
      assert_select "input[name*='[#{dimension}]']", { minimum: 1 }, "expected a #{dimension} recording input"
    end
  end

  test 'creates fixed-rep amrap log from stale round score submission' do
    workout = workouts(:amrap_couplet)
    workout.update!(score_type: :round)

    assert_difference('Log.count') do
      post workout_logs_url(workout), params: { log: {
        score_type: :round, score_value: '20+2'
      } }
    end

    assert_redirected_to log_url(Log.last)
    assert_equal 'rep', Log.last.score_type
    assert_equal 502, Log.last.score_value
    assert_equal 25, Log.last.reps_per_round
  end

  test 'creates amrap log from raw total reps' do
    assert_difference('Log.count') do
      post workout_logs_url(workouts(:amrap_couplet)), params: { log: {
        score_type: :rep, score_value: '202'
      } }
    end

    assert_equal 202, Log.last.score_value
    assert_equal 25, Log.last.reps_per_round
  end

  test 'does not create amrap log from invalid rounds plus reps score' do
    assert_no_difference('Log.count') do
      post workout_logs_url(workouts(:amrap_couplet)), params: { log: {
        score_type: :rep, score_value: '2.5'
      } }
    end

    assert_response :unprocessable_content
  end
end
