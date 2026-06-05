class MigrateWorkoutNotesToRichText < ActiveRecord::Migration[8.1]
  class MigrationWorkout < ActiveRecord::Base
    self.table_name = 'workouts'
  end

  class MigrationRichText < ActiveRecord::Base
    self.table_name = 'action_text_rich_texts'
  end

  def up
    MigrationWorkout.where.not(notes: [nil, '']).find_each do |workout|
      rich_text = MigrationRichText.find_or_initialize_by(
        record_type: 'Workout',
        record_id: workout.id,
        name: 'notes'
      )

      next if rich_text.persisted? && rich_text.body.present?

      rich_text.update!(
        body: rich_text_body(workout.notes),
        created_at: workout.created_at,
        updated_at: workout.updated_at
      )
    end

    remove_column :workouts, :notes
  end

  def down
    add_column :workouts, :notes, :text
    MigrationWorkout.reset_column_information

    MigrationRichText.where(record_type: 'Workout', name: 'notes').find_each do |rich_text|
      workout = MigrationWorkout.find_by(id: rich_text.record_id)
      workout&.update!(notes: ActionText::Content.new(rich_text.body).to_plain_text)
    end

    MigrationRichText.where(record_type: 'Workout', name: 'notes').delete_all
  end

  private

  def rich_text_body(notes)
    notes.to_s.split(/\r?\n\r?\n/).map do |paragraph|
      "<div>#{ERB::Util.html_escape(paragraph).gsub(/\r?\n/, '<br>')}</div>"
    end.join
  end
end
