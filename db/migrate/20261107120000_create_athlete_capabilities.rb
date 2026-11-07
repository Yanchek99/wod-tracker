class CreateAthleteCapabilities < ActiveRecord::Migration[8.1]
  # Kind integers referenced by the partial-index predicates below:
  # max_effort 0, unbroken 1, cannot_do 2, timed 3 (see AthleteCapability::KINDS).
  def change
    create_table :athlete_capabilities do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :movement, null: false, foreign_key: true, index: false
      t.integer :kind, null: false
      t.integer :load
      t.integer :reps
      t.integer :distance
      t.integer :distance_unit
      t.integer :duration_seconds
      t.integer :source, null: false
      t.string :model_version, null: false
      t.decimal :confidence, precision: 4, scale: 3
      t.integer :sample_count, null: false, default: 0
      t.datetime :computed_at, null: false
      t.timestamps
    end

    add_index :athlete_capabilities, %i[user_id movement_id],
              name: 'index_athlete_capabilities_on_user_id_and_movement_id'

    # One row per setting per (user, movement, kind, source). The result column is not part of the
    # key, so each kind gets its own partial index. A plain unique index treats NULLs as distinct,
    # so nullable setting columns are wrapped in COALESCE(col, -1): a bodyweight unbroken row (all
    # settings nil) cannot be duplicated. -1 never collides with a real value because measurements
    # are validated positive and distance_unit is 0 or more. (NULLS NOT DISTINCT would be tidier
    # but needs PostgreSQL 15+.)
    add_index :athlete_capabilities, %i[user_id movement_id source],
              unique: true, where: 'kind = 0',
              name: 'index_athlete_capabilities_unique_max_effort'
    add_index :athlete_capabilities,
              'user_id, movement_id, source, COALESCE(load, -1), COALESCE(distance, -1), ' \
              'COALESCE(distance_unit, -1)',
              unique: true, where: 'kind = 1',
              name: 'index_athlete_capabilities_unique_unbroken'
    add_index :athlete_capabilities, %i[user_id movement_id source],
              unique: true, where: 'kind = 2',
              name: 'index_athlete_capabilities_unique_cannot_do'
    add_index :athlete_capabilities,
              'user_id, movement_id, source, COALESCE(reps, -1), COALESCE(distance, -1), ' \
              'COALESCE(distance_unit, -1), COALESCE(load, -1)',
              unique: true, where: 'kind = 3',
              name: 'index_athlete_capabilities_unique_timed'
  end
end
