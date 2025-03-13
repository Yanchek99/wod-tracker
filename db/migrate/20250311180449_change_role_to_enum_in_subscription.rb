class ChangeRoleToEnumInSubscription < ActiveRecord::Migration[8.0]
  def up
    # Step 1: Add a temporary integer column
    add_column :subscriptions, :role_int, :integer

    # Step 2: Map existing string values to integers
    role_mapping = { 'owner' => 0, 'coach' => 1, 'athelete' => 2 }

    Subscription.reset_column_information
    Subscription.find_each do |subscription|
      if role_mapping.key?(subscription.role)
        subscription.update_columns(role_int: role_mapping[subscription.role])
      end
    end

    # Step 3: Remove old string column and rename new column
    remove_column :subscriptions, :role
    rename_column :subscriptions, :role_int, :role
  end

  def down
    # Rollback: Convert integer back to string
    add_column :subscriptions, :role_str, :string

    role_mapping = { 0 => 'owner', 1 => 'coach', 2 => 'athelete' }

    Subscription.reset_column_information
    Subscription.find_each do |subscription|
      if role_mapping.key?(subscription.role)
        subscription.update_columns(role_str: role_mapping[subscription.role])
      end
    end

    remove_column :subscriptions, :role
    rename_column :subscriptions, :role_str, :role
  end
end
