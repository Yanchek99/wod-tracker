class AddConditionToSegments < ActiveRecord::Migration[8.1]
  def change
    add_column :segments, :condition, :string
  end
end
