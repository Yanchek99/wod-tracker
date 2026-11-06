# One-off: repair production's "Fight Gone Bad" after a scraped copy landed as its own Workout
# (#449) instead of resolving to the catalogued benchmark (#1).
#
#   1. Rebuild the canonical record from its corrected prescription. Prod #1 had drifted to
#      score_type :time with every exercise field stripped, and stored a denormalized segment
#      time_seconds. Saving through the model also refreshes its stale content_key.
#   2. Fold every other Workout named "Fight Gone Bad" into the canonical one (schedules + logs),
#      then delete it.
#
# The prescription below mirrors db/seeds/benchmark_workouts.rb, which is the source of truth.
#
# Run once: bin/rails runner script/repair_fight_gone_bad.rb
class FightGoneBadRepair
  NAME = 'Fight Gone Bad'.freeze

  NOTES = 'In this workout you move from each of 5 stations after a minute. ' \
          'This is a 5-minute round after which a 1-minute break is allowed before repeating. ' \
          'The clock does not reset or stop between exercises. ' \
          'On the call of "rotate," the athlete(s) must move to the next station immediately for a good score. ' \
          'One point is given for each rep, except on the rower where each calorie is 1 point.'.freeze

  # Ordered stations of one round, keyed by movement name; :movement is swapped for the record
  # before build. A minute per station, rep-counted except Row (calories) and Rest.
  STATIONS = [
    { movement: 'Wall-ball Shot', reps: 0, duration_seconds: 60, female_load: 14, male_load: 20, load_unit: :lb,
      female_distance: 9, male_distance: 10, distance_unit: :foot },
    { movement: 'Sumo Deadlift High Pull', reps: 0, duration_seconds: 60, female_load: 55, male_load: 75,
      load_unit: :lb },
    { movement: 'Box Jump', reps: 0, duration_seconds: 60, distance: 20, distance_unit: :inch },
    { movement: 'Push Press', reps: 0, duration_seconds: 60, female_load: 55, male_load: 75, load_unit: :lb },
    { movement: 'Row', calories: 0, duration_seconds: 60 },
    { movement: 'Rest', reps: 1, duration_seconds: 60 }
  ].freeze

  def initialize(output: $stdout)
    @output = output
  end

  def call
    ActiveRecord::Base.transaction do
      canonical = rebuild_canonical
      fold_duplicates_into(canonical)
    end
  end

  private

  attr_reader :output

  def rebuild_canonical
    workout = Workout.find_or_initialize_by(name: NAME)
    workout.segments.destroy_all
    workout.assign_attributes(score_type: :rep, notes: NOTES)
    segment = workout.segments.build(rounds: 3, position: 1)
    STATIONS.each_with_index do |station, index|
      segment.exercises.build(station.merge(movement: movement!(station[:movement]), position: index + 1))
    end
    workout.save!
    log("Rebuilt ##{workout.id} #{NAME.inspect} (content_key #{workout.content_key})")
    workout
  end

  def fold_duplicates_into(canonical)
    Workout.where(name: NAME).where.not(id: canonical.id).find_each do |dup|
      merge_workouts(dup, canonical)
      log("Folded ##{dup.id} into ##{canonical.id}")
    end
  end

  # Mirrors script/normalize_official_workout_names.rb: move the duplicate's schedules and logs
  # onto the canonical record, then delete it. The one duplicate here (#449) is scheduled on a
  # date the canonical record does not share, so no schedule-collision handling is needed.
  def merge_workouts(dup, canonical)
    dup.schedules.find_each { |schedule| schedule.update!(workout: canonical) }
    dup.logs.update_all(workout_id: canonical.id) # rubocop:disable Rails/SkipsModelValidations
    dup.destroy!
  end

  def movement!(name)
    Movement.find_by!(name: name)
  end

  def log(message)
    output.puts(message)
  end
end

FightGoneBadRepair.new.call if __FILE__ == $PROGRAM_NAME
