require 'test_helper'

class LoadEquivalenceTest < ActiveSupport::TestCase
  test 'pounds are canonical and pass through' do
    assert_equal 95, LoadEquivalence.to_lb(95, :lb)
    assert_equal 95, LoadEquivalence.to_lb(95, '')
    assert_equal 95, LoadEquivalence.to_lb(95, nil)
  end

  test 'source-confirmed kg pairs normalize to their published lb value' do
    assert_equal 95, LoadEquivalence.to_lb(43, :kg)
    assert_equal 135, LoadEquivalence.to_lb(61, :kg)
    assert_equal 315, LoadEquivalence.to_lb(142, :kg)
  end

  test 'kg rounding variants map to one canonical lb value' do
    assert_equal 65, LoadEquivalence.to_lb(29, :kg)
    assert_equal 65, LoadEquivalence.to_lb(29.5, :kg)
  end

  test 'standard kettlebells normalize identically from pood and kg' do
    assert_equal 35, LoadEquivalence.to_lb(1, :pood)
    assert_equal 35, LoadEquivalence.to_lb(16, :kg)
    assert_equal 53, LoadEquivalence.to_lb(1.5, :pood)
    assert_equal 53, LoadEquivalence.to_lb(24, :kg)
    assert_equal 70, LoadEquivalence.to_lb(2, :pood)
    assert_equal 70, LoadEquivalence.to_lb(32, :kg)
  end

  test 'non-standard kg falls back to nearest 5 lb' do
    assert_equal 110, LoadEquivalence.to_lb(50, :kg) # 50 * 2.20462 = 110.2 -> 110
  end

  test 'nil value returns nil' do
    assert_nil LoadEquivalence.to_lb(nil, :kg)
  end

  test 'unknown unit raises' do
    assert_raises(ArgumentError) { LoadEquivalence.to_lb(10, :stone) }
  end

  test 'lb_to_kg returns the published kg label where known' do
    assert_equal 43, LoadEquivalence.lb_to_kg(95)
    assert_equal 29, LoadEquivalence.lb_to_kg(65) # most recent published label
  end
end
