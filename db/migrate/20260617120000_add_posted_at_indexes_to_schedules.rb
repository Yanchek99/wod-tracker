class AddPostedAtIndexesToSchedules < ActiveRecord::Migration[8.1]
  def change
    add_index :schedules, [:program_id, :posted_at]
    add_index :schedules, :posted_at
  end
end
