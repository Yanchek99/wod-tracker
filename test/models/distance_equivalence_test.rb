require 'test_helper'

class DistanceEquivalenceTest < ActiveSupport::TestCase
  test 'meters are canonical and pass through' do
    assert_equal 400, DistanceEquivalence.to_meters(400, :meter)
    assert_equal 400, DistanceEquivalence.to_meters(400, '')
    assert_equal 400, DistanceEquivalence.to_meters(400, nil)
  end

  test 'a mile uses the published 1600 m convention' do
    assert_equal 1600, DistanceEquivalence.to_meters(1, :mile)
  end

  test 'kilometers convert to meters' do
    assert_equal 5000, DistanceEquivalence.to_meters(5, :km)
  end

  test 'nil value returns nil' do
    assert_nil DistanceEquivalence.to_meters(nil, :mile)
  end

  test 'unknown unit raises' do
    assert_raises(ArgumentError) { DistanceEquivalence.to_meters(10, :foot) }
  end
end
