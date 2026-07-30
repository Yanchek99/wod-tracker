require 'test_helper'

class LoadBearingMovementTest < ActiveSupport::TestCase
  test 'recognizes catalog load-bearing movements by name' do
    LoadBearingMovement::LOAD_BEARING_MOVEMENTS.each do |name|
      assert LoadBearingMovement.call(Movement.new(name: name)), "#{name} should be load-bearing"
    end
  end

  test 'keeps every catalog name aligned with db seeds' do
    missing = LoadBearingMovement::LOAD_BEARING_MOVEMENTS - seeded_movement_names

    assert_empty missing
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

  private

  def seeded_movement_names
    Rails.root.join('db/seeds.rb').read.scan(/Movement\.find_or_create_by\(name: '([^']+)'\)/).flatten
  end
end
