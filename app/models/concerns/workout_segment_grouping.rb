module WorkoutSegmentGrouping
  extend ActiveSupport::Concern

  # How many times the segment list is an identical group repeated back to back
  # (>= 2) -- e.g. "2 rounds for total reps of:" wrapping three distinct timed
  # blocks the extractor had to emit twice, since the schema has no field for
  # repeating a segment group. 1 when the segments do not repeat.
  def segment_group_rounds
    shapes = segments.reject(&:marked_for_destruction?).map { |segment| segment_content_signature(segment) }
    period = repeating_period(shapes)
    period ? shapes.size / period : 1
  end

  def repeated_segment_group?
    segment_group_rounds > 1
  end

  # The segments to actually render: a repeated total-reps group collapsed to a
  # single pass, since workout_objective already announces "N rounds for total
  # reps of". Every segment otherwise.
  def distinct_segments
    return segments.to_a unless segmented_total_reps? && repeated_segment_group?

    segments.to_a.first(segments.size / segment_group_rounds)
  end

  private

  # Smallest group size the shape list is a whole-number repeat of (a proper
  # divisor of its length whose blocks all recur at that stride), or nil.
  def repeating_period(shapes)
    count = shapes.size
    return if count < 2

    (1...count).find do |candidate|
      (count % candidate).zero? && shapes.drop(candidate).each_with_index.all? { |shape, i| shape == shapes[i] }
    end
  end
end
