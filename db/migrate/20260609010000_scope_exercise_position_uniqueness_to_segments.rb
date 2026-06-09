# rubocop:disable Metrics/ClassLength
class ScopeExercisePositionUniquenessToSegments < ActiveRecord::Migration[8.1]
  class MigrationExercise < ActiveRecord::Base
    self.table_name = 'exercises'
    self.record_timestamps = false
  end

  class MigrationSegment < ActiveRecord::Base
    self.table_name = 'segments'
    self.record_timestamps = false

    has_many :exercises, class_name: 'ScopeExercisePositionUniquenessToSegments::MigrationExercise',
                         foreign_key: :segment_id, inverse_of: false
  end

  def up
    remove_index :exercises, name: 'index_exercises_on_position_and_workout_id' if old_exercise_position_index?
    add_column :segments, :position, :integer unless column_exists?(:segments, :position)

    reset_positions

    change_column_null :segments, :position, false
    add_index :segments, [:position, :workout_id], unique: true unless segment_position_index?

    add_top_level_exercise_position_index
    add_segment_exercise_position_index
  end

  def down
    remove_index :exercises, name: 'index_exercises_on_position_and_segment_id' if segment_exercise_position_index?
    remove_index :exercises, name: 'index_exercises_on_position_and_workout_id' if top_level_exercise_position_index?

    reset_whole_workout_exercise_positions

    remove_index :segments, column: [:position, :workout_id] if segment_position_index?
    remove_column :segments, :position if column_exists?(:segments, :position)

    add_old_exercise_position_index unless old_exercise_position_index?
  end

  private

  def reset_positions
    say_with_time 'Resetting exercise positions within their ordering scopes' do
      reset_workout_part_positions
      reset_segment_positions
    end
  end

  def reset_workout_part_positions
    workout_ids = MigrationExercise.distinct.pluck(:workout_id) | MigrationSegment.distinct.pluck(:workout_id)

    workout_ids.each do |workout_id|
      reset_workout_positions(workout_id)
    end
  end

  def reset_segment_positions
    MigrationExercise.where.not(segment_id: nil).distinct.pluck(:segment_id).each do |segment_id|
      reset_scope_positions(MigrationExercise.where(segment_id:))
    end
  end

  def reset_scope_positions(scope)
    scope.order(:position, :id).pluck(:id).each.with_index(1) do |id, position|
      MigrationExercise.find(id).update!(position:)
    end
  end

  def reset_workout_positions(workout_id)
    workout_parts(workout_id).sort_by { |part| [part[:old_position], part[:id]] }.each.with_index(1) do |part, position|
      part[:record].update!(position:)
    end
  end

  def workout_parts(workout_id)
    top_level_exercises(workout_id) + segments(workout_id)
  end

  def top_level_exercises(workout_id)
    MigrationExercise.where(workout_id:, segment_id: nil).map do |exercise|
      { record: exercise, id: exercise.id, old_position: exercise.position }
    end
  end

  def segments(workout_id)
    fallback_position = MigrationExercise.where(workout_id:).maximum(:position).to_i

    MigrationSegment.where(workout_id:).map do |segment|
      fallback_position += 1
      { record: segment, id: segment.id, old_position: segment.position || segment_old_position(segment) || fallback_position }
    end
  end

  def segment_old_position(segment)
    MigrationExercise.where(segment_id: segment.id).minimum(:position)
  end

  def reset_whole_workout_exercise_positions
    MigrationExercise.distinct.pluck(:workout_id).each do |workout_id|
      whole_workout_exercises(workout_id).each.with_index(1) do |exercise, position|
        exercise.update!(position:)
      end
    end
  end

  def whole_workout_exercises(workout_id)
    if column_exists?(:segments, :position)
      workout_parts(workout_id).sort_by { |part| [part[:old_position], part[:id]] }.flat_map do |part|
        part[:record].is_a?(MigrationSegment) ? part[:record].exercises.order(:position, :id) : part[:record]
      end
    else
      MigrationExercise.where(workout_id:).order(:position, :id)
    end
  end

  def add_top_level_exercise_position_index
    return if top_level_exercise_position_index?

    add_index :exercises, [:position, :workout_id],
              unique: true,
              where: 'segment_id IS NULL',
              name: 'index_exercises_on_position_and_workout_id'
  end

  def add_segment_exercise_position_index
    return if segment_exercise_position_index?

    add_index :exercises, [:position, :segment_id],
              unique: true,
              where: 'segment_id IS NOT NULL',
              name: 'index_exercises_on_position_and_segment_id'
  end

  def add_old_exercise_position_index
    add_index :exercises, [:position, :workout_id],
              unique: true,
              name: 'index_exercises_on_position_and_workout_id'
  end

  def old_exercise_position_index?
    index_exists?(:exercises, [:position, :workout_id], name: 'index_exercises_on_position_and_workout_id')
  end

  def top_level_exercise_position_index?
    index_exists?(:exercises, [:position, :workout_id], name: 'index_exercises_on_position_and_workout_id')
  end

  def segment_exercise_position_index?
    index_exists?(:exercises, [:position, :segment_id], name: 'index_exercises_on_position_and_segment_id')
  end

  def segment_position_index?
    index_exists?(:segments, [:position, :workout_id])
  end
end
# rubocop:enable Metrics/ClassLength
