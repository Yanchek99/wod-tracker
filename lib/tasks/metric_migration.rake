namespace :metric_migration do
  desc "TODO"
  task exercises: :environment do
    Exercise.all.each do |e|
      e.metrics.build(measurement: :rep, value: e.reps)
      if e.measurement && e.measurement_value.present?
        e.metrics.build(measurement: e.measurement.name.to_sym, value: e.measurement_value)
      end
      e.save
    end
  end

  desc "TODO"
  task movement_logs: :environment do
    MovementLog.all.each do |ml|
      ml.metrics.build(measurement: :rep, value: ml.reps)
      if ml.measurement && ml.measurement_value.present?
        ml.metrics.build(measurement: ml.measurement.name.to_sym, value: ml.measurement_value)
      end
      ml.save
    end
  end
end
