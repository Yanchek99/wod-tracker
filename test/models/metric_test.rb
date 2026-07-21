require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  test 'multiplies a rep placeholder by the interval total, same as calorie' do
    segment = Segment.new(interval_scheme: '21-15-9')

    rep_metric = Metric.new(measurement: 'rep', value: 1)
    calorie_metric = Metric.new(measurement: 'calorie', value: 1)

    assert_equal 45, rep_metric.calculated_value(segment)
    assert_equal 45, calorie_metric.calculated_value(segment)
  end

  test 'returns the literal value for rep and calorie outside an interval scheme' do
    segment = Segment.new

    assert_equal 20, Metric.new(measurement: 'rep', value: 20).calculated_value(segment)
    assert_equal 20, Metric.new(measurement: 'calorie', value: 20).calculated_value(segment)
  end

  test 'other measurements are never interval-multiplied' do
    segment = Segment.new(interval_scheme: '21-15-9')

    assert_equal 1, Metric.new(measurement: 'lb', value: 1).calculated_value(segment)
  end
end
