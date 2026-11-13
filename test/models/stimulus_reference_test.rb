require 'test_helper'

class StimulusReferenceTest < ActiveSupport::TestCase
  setup do
    @reference = StimulusReference.current
  end

  test 'loads the calculation constants' do
    assert_equal 10, @reference.constant(:transition_seconds)
    assert_equal 2, @reference.constant(:slow_factor)
    assert_in_delta 0.85, @reference.constant(:heavy_boundary)
    assert_in_delta 0.7, @reference.constant(:female_reference_factor)
  end

  test 'finds a loaded movement entry with paces per load class' do
    thruster = @reference.movement('Thruster')

    assert_equal 'barbell', thruster.lift_class
    assert_operator thruster.reference_load, :>, 0
    assert_in_delta 2.5, thruster.seconds_per('rep', 'moderate')
  end

  test 'a monostructural entry has a pace per unit regardless of load' do
    assert_in_delta 0.225, @reference.movement('Run').seconds_per('meter', nil)
    assert_nil @reference.movement('Run').seconds_per('rep', nil)
  end

  test 'a loaded pace needs a load class' do
    assert_nil @reference.movement('Thruster').seconds_per('rep', nil)
  end

  test 'an unknown movement is nil' do
    assert_nil @reference.movement('Unicycle Juggle')
  end

  test 'light boundary per lift class' do
    assert_in_delta 0.45, @reference.light_boundary('olympic')
    assert_in_delta 0.50, @reference.light_boundary('barbell')
  end

  test 'every movement entry has paces and a source' do
    @reference.movements.each_value do |entry|
      assert entry.paces.present?, "#{entry.name} has no paces"
      assert entry.source.present?, "#{entry.name} has no source"
    end
  end

  test 'every movement name exists in the seeds' do
    seeded = Rails.root.join('db/seeds.rb').read.scan(/Movement\.find_or_initialize_by\(name: '([^']+)'\)/).flatten

    assert_empty @reference.movements.keys - seeded
  end
end
