namespace :metric do
  desc "Convert measurement to a unit"
  task measurement_migration: :environment do
    Metric.all.each do |metric|
      next if metric.measurement.blank?
      next if metric.measurable.instance_of?(Workout) || metric.instance_of?(Log)
      case metric.measurement.to_sym
      when :weight
        metric.lb!
      when :time
        metric.seconds!
      when :height
        metric.inch!
      when :distance
        metric.meter!
      end
    end
  end

end
