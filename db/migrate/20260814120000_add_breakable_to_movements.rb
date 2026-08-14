class AddBreakableToMovements < ActiveRecord::Migration[8.1]
  def change
    add_column :movements, :breakable, :boolean, default: true, null: false
  end
end
