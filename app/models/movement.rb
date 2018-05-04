class Movement < ApplicationRecord
  enum measurement: [:weight, :distance, :time, :height]

  def measurement_unit
    return '' unless measurement
    case measurement.to_sym
    when :weight
      'lb'
    when :distance
      'meter'
    when :time
      'minute'
    else
      ''
    end
  end
end
