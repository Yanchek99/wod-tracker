class ChangeRoleToEnumInUsers < ActiveRecord::Migration[8.0]
  def up
    # Step 1: Add a temporary integer column
    add_column :users, :role_int, :integer

    # Step 2: Map existing string values to integers
    role_mapping = { 'admin' => 0, 'user' => 1 }
    User.reset_column_information
    User.find_each do |user|
      user.update_columns(role_int: role_mapping[user.role]) if role_mapping.key?(user.role)
    end

    # Step 3: Remove old string column and rename new column
    remove_column :users, :role 
    rename_column :users, :role_int, :role 
  end

  def down
    # Rollback: Convert integer back to string
    add_column :users, :role_str, :string

    role_mapping = { 0 => 'admin', 1 => 'user' }
    User.reset_column_information
    User.find_each do |user|
      user.update_columns(role_str: role_mapping[user.role]) if role_mapping.key?(user.role)
    end

    remove_column :users, :role
    rename_column :users, :role_str, :role
  end
end
