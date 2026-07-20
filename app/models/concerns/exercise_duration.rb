module ExerciseDuration
  extend ActiveSupport::Concern

  # Duration is stored as seconds, but forms accept "M:SS" or "H:MM:SS" for faster entry.
  def duration_seconds=(value)
    if value.is_a?(String) && value.include?(':')
      super(duration_string_to_seconds(value))
    else
      super
    end
  end

  def duration
    return if duration_seconds.blank?

    hours, remainder = duration_seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    return format('%<hours>d:%<minutes>02d:%<seconds>02d', hours:, minutes:, seconds:) if hours.positive?

    format('%<minutes>d:%<seconds>02d', minutes:, seconds:)
  end

  private

  def duration_string_to_seconds(value)
    value.split(':').map(&:to_i).reverse.each_with_index.sum { |part, index| part * (60**index) }
  end
end
