module SegmentsHelper
  def segment_objective(segment, then_prefix: false)
    msg = then_prefix && !named_max_reps_segment?(segment) ? 'Then, ' : ''

    "#{msg}#{segment_prescription(segment)}"
  end

  private

  def named_max_reps_segment?(segment)
    segment.name.present? && segment.max_reps?
  end

  def segment_prescription(segment)
    return "#{segment.interval_scheme} of" if segment.interval?
    return "#{pluralize segment.rounds, 'round'} of" if segment.rounds?
    return max_reps_segment_prescription(segment) if segment.max_reps?
    return "As many rounds as possible in #{segment_duration(segment)}" if segment.amrap?
    return "EMOM #{segment.time_seconds / 60}" if segment.emom?
    return "#{segment.rounds} #{segment.time_seconds / 60}-minute rounds" if segment.timed_rounds?

    "#{segment.name.presence || 'Segment'}:"
  end

  def max_reps_segment_prescription(segment)
    [segment.name.presence, "max reps in #{segment_duration(segment)}"].compact.join(': ')
  end

  def segment_duration(segment)
    seconds = segment.time_seconds
    return pluralize(seconds / 60, 'minute') if (seconds % 60).zero?

    pluralize(seconds, 'second')
  end
end
