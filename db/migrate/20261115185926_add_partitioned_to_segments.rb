# A segment whose reps may be split up and done in any order (Murph, Open 20.5): one effort of a
# movement is then the athlete's choice, so it gets no per-effort stimulus values.
class AddPartitionedToSegments < ActiveRecord::Migration[8.1]
  def change
    add_column :segments, :partitioned, :boolean, default: false, null: false
  end
end
