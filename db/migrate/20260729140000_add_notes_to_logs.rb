class AddNotesToLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :logs, :notes, :text
  end
end
