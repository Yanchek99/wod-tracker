module SegmentsHelper
  def segment_objective(segment)
    msg = ''
    msg << 'Then, ' unless segment.exercises.where(position: 1).exists?
    return "#{msg}#{pluralize segment.rounds, 'round'} of" if segment.rounds.positive?
    return "#{msg}As many rounds as possible in #{pluralize segment.time, 'minute'}" if segment.amrap?
    return "#{msg}EMOM #{segment.time}" if segment.emom?
    return "#{msg}#{segment.rounds} #{segment.time}-minute rounds" if segment.timed_rounds?

    "#{msg}#{segment.interval} for #{segment.metric.measurement}"
  end
end
