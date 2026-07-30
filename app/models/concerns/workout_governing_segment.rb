module WorkoutGoverningSegment
  extend ActiveSupport::Concern

  # The segment that determines the workout's overall scheme: the sole segment, or the sole schemed
  # segment when every sibling is named context. Unnamed siblings are real prescribed work, so they
  # keep the workout from hiding them behind an inner segment's scheme.
  #
  # Segments are loaded into an Array before checking one?/many? here: CollectionProxy#one?/
  # #many?/#count run a SQL query rather than counting the in-memory target, which returns 0 for
  # an unsaved workout with only just-built (unpersisted) segments -- e.g. CfWod::WorkoutParser's
  # freshly parsed, not-yet-saved Workout. Array#one?/#many? don't have that problem.
  def governing_segment
    parts = segments.to_a
    return parts.sole if parts.one?

    schemed = parts.select(&:schemed?)
    return unless schemed.one?

    governing = schemed.sole
    governing if parts.all? { |part| part == governing || part.name.present? }
  end
end
