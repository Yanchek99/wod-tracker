require 'test_helper'

# Loads are stored canonically in pounds, so a prescription entered or imported in lb, kg, or pood
# must resolve to one content fingerprint (see cf/docs/decisions.md, #1684).
class WorkoutLoadIdentityTest < ActiveSupport::TestCase
  test 'the same barbell prescription fingerprints identically whether entered in lb or kg' do
    in_lb = build_loaded(load: 95, unit: :lb)
    in_kg = build_loaded(load: 43, unit: :kg) # 43 kg is published as 95 lb

    assert_equal in_lb.content_fingerprint, in_kg.content_fingerprint
  end

  test 'a standard kettlebell fingerprints identically across pood, kg, and lb' do
    # The 32 kg / 2 pood / 70 lb kettlebell is one prescription. (A fractional 1.5-pood input is
    # normalized by the importer before it reaches the integer load column; see LoadEquivalenceTest.)
    lb = build_loaded(load: 70, unit: :lb)

    assert_equal lb.content_fingerprint, build_loaded(load: 32, unit: :kg).content_fingerprint
    assert_equal lb.content_fingerprint, build_loaded(load: 2, unit: :pood).content_fingerprint
  end

  # The load-identity migration recomputes every workout's content_key now that load_unit no longer
  # participates in the fingerprint, which can make two previously-distinct workouts (e.g. one
  # stored 95 lb, one stored 43 kg) collide on the same key. Recomputing with a raw write would trip
  # the unique index; the migration instead saves through the model (leaving a duplicate's key nil,
  # per WorkoutFingerprint#assignable_content_key) and merges via absorb_duplicate!. This proves that
  # sequence consolidates two persisted rows whose stale keys predate the fingerprint format change,
  # instead of raising.
  test 'recomputing stale content keys for two workouts that now match merges them' do
    first = build_loaded(load: 95, unit: :lb)
    first.save!
    # rubocop:disable Rails/SkipsModelValidations -- simulates a key computed under the old format
    first.update_column(:content_key, 'stale-key-a')

    second = build_loaded(load: 95, unit: :lb)
    second.save!(validate: false)
    second.update_column(:content_key, 'stale-key-b')
    # rubocop:enable Rails/SkipsModelValidations

    assert_difference('Workout.count', -1) do
      Workout.where(id: [first.id, second.id]).find_each do |workout|
        workout.save!(validate: false)
        workout.absorb_duplicate!
      end
    end

    assert Workout.exists?(content_key: first.content_fingerprint)
  end

  private

  # Builds and validates a one-exercise workout so the load input is canonicalized to pounds.
  def build_loaded(load:, unit:)
    Workout.new(name: "Loaded #{load}#{unit}", score_type: :time).tap do |workout|
      segment = workout.segments.build(position: 1)
      segment.exercises.build(movement: movements(:thruster), position: 1, reps: 1, load:, load_unit: unit)
      workout.validate
    end
  end
end
