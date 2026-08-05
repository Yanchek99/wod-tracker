class OfficialWorkoutNameNormalizer
  RENAMES = {
    'CHAD1000x' => 'CHAD'
  }.freeze

  def initialize(output: $stdout)
    @output = output
  end

  def call
    ActiveRecord::Base.transaction do
      RENAMES.each { |legacy_name, official_name| normalize_name(legacy_name, official_name) }
    end
  end

  private

  attr_reader :output

  def normalize_name(legacy_name, official_name)
    legacy = workout_named(legacy_name)
    return log("Missing #{legacy_name}; skipped") if legacy.blank?

    official = workout_named(official_name)

    if official.present? && official != legacy
      merge_workouts(legacy, official)
      log("Merged #{legacy_name} into #{official_name}")
    else
      legacy.update!(name: official_name)
      log("Renamed #{legacy_name} to #{official_name}")
    end
  end

  def merge_workouts(legacy, official)
    legacy.schedules.find_each { |schedule| schedule.update!(workout: official) }
    legacy.logs.update_all(workout_id: official.id) # rubocop:disable Rails/SkipsModelValidations
    legacy.destroy!
  end

  def workout_named(name)
    Workout.where('LOWER(name) = ?', name.downcase).first
  end

  def log(message)
    output.puts(message)
  end
end

OfficialWorkoutNameNormalizer.new.call if __FILE__ == $PROGRAM_NAME
