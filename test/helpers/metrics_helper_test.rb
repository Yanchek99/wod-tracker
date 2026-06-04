require 'test_helper'

class MetricsHelperTest < ActionView::TestCase
  test 'renders partial amrap scores as rounds plus reps and total reps' do
    assert_equal '8 + 2 (202 reps)', log_score_msg(logs(:matt_amrap))
  end

  test 'renders exact amrap scores as completed rounds and total reps' do
    log = logs(:matt_amrap)
    log.metric.value = 200

    assert_equal '8 rounds (200 reps)', log_score_msg(log)
  end

  test 'renders unknown amrap round size as total reps' do
    log = workouts(:amrap_unknown_distance).logs.build(reps_per_round: nil)
    log.build_metric(measurement: :rep, value: 202)

    assert_equal '202 reps', log_score_msg(log)
  end

  test 'renders paired female and male load values' do
    metric = Metric.new(measurement: :lb, female_value: 65, male_value: 95)

    assert_equal '♀65-lb / ♂95-lb', metric_unit_msg(metric)
  end

  test 'renders paired female and male height values' do
    metric = Metric.new(measurement: :inch, female_value: 20, male_value: 24)

    assert_equal '♀20-inch / ♂24-inch', metric_unit_msg(metric)
  end
end
