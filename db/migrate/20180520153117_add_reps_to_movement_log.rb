class AddRepsToMovementLog < ActiveRecord::Migration[5.2]
  def change
    add_column :movement_logs, :reps, :integer
  end
end
