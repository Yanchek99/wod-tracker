require 'test_helper'

class LogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @workout = workouts(:fran)
    sign_in users(:mathew)
  end

  test 'index shows only the current user logs' do
    get logs_url

    assert_response :success
    assert_select 'a[href=?]', workout_path(workouts(:murph))
    assert_select 'a[href=?]', workout_path(workouts(:amrap_couplet))
    assert_select 'a[href=?]', workout_path(workouts(:fran)), count: 0
  end

  test 'index orders history newest first' do
    logs(:matt_murph).update!(created_at: 2.days.ago)
    logs(:matt_amrap).update!(created_at: 1.day.ago)

    get logs_url

    assert_operator response.body.index(workout_path(workouts(:amrap_couplet))),
                    :<,
                    response.body.index(workout_path(workouts(:murph)))
  end

  test 'index row links to the log show page and shows the score' do
    get logs_url

    assert_select 'a[href=?]', log_path(logs(:matt_murph))
    assert_select 'a[href=?]', log_path(logs(:matt_amrap))
    assert_select '.fw-semibold', text: '01:00:00'
    assert_select '.fw-semibold', text: '8 + 2 (202 reps)'
  end

  test 'index shows an empty state when the user has no logs' do
    Log.where(user: users(:mathew)).destroy_all

    get logs_url

    assert_response :success
    assert_select 'p', text: 'No workouts logged yet.'
  end

  test 'nav links to the workout history' do
    get logs_url

    assert_select 'nav a[href=?]', logs_path, text: 'History'
  end

  test 'index page one renders a lazy frame chaining to the next page' do
    30.times do
      Log.create!(user: users(:mathew), workout: workouts(:murph), score_type: :time, score_value: 1200)
    end

    get logs_url

    assert_response :success
    assert_select 'turbo-frame#logs_page_1'
    assert_select 'turbo-frame#logs_page_2[loading="lazy"][src=?]', logs_path(page: 2)
  end

  test 'index last page renders no further lazy frame' do
    30.times do
      Log.create!(user: users(:mathew), workout: workouts(:murph), score_type: :time, score_value: 1200)
    end

    get logs_url(page: 2)

    assert_response :success
    assert_select 'turbo-frame#logs_page_2'
    assert_select 'turbo-frame[loading="lazy"]', count: 0
  end

  test 'index paginates same-timestamp logs in descending ID order' do
    timestamp = Time.zone.parse('2100-01-01 12:00:00')
    logs = Array.new(26) do
      Log.create!(user: users(:mathew), workout: workouts(:murph), score_type: :time, score_value: 1200,
                  created_at: timestamp)
    end

    get logs_url

    assert_response :success
    logs.last(25).reverse_each do |log|
      assert_select "a[href='#{log_path(log)}']"
    end
    assert_select "a[href='#{log_path(logs.first)}']", count: 0

    get logs_url(page: 2)

    assert_response :success
    assert_select "a[href='#{log_path(logs.first)}']"
  end

  test 'turbo frame request renders only the page frame without the heading' do
    get logs_url, headers: { 'Turbo-Frame' => 'logs_page_1' }

    assert_response :success
    assert_select 'h1', count: 0
    assert_select 'turbo-frame#logs_page_1'
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

  test 'creates log with a set breakdown' do
    assert_difference(['Log.count', 'MovementLog.count'], 1) do
      post workout_logs_url(@workout), params: { log: {
        score_type: :time,
        score_value: '5:30',
        movement_logs_attributes: {
          '0' => {
            movement_id: movements(:pullup).id,
            reps: 45,
            set_breakdown: %w[21 15 9]
          }
        }
      } }
    end

    assert_redirected_to log_url(Log.last)
    movement_log = Log.last.movement_logs.first
    assert_equal [21, 15, 9], movement_log.set_breakdown
  end

  test 'rejects a log whose set breakdown does not sum to reps' do
    assert_no_difference('Log.count') do
      post workout_logs_url(@workout), params: { log: {
        score_type: :time,
        score_value: '5:30',
        movement_logs_attributes: {
          '0' => {
            movement_id: movements(:pullup).id,
            reps: 45,
            set_breakdown: %w[21 15]
          }
        }
      } }
    end

    assert_response :unprocessable_content
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

  test 'new log form shows the set breakdown repeater when reps are not auto-populated' do
    get new_workout_log_url(workouts(:fran))

    assert_response :success

    # Fran: Thruster and Pullup both aggregate to 45 reps via the interval scheme, and neither
    # is auto-populated (multi-exercise workout) -- see test/fixtures/exercises.yml.
    thruster_card = css_select('.card.mb-3')[0]
    assert_select thruster_card, "[data-controller~='set-breakdown']" do |elements|
      assert_nil elements.first['hidden']
    end
    assert_select thruster_card, "input[name$='[set_breakdown][]']"
  end

  test 'new log form hides the set breakdown repeater for an auto-populated single-lift day' do
    get new_workout_log_url(workouts(:back_squat_5x5))

    assert_response :success
    card = css_select('.card.mb-3').first
    assert_select card, "[data-controller~='set-breakdown'][hidden]", 1
  end

  test 'failed submission redisplays the set breakdown repeater with the submitted values' do
    post workout_logs_url(workouts(:fran)), params: { log: {
      score_type: :time,
      score_value: '5:30',
      movement_logs_attributes: {
        '0' => {
          movement_id: movements(:thruster).id,
          reps: 45,
          set_breakdown: %w[21 15]
        }
      }
    } }

    assert_response :unprocessable_content
    thruster_card = css_select('.card.mb-3')[0]
    container = css_select(thruster_card, "[data-set-breakdown-target='container']").first
    values = css_select(container, "input[type='number']").pluck('value')
    assert_equal %w[21 15], values
  end

  test 'auto-populated set breakdown persists through the hidden repeater input on create' do
    assert_difference('MovementLog.count', 5) do
      post workout_logs_url(workouts(:back_squat_5x5)), params: { log: {
        score_type: :weight,
        movement_logs_attributes: {
          '0' => { movement_id: movements(:back_squat).id, reps: 5, load: 135, set_breakdown: ['5'] },
          '1' => { movement_id: movements(:back_squat).id, reps: 5, load: 145, set_breakdown: ['5'] },
          '2' => { movement_id: movements(:back_squat).id, reps: 5, load: 155, set_breakdown: ['5'] },
          '3' => { movement_id: movements(:back_squat).id, reps: 5, load: 165, set_breakdown: ['5'] },
          '4' => { movement_id: movements(:back_squat).id, reps: 5, load: 175, set_breakdown: ['5'] }
        }
      } }
    end

    Log.last.movement_logs.each { |ml| assert_equal [5], ml.set_breakdown }
  end

  test 'submitting a blank set breakdown entry does not crash' do
    post workout_logs_url(@workout), params: { log: {
      score_type: :time,
      score_value: '5:30',
      movement_logs_attributes: {
        '0' => {
          movement_id: movements(:pullup).id,
          reps: 21,
          set_breakdown: ['21', '']
        }
      }
    } }

    assert_response :redirect
    assert_equal [21], Log.last.movement_logs.first.set_breakdown
  end

  test 're-rendered new form falls back to showing all fields when a movement log has no matching exercise' do
    # Fran only prescribes 2 exercises. Simulates the workout gaining an exercise between the user
    # loading the form and submitting it, so the submitted movement log count no longer matches
    # exercises_for_log_recording -- the failed create re-renders with the mismatched submission.
    post workout_logs_url(@workout), params: { log: {
      score_value: '5:30',
      movement_logs_attributes: {
        '0' => { movement_id: movements(:thruster).id, reps: 1, load: 95 },
        '1' => { movement_id: movements(:pullup).id, reps: 1 },
        '2' => { movement_id: movements(:run).id, reps: 1, distance: 400 }
      }
    } }

    assert_response :unprocessable_content
    extra_card = css_select('.card.mb-3').last
    assert_select extra_card, "input[name$='[duration_seconds]']" do |elements|
      assert_not elements.first.ancestors('[hidden]').any?
    end
  end

  test 'implement-count field stays hidden by default when a load-capable movement has no prescribed load' do
    dumbbell_burpee = Movement.create!(name: 'Dumbbell Burpee')
    exercises(:fran_pullup).segment.exercises.create!(movement: dumbbell_burpee, position: 3, reps: 10)

    get new_workout_log_url(workouts(:fran))

    assert_response :success
    dumbbell_card = css_select('.card.mb-3').last
    assert_select dumbbell_card, "input[name$='[implement_count]']" do |elements|
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
