class AddSexToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :sex, :integer, default: 0, null: false
    change_column_default :users, :sex, from: 0, to: nil
  end
end
