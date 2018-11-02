module MetricsHelper
  def measurement_unit(metric)
    case metric.measurement.to_sym
    when :weight
      "lbs"
    when :distance
      "meters"
    else
      ""
    end
  end
end
