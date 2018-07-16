class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.belongs_to :program, foreign_key: true
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end

    add_index :subscriptions, [:program_id, :user_id], unique: true
  end
end
