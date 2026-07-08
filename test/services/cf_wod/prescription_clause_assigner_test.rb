require 'test_helper'

module CfWod
  class PrescriptionClauseAssignerTest < ActiveSupport::TestCase
    def exercise_line(movement, raw_line)
      { exercise: Exercise.new(movement: movement), raw_line: raw_line }
    end

    test 'binds a bare no-noun clause to every barbell-family movement, skipping bodyweight ones' do
      snatch = exercise_line(movements(:power_snatch), '5 power snatches')
      lunge = exercise_line(movements(:overhead_walking_lunge), '10 overhead walking lunges')
      rope_climb = exercise_line(movements(:rope_climb), '1 rope climb, 15-ft. rope')
      clauses = { female: [[{ value: 65, unit: :lb, implement: '' }]], male: [[{ value: 95, unit: :lb, implement: '' }]] }

      PrescriptionClauseAssigner.call([snatch, lunge, rope_climb], clauses)

      assert_equal [65, 95], [snatch[:exercise].female_load, snatch[:exercise].male_load]
      assert_equal [65, 95], [lunge[:exercise].female_load, lunge[:exercise].male_load]
      assert_nil rope_climb[:exercise].female_load
    end

    test 'binds a shared-token clause to every occurrence of a repeated movement' do
      first_box_jump = exercise_line(movements(:box_jump), '40 box jumps')
      second_box_jump = exercise_line(movements(:box_jump), '40 box jumps')
      deadlift = exercise_line(movements(:deadlift), '10 deadlifts')
      clauses = { female: [[{ value: 20, unit: :inch, implement: 'box' }]],
                  male: [[{ value: 24, unit: :inch, implement: 'box' }]] }

      PrescriptionClauseAssigner.call([first_box_jump, second_box_jump, deadlift], clauses)

      assert_equal [20, 24], [first_box_jump[:exercise].female_distance, first_box_jump[:exercise].male_distance]
      assert_equal [20, 24], [second_box_jump[:exercise].female_distance, second_box_jump[:exercise].male_distance]
      assert_nil deadlift[:exercise].female_distance
    end

    test 'binds a shared-token clause across a synonymous implement noun (medicine ball vs wall-ball)' do
      wall_ball = exercise_line(movements(:wall_ball_shot), '30 wall-ball shots')
      clauses = { female: [[{ value: 14, unit: :lb, implement: 'medicine ball' },
                            { value: 9, unit: :foot, implement: 'target' }]],
                  male: [[{ value: 20, unit: :lb, implement: 'medicine ball' },
                          { value: 10, unit: :foot, implement: 'target' }]] }

      PrescriptionClauseAssigner.call([wall_ball], clauses)

      exercise = wall_ball[:exercise]
      assert_equal [14, 20], [exercise.female_load, exercise.male_load]
      assert_equal [9, 10], [exercise.female_distance, exercise.male_distance]
      assert_equal :foot, exercise.distance_unit.to_sym
    end

    test 'raises UnparseableError when a clause matches no candidate' do
      rope_climb = exercise_line(movements(:rope_climb), '1 rope climb, 15-ft. rope')
      clauses = { female: [[{ value: 20, unit: :inch, implement: 'box' }]],
                  male: [[{ value: 24, unit: :inch, implement: 'box' }]] }

      assert_raises(WorkoutParser::UnparseableError) { PrescriptionClauseAssigner.call([rope_climb], clauses) }
    end
  end
end
