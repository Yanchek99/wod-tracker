module SegmentsHelper
  def segment_objective(segment)
    return "Then, #{pluralize segment.rounds, 'round'} of" if segment.rounds.positive?
    return "Then, As many rounds as possible in #{pluralize segment.time, 'minute'}" if segment.amrap?
    return "Then, EMOM #{segment.time}" if segment.emom?
    return "Then, #{segment.rounds} #{segment.time}-minute rounds" if segment.timed_rounds?

    "Then, #{segment.interval} for #{segment.metric.measurement}"
  end
end
