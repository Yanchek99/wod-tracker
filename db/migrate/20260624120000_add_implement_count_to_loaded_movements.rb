class AddImplementCountToLoadedMovements < ActiveRecord::Migration[8.1]
  def change
    add_column :exercises, :implement_count, :integer, default: 1
    add_column :movement_logs, :implement_count, :integer, default: 1
  end
end
