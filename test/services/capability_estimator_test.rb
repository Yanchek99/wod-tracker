require 'test_helper'

class CapabilityEstimatorTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: 'estimator@wod-tracker.com', password: 'password123', first_name: 'Est', last_name: 'Imator', weight: 150, sex: :female)
    @movement = movements(:pullup)
  end

  def stub_rule(*rows)
    Class.new do
      define_singleton_method(:call) { |_samples| rows }
    end
  end

  def unbroken_row(movement, reps: 8)
    { movement_id: movement.id, kind: :unbroken, reps:, sample_count: 1 }
  end

  test 'call writes heuristic rows returned by the rules' do
    CapabilityEstimator.call(@user, rules: [stub_rule(unbroken_row(@movement))])

    row = @user.athlete_capabilities.sole
    assert_equal 'unbroken', row.kind
    assert_equal 8, row.reps
    assert row.source_heuristic?
    assert_equal 'heuristic-v1', row.model_version
    assert_not_nil row.computed_at
  end

  test 'call is idempotent' do
    2.times { CapabilityEstimator.call(@user, rules: [stub_rule(unbroken_row(@movement))]) }

    assert_equal 1, @user.athlete_capabilities.count
  end

  test 'call deletes heuristic rows the rules no longer produce' do
    CapabilityEstimator.call(@user, rules: [stub_rule(unbroken_row(@movement))])
    CapabilityEstimator.call(@user, rules: [stub_rule])

    assert_equal 0, @user.athlete_capabilities.count
  end

  test 'call leaves learned rows and other users rows untouched' do
    learned = @user.athlete_capabilities.create!(movement: @movement, kind: :unbroken, reps: 12, source: :learned,
                                                 model_version: 'x', computed_at: Time.current)
    other_count = users(:brooke).athlete_capabilities.source_heuristic.count

    CapabilityEstimator.call(@user, rules: [stub_rule])

    assert AthleteCapability.exists?(learned.id)
    assert_equal other_count, users(:brooke).athlete_capabilities.source_heuristic.count
  end

  test 'a user with no logs ends with no heuristic rows' do
    CapabilityEstimator.call(@user, rules: [])

    assert_equal 0, @user.athlete_capabilities.count
  end

  test 'an invalid row is skipped without blocking the others or failing the recompute' do
    invalid = { movement_id: movements(:run).id, kind: :unbroken, reps: 0 }

    CapabilityEstimator.call(@user, rules: [stub_rule(invalid, unbroken_row(@movement))])

    assert_equal [@movement.id], @user.athlete_capabilities.pluck(:movement_id)
  end

  test 'building samples does not query once per workout' do
    log_on = ->(workout) { Log.create!(user: @user, workout:, score_type: :time).tap { |log| log.movement_logs.create!(movement: @movement, reps: 1) } }
    log_on.call(workouts(:fran))
    one_workout = count_queries { CapabilityEstimator.samples_for(@user) }

    log_on.call(workouts(:murph))
    log_on.call(workouts(:amrap_couplet))
    assert_equal(one_workout, count_queries { CapabilityEstimator.samples_for(@user) })
  end

  def count_queries(&)
    count = 0
    counter = ->(*, payload) { count += 1 unless %w[SCHEMA TRANSACTION].include?(payload[:name]) || payload[:cached] }
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &)
    count
  end
end
