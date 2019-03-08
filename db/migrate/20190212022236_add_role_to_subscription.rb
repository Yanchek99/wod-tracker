class AddRoleToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :role, :string, default: :athlete
  end
end
