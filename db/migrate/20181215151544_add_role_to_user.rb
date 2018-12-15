class AddRoleToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :role, :string, null: false, default: 'athlete'
  end
end
