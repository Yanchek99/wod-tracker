require_relative 'helper'

class CapabilityEstimatorMaxEffortTest < ActiveSupport::TestCase
  include CapabilityEstimatorHelper

  setup do
    setup_estimator_user
    @squat = movements(:back_squat)
    @lifting = workouts(:back_squat_5x5)
    @metcon = workouts(:fran)
  end

  def rows = CapabilityEstimator::MaxEffort.call(samples)

  def lifting_log(reps:, load:)
    create_log(@lifting, { movement: @squat, reps:, load: }, score_type: :weight)
  end

  test 'a 3 rep log at 100 lb estimates 110' do
    lifting_log(reps: 3, load: 100)

    row = rows.sole
    assert_equal({ movement_id: @squat.id, kind: :max_effort, load: 110 }, row.slice(:movement_id, :kind, :load))
    assert_nil row[:reps]
  end

  test 'a single rep is the load itself' do
    lifting_log(reps: 1, load: 225)

    assert_equal 225, rows.sole[:load]
  end

  test 'the max estimate across logs wins and sample_count counts the logs' do
    lifting_log(reps: 3, load: 100)
    lifting_log(reps: 1, load: 225)

    row = rows.sole
    assert_equal 225, row[:load]
    assert_equal 2, row[:sample_count]
  end

  test 'reps above the cap are capped at 10' do
    lifting_log(reps: 15, load: 100)

    assert_equal 133, rows.sole[:load]
  end

  test 'metcon-only history gets the floor confidence' do
    create_log(@metcon, { movement: @squat, reps: 1, load: 100 })

    assert_in_delta 0.4, rows.sole[:confidence]
  end

  test 'a max-effort source raises confidence and three samples add a bonus, capped at 0.9' do
    lifting_log(reps: 3, load: 100)
    assert_in_delta 0.7, rows.sole[:confidence]

    2.times { lifting_log(reps: 3, load: 100) }
    assert_in_delta 0.8, rows.sole[:confidence]
  end

  test 'movement logs without a load, with nil reps, or with the reps 0 sentinel contribute nothing' do
    create_log(@lifting, { movement: @squat, reps: 5 }, score_type: :weight)
    create_log(@lifting, { movement: @squat, load: 135 }, score_type: :weight)
    create_log(@lifting, { movement: @squat, reps: 0, load: 135 }, score_type: :weight)

    assert_empty rows
  end
end
