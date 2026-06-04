require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  test 'allows a single unisex value' do
    metric = build_metric(value: 95)

    assert metric.valid?
  end

  test 'allows paired female and male values' do
    metric = build_metric(female_value: 65, male_value: 95)

    assert metric.valid?
  end

  test 'allows blank values' do
    metric = build_metric

    assert metric.valid?
  end

  test 'rejects mixed unisex and sex-specific values' do
    metric = build_metric(value: 95, female_value: 65, male_value: 95)

    assert_not metric.valid?
    assert_includes metric.errors[:value], 'cannot be set with male and female values'
  end

  test 'rejects a female value without a male value' do
    metric = build_metric(female_value: 65)

    assert_not metric.valid?
    assert_includes metric.errors[:base], 'male and female values must both be set'
  end

  test 'rejects a male value without a female value' do
    metric = build_metric(male_value: 95)

    assert_not metric.valid?
    assert_includes metric.errors[:base], 'male and female values must both be set'
  end

  private

  def build_metric(attributes = {})
    exercises(:fran_pullup).metrics.build({ measurement: :lb }.merge(attributes))
  end
end
