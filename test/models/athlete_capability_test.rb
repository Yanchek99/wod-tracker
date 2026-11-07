require 'test_helper'

class AthleteCapabilityTest < ActiveSupport::TestCase
  test 'for returns only that user\'s rows for that movement' do
    assert_equal [athlete_capabilities(:brooke_run_mile_timed)],
                 AthleteCapability.for(users(:brooke), movements(:run)).to_a
  end

  test 'destroying a user removes their capabilities' do
    user = users(:brooke)

    assert_difference 'AthleteCapability.count', -user.athlete_capabilities.count do
      user.destroy
    end
  end

  test 'destroying a movement removes its capabilities' do
    movement = movements(:run)

    assert_difference 'AthleteCapability.count', -movement.athlete_capabilities.count do
      movement.destroy
    end
  end

  test 'rejects a duplicate max_effort for the same user, movement and source' do
    build_row(kind: :max_effort, load: 185).save!(validate: false)

    assert_raises(ActiveRecord::RecordNotUnique) do
      build_row(kind: :max_effort, load: 200).save!(validate: false)
    end
  end

  test 'allows unbroken rows at different loads' do
    build_row(kind: :unbroken, reps: 10, load: 95).save!(validate: false)

    assert_nothing_raised { build_row(kind: :unbroken, reps: 5, load: 135).save!(validate: false) }
  end

  test 'rejects duplicate bodyweight unbroken rows' do
    build_row(kind: :unbroken, reps: 10).save!(validate: false)

    assert_raises(ActiveRecord::RecordNotUnique) do
      build_row(kind: :unbroken, reps: 12).save!(validate: false)
    end
  end

  test 'allows timed rows at different distances' do
    build_row(kind: :timed, distance: 400, distance_unit: :meter, duration_seconds: 90).save!(validate: false)

    assert_nothing_raised do
      build_row(kind: :timed, distance: 1609, distance_unit: :meter, duration_seconds: 302).save!(validate: false)
    end
  end

  test 'rejects a timed row for an existing setting with a different duration' do
    build_row(kind: :timed, distance: 1609, distance_unit: :meter, duration_seconds: 302).save!(validate: false)

    assert_raises(ActiveRecord::RecordNotUnique) do
      build_row(kind: :timed, distance: 1609, distance_unit: :meter, duration_seconds: 310).save!(validate: false)
    end
  end

  test 'allows timed rows with reps as the setting and distance as height' do
    build_row(kind: :timed, reps: 50, distance: 24, distance_unit: :inch, duration_seconds: 130).save!(validate: false)

    assert_nothing_raised do
      build_row(kind: :timed, reps: 50, distance: 30, distance_unit: :inch, duration_seconds: 150)
        .save!(validate: false)
    end
  end

  test 'rejects duplicate cannot_do rows' do
    build_row(kind: :cannot_do).save!(validate: false)

    assert_raises(ActiveRecord::RecordNotUnique) { build_row(kind: :cannot_do).save!(validate: false) }
  end

  test 'allows heuristic and learned rows for the same point' do
    build_row(kind: :max_effort, load: 185, source: :heuristic).save!(validate: false)

    assert_nothing_raised { build_row(kind: :max_effort, load: 190, source: :learned).save!(validate: false) }
  end

  test 'allows different kinds for the same movement and source' do
    build_row(kind: :max_effort, load: 185).save!(validate: false)

    assert_nothing_raised { build_row(kind: :unbroken, reps: 8).save!(validate: false) }
  end

  private

  # mathew has no capability fixtures, so these rows never collide with the fixture data.
  def build_row(kind:, **attrs)
    AthleteCapability.new(
      { user: users(:mathew), movement: movements(:run), source: :heuristic, model_version: 'heuristic-v1',
        computed_at: Time.current, kind: kind }.merge(attrs)
    )
  end
end
