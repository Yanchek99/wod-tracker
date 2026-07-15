require 'test_helper'

class WorkoutFingerprintTest < ActiveSupport::TestCase
  test 'assigns a content key from the workout structure on save' do
    workout = build_fran('Fran A')
    workout.save!

    assert workout.content_key.present?
    assert_equal workout.content_fingerprint, workout.content_key
  end

  test 'identical prescribed content fingerprints the same regardless of name' do
    assert_equal build_fran('One').content_fingerprint, build_fran('Two').content_fingerprint
  end

  test 'different prescribed content fingerprints differently' do
    heavier = build_fran('Heavier')
    heavier.segments.first.exercises.first.load = 135

    assert_not_equal build_fran('Base').content_fingerprint, heavier.content_fingerprint
  end

  test 'notes do not change the fingerprint' do
    noted = build_fran('Noted')
    noted.segments.first.exercises.first.notes = '1 1/2 body weight'

    assert_equal build_fran('Plain').content_fingerprint, noted.content_fingerprint
  end

  test 'excludes exercises marked for destruction from the fingerprint' do
    workout = build_fran('Trimmed')
    workout.save!
    remaining = Workout.new(name: 'Remaining', score_type: :time, interval: '21-15-9')
    remaining_segment = remaining.segments.build(interval_scheme: '21-15-9', position: 1)
    remaining_segment.exercises.build(movement: movements(:thruster), position: 1, reps: 1, load: 95, load_unit: :lb)

    workout.segments.flat_map(&:exercises).find { |exercise| exercise.movement == movements(:pullup) }.mark_for_destruction

    assert_equal remaining.content_fingerprint, workout.content_fingerprint
  end

  test 'a workout without parts has no content key' do
    assert_nil Workout.create!(name: 'Empty', score_type: :time).content_key
  end

  test 'refreshes the content key when an exercise changes directly' do
    workout = build_fran('Direct')
    workout.save!
    original = workout.content_key

    workout.exercises.first.update!(reps: 15)

    assert_not_equal original, workout.reload.content_key
  end

  test 'refreshes the content key when a part is added to an empty workout' do
    workout = Workout.create!(name: 'Grows', score_type: :time)
    segment = workout.segments.create!(position: 1)

    segment.exercises.create!(movement: movements(:pullup), position: 1, reps: 21)

    assert workout.reload.content_key.present?
  end

  test 'refreshes the content key when an exercise is destroyed directly' do
    workout = build_fran('Shrinks')
    workout.save!
    original = workout.content_key

    workout.exercises.find { |exercise| exercise.movement == movements(:pullup) }.destroy!

    assert_not_equal original, workout.reload.content_key
  end

  test 'a duplicate-content workout saves with a nil key for later merge' do
    build_fran('Original').save!
    dup = build_fran('Duplicate')

    assert_nothing_raised { dup.save! }
    assert_nil dup.content_key
  end

  test 'absorb_duplicate! folds schedules and logs into the matching workout and deletes self' do
    canonical = build_fran('Canonical')
    canonical.save!
    dup = build_fran('Dup')
    dup.save!
    dup.schedules.create!(program: programs(:crossfit), posted_at: '2026-02-01')
    dup.logs.create!(user: users(:mathew), score_type: :time)

    result = dup.absorb_duplicate!

    assert_equal canonical, result
    assert_not Workout.exists?(dup.id)
    assert_equal canonical.id, Schedule.find_by(posted_at: '2026-02-01').workout_id
    assert_equal 1, canonical.logs.count
  end

  test 'absorb_duplicate! drops a schedule that duplicates one on the canonical workout' do
    canonical = build_fran('Canonical')
    canonical.save!
    dup = build_fran('Dup')
    dup.save!
    canonical.schedules.create!(program: programs(:crossfit), posted_at: '2026-03-01')
    dup.schedules.create!(program: programs(:crossfit), posted_at: '2026-03-01')
    dup.schedules.create!(program: programs(:local_gym), posted_at: '2026-03-01')

    assert_difference -> { Schedule.count }, -1 do
      dup.absorb_duplicate!
    end

    assert_equal 1, canonical.schedules.where(program: programs(:crossfit), posted_at: '2026-03-01').count
    assert_equal 1, canonical.schedules.where(program: programs(:local_gym)).count
  end

  test 'absorb_duplicate! returns self when the content is unique' do
    workout = build_fran('Unique')
    workout.save!

    assert_equal workout, workout.absorb_duplicate!
    assert Workout.exists?(workout.id)
  end

  test 'team size keeps a partner workout distinct from content-identical solo work' do
    solo = build_fran('Solo')
    partnered = build_fran('Partner').tap { |workout| workout.team_size = 2 }

    assert_not_equal solo.content_fingerprint, partnered.content_fingerprint
  end

  private

  def build_fran(name)
    Workout.new(name:, score_type: :time, interval: '21-15-9').tap do |workout|
      segment = workout.segments.build(interval_scheme: '21-15-9', position: 1)
      segment.exercises.build(movement: movements(:thruster), position: 1, reps: 1, load: 95, load_unit: :lb)
      segment.exercises.build(movement: movements(:pullup), position: 2, reps: 1)
    end
  end
end
