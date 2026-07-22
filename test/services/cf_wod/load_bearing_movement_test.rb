require 'test_helper'

module CfWod
  class LoadBearingMovementTest < ActiveSupport::TestCase
    LOAD_BEARING_CATALOG_MOVEMENTS = [
      'Back Squat', 'Barbell Back-rack Step-up', 'Barbell Carry', 'Barbell Front-rack Lunge',
      'Barbell Step-up', 'Bench Press', 'Bent-over Row', 'Clean', 'Clean and Jerk', 'Clean and Push Jerk',
      'Clean Squat',
      'Deadlift', 'Stiff-legged Deadlift', 'Sumo Deadlift', 'Sumo Deadlift High Pull',
      'Front Squat', 'Good Morning', 'Ground to Overhead',
      'Hang Clean', 'Hang Clean and Push Jerk', 'Hang Power Clean', 'Hang Power Snatch', 'Hang Snatch',
      'Hang Squat Clean',
      'Jerk', 'Muscle Snatch', 'Overhead Squat', 'Overhead Walk', 'Overhead Walking Lunge',
      'Power Clean', 'Power Clean and Split Jerk', 'Power Snatch', 'Push Jerk', 'Push Press',
      'Shoulder Press', 'Shoulder to Overhead', 'Snatch', 'Snatch Balance', 'Sots Press',
      'Split Clean', 'Split Jerk', 'Split Snatch', 'Squat Clean', 'Squat Clean Thruster', 'Squat Snatch',
      'Tempo Jerk', 'Thruster', 'Zercher Squat'
    ].freeze

    test 'recognizes seeded catalog load-bearing movements by name' do
      LOAD_BEARING_CATALOG_MOVEMENTS.each do |name|
        assert LoadBearingMovement.call(Movement.new(name: name)), "#{name} should be load-bearing"
      end
    end

    test 'does not infer implement or bodyweight movements by name alone' do
      [
        'Dumbbell Clean',
        'Kettlebell Clean and Jerk',
        'Lateral Over Barbell Burpee',
        'Medicine-ball Clean',
        'Pull-up',
        'Sandbag Clean'
      ].each do |name|
        assert_not LoadBearingMovement.call(Movement.new(name: name)), "#{name} should not be load-bearing by name"
      end
    end

    test 'uses scraper raw-text rack and overhead cues as a fallback' do
      movement = Movement.new(name: 'Walking Lunge')

      assert LoadBearingMovement.call(movement, raw_text: '100-ft. front-rack walking lunge')
      assert LoadBearingMovement.call(movement, raw_text: '50-ft. back-rack walking lunge')
      assert LoadBearingMovement.call(movement, raw_text: '25-ft. overhead walking lunge')
    end
  end
end
