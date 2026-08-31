module SegmentsHelper
  def segment_objective(segment, then_prefix: false)
    return nil if segment.name.blank? && !segment.schemed?

    msg = then_prefix && !standalone_max_reps_segment?(segment) ? 'Then, ' : ''
    "#{msg}#{segment_prescription(segment)}"
  end

  def segment_objective?(segment)
    !segment.implicit_workout_part?
  end

  # A segment's own trailing rest ("Rest 1 minute"), rendered as its own line after the
  # segment's exercises. nil when the segment carries no rest of its own.
  def segment_rest(segment)
    return nil if segment.rest_seconds.blank?

    "Rest #{humanized_duration(segment.rest_seconds)}"
  end

  private

  # A max-rep block that reads on its own without a "Then, " lead-in: either it
  # carries its own label (a "0:00-5:00" window) or it is one part of a repeated
  # group already announced as "N rounds for total reps of".
  def standalone_max_reps_segment?(segment)
    return false unless segment.max_reps?

    segment.name.present? || segment.workout&.repeated_segment_group? || false
  end

  def segment_prescription(segment)
    return "#{segment.interval_scheme} of" if segment.interval?
    return "#{pluralize segment.rounds, 'round'} of" if segment.rounds?

    timed_segment_prescription(segment) || "#{segment.name.presence || 'Segment'}:"
  end

  def timed_segment_prescription(segment)
    return max_reps_segment_prescription(segment) if segment.max_reps?
    return amrap_segment_prescription(segment) if segment.amrap?
    return "EMOM #{segment.time_seconds / 60}" if segment.emom?

    "#{segment.rounds} #{segment.time_seconds / 60}-minute rounds" if segment.timed_rounds?
  end

  # A bare interval block -- one with no heading of its own, or one part of a repeated group
  # already announced as "N rounds for total reps of" -- reads as "AMRAP in M:SS", since its
  # name would only restate the timing or the movements listed right below it. A labeled
  # standalone window ("0:00-5:00" on one shared clock) keeps the prose form.
  def amrap_segment_prescription(segment)
    return "AMRAP in #{clock_duration(segment.time_seconds)}" if bare_interval_block?(segment)

    "#{segment.name}: As many rounds as possible in #{segment_duration(segment)}"
  end

  def max_reps_segment_prescription(segment)
    return "AMRAP in #{clock_duration(segment.time_seconds)}" if bare_interval_block?(segment)

    "#{segment.name}: max reps in #{segment_duration(segment)}"
  end

  def bare_interval_block?(segment)
    segment.name.blank? || segment.workout&.repeated_segment_group? || false
  end

  def segment_duration(segment)
    humanized_duration(segment.time_seconds)
  end

  def clock_duration(seconds)
    format('%<minutes>d:%<seconds>02d', minutes: seconds / 60, seconds: seconds % 60)
  end

  def humanized_duration(seconds)
    return pluralize(seconds / 60, 'minute') if (seconds % 60).zero?

    pluralize(seconds, 'second')
  end
end
