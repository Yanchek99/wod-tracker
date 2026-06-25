class AddImplementCountToLoadedMovements < ActiveRecord::Migration[8.1]
  def change
    add_column :exercises, :implement_count, :integer
    add_column :movement_logs, :implement_count, :integer
  end
end
