class BackfillRolelessSubscriptions < ActiveRecord::Migration[8.1]
  class MigrationSubscription < ActiveRecord::Base
    self.table_name = 'subscriptions'
  end

  def up
    # rubocop:disable Rails/SkipsModelValidations
    MigrationSubscription.where(role: nil).update_all(role: 2)
    # rubocop:enable Rails/SkipsModelValidations

    change_column_default :subscriptions, :role, from: nil, to: 2
  end

  def down
    change_column_default :subscriptions, :role, from: 2, to: nil
  end
end
