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
  desc 'Migrates workouts model to use metric'
  task workouts: :environment do
    Workout.all.each do |w|
      w.create_metric(measurement: w.measurement.name.to_sym)
      w.save
    end
  end
  desc 'Migrates logs model to metric'
  task logs: :environment do
    Log.all.each do |l|
      l.create_metric(measurement: l.workout.measurement.name.to_sym, value: l.measurement_value)
      l.save
    end
  end
end
