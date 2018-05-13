class Movement < ApplicationRecord
  enum measurement: [:weight, :distance, :time, :height]

  # rubocop:disable Metrics/MethodLength
  def measurement_unit
    return '' unless measurement
    case measurement.to_sym
    when :weight
      'lb'
    when :distance
      'meter'
    when :time
      'minute'
    when :height
      'inch'
    else
      ''
    end
  end
  # rubocop:enable Metrics/MethodLength
end
