# A double kettlebell clean is a different capability from a single (or alternating single) one at
# the same per-implement load, so the implement count is part of a point's setting. NULL means a
# single implement (as on exercises and movement_logs); only counts above 1 are stored.
class AddImplementCountToAthleteCapabilities < ActiveRecord::Migration[8.1]
  # index name => [kind, columns before, columns after]; kind integers are AthleteCapability::KINDS.
  INDEXES = {
    'index_athlete_capabilities_unique_max_effort' => [
      0, %i[user_id movement_id source],
      'user_id, movement_id, source, COALESCE(implement_count, -1)'
    ],
    'index_athlete_capabilities_unique_unbroken' => [
      1, 'user_id, movement_id, source, COALESCE(load, -1), COALESCE(distance, -1), COALESCE(distance_unit, -1)',
      'user_id, movement_id, source, COALESCE(load, -1), COALESCE(distance, -1), COALESCE(distance_unit, -1), ' \
      'COALESCE(implement_count, -1)'
    ],
    'index_athlete_capabilities_unique_timed' => [
      3, 'user_id, movement_id, source, COALESCE(reps, -1), COALESCE(distance, -1), COALESCE(distance_unit, -1), ' \
         'COALESCE(load, -1)',
      'user_id, movement_id, source, COALESCE(reps, -1), COALESCE(distance, -1), COALESCE(distance_unit, -1), ' \
      'COALESCE(load, -1), COALESCE(implement_count, -1)'
    ]
  }.freeze

  def up
    add_column :athlete_capabilities, :implement_count, :integer
    INDEXES.each { |name, (kind, _before, after)| rebuild_index(name, kind, after) }
  end

  def down
    INDEXES.each { |name, (kind, before, _after)| rebuild_index(name, kind, before) }
    remove_column :athlete_capabilities, :implement_count
  end

  private

  def rebuild_index(name, kind, columns)
    remove_index :athlete_capabilities, name: name
    add_index :athlete_capabilities, columns, unique: true, where: "kind = #{kind}", name: name
  end
end
