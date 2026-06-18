module WorkoutPositionReservation
  extend ActiveSupport::Concern

  def reserve_submitted_positions!(attributes)
    reserve_records(existing_top_level_exercises(attributes))
    reserve_records(existing_segments(attributes))

    nested_attribute_values(attributes[:segments_attributes]).each do |segment_attributes|
      segment_id = nested_attribute_id(segment_attributes)
      next unless segment_id

      reserve_records(existing_segment_exercises(segment_id, segment_attributes))
    end
  end

  private

  def existing_top_level_exercises(attributes)
    exercise_ids = nested_attribute_ids(attributes[:exercises_attributes])
    Exercise.unscoped.where(workout_id: id, segment_id: nil, id: exercise_ids)
  end

  def existing_segments(attributes)
    segment_ids = nested_attribute_ids(attributes[:segments_attributes])
    Segment.unscoped.where(workout_id: id, id: segment_ids)
  end

  def existing_segment_exercises(segment_id, segment_attributes)
    exercise_ids = nested_attribute_ids(segment_attributes[:exercises_attributes])
    Exercise.unscoped.where(segment_id:, id: exercise_ids)
  end

  def reserve_records(records)
    records.each.with_index(1) do |record, index|
      # Reserve submitted rows inside the update transaction so uniqueness indexes allow position swaps.
      # The workout form submits every persisted sibling with a hidden positive
      # position; validation rollback protects us if that invariant is broken.
      record.update_columns(position: -index) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def nested_attribute_ids(attributes)
    nested_attribute_values(attributes).filter_map { |attribute| nested_attribute_id(attribute) }
  end

  def nested_attribute_values(attributes)
    return [] if attributes.blank?
    return attributes.values if nested_attribute_collection?(attributes)

    Array(attributes)
  end

  def nested_attribute_collection?(attributes)
    !attributes.is_a?(Array) && attributes.respond_to?(:values) && nested_attribute_id(attributes).blank?
  end

  def nested_attribute_id(attributes)
    (attributes[:id] || attributes['id']).presence
  end
end
