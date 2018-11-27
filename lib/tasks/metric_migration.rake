namespace :metric_migration do
  desc 'Migrates exercise model to metrics'
  task exercises: :environment do
    Exercise.all.each do |e|
      e.metrics.build(measurement: :rep, value: e.reps)
      e.metrics.build(measurement: e.measurement.name.to_sym, value: e.measurement_value) if e.measurement && e.measurement_value.present?
      e.save
    end
  end

  desc 'Migrates movement logs model to metrics'
  task movement_logs: :environment do
    MovementLog.all.each do |ml|
      ml.metrics.build(measurement: :rep, value: ml.reps)
      ml.metrics.build(measurement: ml.measurement.name.to_sym, value: ml.measurement_value) if ml.measurement && ml.measurement_value.present?
      ml.save
    end
  end
end
