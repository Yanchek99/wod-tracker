require 'test_helper'

class StimulusClaimsTest < ActiveSupport::TestCase
  test 'proposes a finish window' do
    claims = StimulusClaims.propose('Some of you may even finish under 9 minutes.', [])

    assert_equal [nil, 540], claims['finish_seconds']
  end

  test 'a per-movement time is not a finish window' do
    assert_nil StimulusClaims.propose('Complete the burpees in under 1 minute.', ['Burpee'])['finish_seconds']
  end

  test 'proposes a finish range in minutes' do
    claims = StimulusClaims.propose('Aim to finish between 10-15 minutes, with some of you pushing closer to 8.', [])

    assert_equal [600, 900], claims['finish_seconds']
  end

  test 'proposes a round time' do
    assert_equal [120, 180], StimulusClaims.propose('Aim for two- to three-minute rounds.', [])['round_seconds']
  end

  test 'proposes loading and a sets guide for a named movement' do
    text = 'Choose a moderate overhead squat load that lets you finish your reps in 3 sets or less.'

    claims = StimulusClaims.propose(text, ['Overhead Squat', 'Strict Pull-up'])

    assert_equal({ 'Overhead Squat' => 'moderate' }, claims['loading'])
    assert_equal({ 'Overhead Squat' => 3 }, claims['sets_max'])
  end

  test 'proposes a working-set percentage' do
    claims = StimulusClaims.propose('All 5 push jerk sets should be at or near 75% of your 1-rep max.', [])

    assert_equal [75, 75], claims['percent_1rm']
  end

  test 'proposes a target round count' do
    assert_equal [3, 5], StimulusClaims.propose('Aim for at least 3-5 rounds.', [])['rounds']
  end

  test 'proposes a per-movement time ceiling' do
    claims = StimulusClaims.propose('Aim to complete the double-unders in 1:30 or faster.', ['Double-under'])

    assert_equal({ 'Double-under' => 90 }, claims['duration_max'])
  end

  test 'loads the checked-in claims file' do
    claims = StimulusClaims.load

    assert_operator claims.size, :>=, 20
    assert(claims.all? { |claim| claim.workout_name.present? && claim.claims.is_a?(Hash) })
  end
end
