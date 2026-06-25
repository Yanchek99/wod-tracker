require 'test_helper'

class MeasurementTest < ActiveSupport::TestCase
  test 'defaults to a single implement' do
    metric = Metric.new(measurement: :lb, value: 50)

    assert_equal 1, metric.implement_count
    assert_not metric.multiple_implements?
  end

  test 'treats a count above one as multiple implements' do
    metric = Metric.new(measurement: :lb, value: 50, implement_count: 2)

    assert_equal 2, metric.implement_count
    assert_predicate metric, :multiple_implements?
  end
end
