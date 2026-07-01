require 'test_helper'

class MetricsHelperTest < ActionView::TestCase
  test 'renders partial amrap scores as rounds plus reps and total reps' do
    assert_equal '8 + 2 (202 reps)', log_score_msg(logs(:matt_amrap))
  end

  test 'renders exact amrap scores as completed rounds and total reps' do
    log = logs(:matt_amrap)
    log.score_value = 200

    assert_equal '8 rounds (200 reps)', log_score_msg(log)
  end

  test 'renders unknown amrap round size as total reps' do
    log = workouts(:amrap_unknown_distance).logs.build(score_type: :rep, score_value: 202, reps_per_round: nil)

    assert_equal '202 reps', log_score_msg(log)
  end

  test 'renders paired female and male load values' do
    metric = Metric.new(measurement: :lb, female_value: 65, male_value: 95)

    assert_equal '♀65lb / ♂95lb', metric_unit_msg(metric)
  end

  test 'prefixes multi-implement load with the implement count' do
    metric = Metric.new(measurement: :lb, value: 50, implement_count: 2)

    assert_equal '2×50 lbs', metric_unit_msg(metric)
  end

  test 'prefixes multi-implement sex-specific load with the implement count' do
    metric = Metric.new(measurement: :lb, female_value: 35, male_value: 50, implement_count: 2)

    assert_equal '2×♀35lb / ♂50lb', metric_unit_msg(metric)
  end

  test 'does not prefix single-implement load' do
    metric = Metric.new(measurement: :lb, value: 50, implement_count: 1)

    assert_equal '50 lbs', metric_unit_msg(metric)
  end

  test 'renders loads in kilograms for a metric athlete' do
    Current.user = users(:brooke).tap { |user| user.unit_system = :metric }

    assert_equal '43 kgs', metric_unit_msg(Metric.new(measurement: :lb, value: 95))
    assert_equal '♀29kg / ♂43kg', metric_unit_msg(Metric.new(measurement: :lb, female_value: 65, male_value: 95))
  ensure
    Current.user = nil
  end

  test 'renders paired female and male height values' do
    metric = Metric.new(measurement: :inch, female_value: 20, male_value: 24)

    assert_equal '♀20-inch / ♂24-inch', metric_unit_msg(metric)
  end
end
