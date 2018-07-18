class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.belongs_to :program, foreign_key: true
      t.belongs_to :workout, foreign_key: true
      t.timestamp :posted_at, null: false

      t.timestamps
    end
  end
end
