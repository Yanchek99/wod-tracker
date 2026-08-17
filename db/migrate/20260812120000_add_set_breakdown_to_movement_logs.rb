class AddSetBreakdownToMovementLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :movement_logs, :set_breakdown, :integer, array: true, default: [], null: false
  end
end
