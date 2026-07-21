class BackfillRolelessSubscriptions < ActiveRecord::Migration[8.1]
  class MigrationSubscription < ActiveRecord::Base
    self.table_name = 'subscriptions'
  end

  def up
    # rubocop:disable Rails/SkipsModelValidations
    MigrationSubscription.where(role: nil).in_batches.update_all(role: 2)
    # rubocop:enable Rails/SkipsModelValidations

    # New subscriptions without an explicit role should behave like a normal follow.
    change_column_default :subscriptions, :role, from: nil, to: 2
  end

  def down
    # Data-only backfill is intentionally not reversible; only restore the schema default.
    change_column_default :subscriptions, :role, from: 2, to: nil
  end
end
