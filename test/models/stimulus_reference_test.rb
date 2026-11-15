require 'test_helper'

class StimulusReferenceTest < ActiveSupport::TestCase
  setup do
    @reference = StimulusReference.current
  end

  test 'loads the calculation constants' do
    assert_equal 10, @reference.constant(:transition_seconds)
    assert_in_delta 1.6, @reference.constant(:slow_factor)
    assert_in_delta 0.85, @reference.constant(:heavy_boundary)
  end

  test 'a barbell lift takes its lift family from its primary function' do
    thruster = @reference.profile(movements(:thruster))

    assert_equal ['lift:squat', 'barbell'], [thruster.bucket, thruster.basis]
    assert_in_delta 3.0, thruster.seconds_per('rep', 'moderate')
    deadlift = Movement.create!(name: 'Calc Deadlift', family: :weightlifting, equipment: :barbell,
                                function_roles: { primary: :hinge })

    assert_equal 'lift:hinge', @reference.profile(deadlift).bucket
  end

  test 'snatch, clean and jerk lifts go by name before function' do
    assert_equal 'lift:clean', @reference.profile(movements(:clean_and_jerk)).bucket
    assert_equal 'lift:snatch', @reference.profile(movements(:power_snatch)).bucket
  end

  test 'an implement compares against its typical load' do
    swing = Movement.new(name: 'Kettlebell Swing', family: :weightlifting, equipment: :kettlebell)
    profile = @reference.profile(swing)

    assert_equal ['implement:kettlebell', 'implement', 53], [profile.bucket, profile.basis, profile.reference_load]
  end

  test 'a wall-ball target and a box have typical heights in inches' do
    wall_ball = Movement.new(name: 'Wall-ball Shot', family: :weightlifting, equipment: :medicine_ball)
    box_jump = Movement.new(name: 'Box Jump', family: :gymnastics, equipment: :box, skill_level: :basic)

    assert_in_delta 120, @reference.profile(wall_ball).typical_height
    assert_in_delta 24, @reference.profile(box_jump).typical_height
  end

  test 'unloaded gymnastics paces by skill level, with a burpee component added' do
    burpee_pull_up = Movement.new(name: 'Burpee Pull-up', family: :gymnastics, skill_level: :intermediate)

    assert_in_delta 2.0, @reference.profile(movements(:pullup)).seconds_per('rep', nil)
    assert_in_delta 4.0, @reference.profile(burpee_pull_up).seconds_per('rep', nil)
  end

  test 'a monostructural movement has its own pace, a foot read as a meter' do
    run = @reference.profile(movements(:run))

    assert_in_delta 0.225, run.seconds_per('meter', nil)
    assert_in_delta 0.225 * 0.3048, run.seconds_per('foot', nil)
    assert_nil run.seconds_per('rep', nil)
  end

  test 'an override replaces a skill-level pace' do
    rope_climb = Movement.new(name: 'Rope Climb', family: :gymnastics, equipment: :rope, skill_level: :intermediate)

    assert_in_delta 15.0, @reference.profile(rope_climb).seconds_per('rep', nil)
  end

  test 'a loaded pace needs a load class' do
    assert_nil @reference.profile(movements(:thruster)).seconds_per('rep', nil)
  end

  test 'a movement with no family has no profile' do
    assert_nil @reference.profile(movements(:burpee))
  end

  test 'every bucket section carries a source' do
    %w[lift_families implements monostructural overrides].each do |section|
      @reference.section(section).each { |name, attrs| assert attrs['source'].present?, "#{section}/#{name} has no source" }
    end
  end
end
