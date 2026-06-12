class RestructureSegmentsAsStructuralBlocks < ActiveRecord::Migration[8.1]
  class MigrationSegment < ActiveRecord::Base
    self.table_name = 'segments'
    self.record_timestamps = false
  end

  class MigrationMetric < ActiveRecord::Base
    self.table_name = 'metrics'
  end

  def up
    add_column :segments, :name, :string unless column_exists?(:segments, :name)
    add_column :segments, :time_seconds, :integer unless column_exists?(:segments, :time_seconds)
    add_column :segments, :interval_scheme, :string unless column_exists?(:segments, :interval_scheme)
    add_column :segments, :rest_seconds, :integer unless column_exists?(:segments, :rest_seconds)
    add_column :segments, :notes, :text unless column_exists?(:segments, :notes)

    backfill_structural_fields
    delete_segment_metrics

    remove_column :segments, :time if column_exists?(:segments, :time)
    remove_column :segments, :interval if column_exists?(:segments, :interval)
  end

  def down
    add_column :segments, :time, :integer unless column_exists?(:segments, :time)
    add_column :segments, :interval, :integer unless column_exists?(:segments, :interval)

    restore_legacy_fields

    remove_column :segments, :notes if column_exists?(:segments, :notes)
    remove_column :segments, :rest_seconds if column_exists?(:segments, :rest_seconds)
    remove_column :segments, :interval_scheme if column_exists?(:segments, :interval_scheme)
    remove_column :segments, :time_seconds if column_exists?(:segments, :time_seconds)
    remove_column :segments, :name if column_exists?(:segments, :name)
  end

  private

  def backfill_structural_fields
    say_with_time 'Backfilling segment time_seconds and interval_scheme' do
      MigrationSegment.where.not(time: nil).find_each do |segment|
        segment.update!(time_seconds: segment.time * 60)
      end

      MigrationSegment.where.not(interval: nil).find_each do |segment|
        segment.update!(interval_scheme: segment.interval.to_s)
      end
    end
  end

  # Deleted segment metrics are not restorable on rollback.
  def delete_segment_metrics
    say_with_time 'Deleting segment-scoped metrics' do
      MigrationMetric.where(measurable_type: 'Segment').delete_all
    end
  end

  # Dash-style interval schemes cannot round-trip into the legacy integer column and are dropped.
  def restore_legacy_fields
    say_with_time 'Restoring segment time and interval from structural fields' do
      MigrationSegment.where.not(time_seconds: nil).find_each do |segment|
        segment.update!(time: segment.time_seconds / 60)
      end

      MigrationSegment.where("interval_scheme ~ '^[0-9]+$'").find_each do |segment|
        segment.update!(interval: segment.interval_scheme.to_i)
      end
    end
  end
end
