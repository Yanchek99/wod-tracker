class OfficialMovementNameNormalizer
  RENAMES = {
    'Double Under' => 'Double-under',
    'Kettlebell Swings' => 'Kettlebell Swing',
    'Pistol' => 'Single-leg Squat (Pistol)',
    'Strict Toes to Bar' => 'Strict Toes-to-bar'
  }.freeze

  BAD_MOVEMENTS = ['Press Jerk'].freeze

  def initialize(output: $stdout)
    @output = output
  end

  def call
    ActiveRecord::Base.transaction do
      RENAMES.each { |legacy_name, official_name| normalize_name(legacy_name, official_name) }
      BAD_MOVEMENTS.each { |name| remove_bad_movement(name) }
    end
  end

  private

  attr_reader :output

  def normalize_name(legacy_name, official_name)
    legacy = movement_named(legacy_name)
    return log("Missing #{legacy_name}; skipped") if legacy.blank?

    official = movement_named(official_name)

    if official.present? && official != legacy
      merge_movements(legacy, official)
      log("Merged #{legacy_name} into #{official_name}")
    else
      legacy.update!(name: official_name)
      log("Renamed #{legacy_name} to #{official_name}")
    end
  end

  def merge_movements(legacy, official)
    Exercise.unscoped.where(movement_id: legacy.id).find_each do |exercise|
      exercise.update!(movement: official)
    end

    MovementLog.unscoped.where(movement_id: legacy.id).find_each do |movement_log|
      movement_log.update!(movement: official)
    end

    legacy.destroy!
  end

  def remove_bad_movement(name)
    movement = movement_named(name)
    return log("Missing #{name}; skipped") if movement.blank?

    if movement.exercises.exists? || movement.movement_logs.exists?
      log("Referenced #{name}; skipped")
    else
      movement.destroy!
      log("Deleted #{name}")
    end
  end

  def movement_named(name)
    Movement.where('LOWER(name) = ?', name.downcase).first
  end

  def log(message)
    output.puts(message)
  end
end

OfficialMovementNameNormalizer.new.call if __FILE__ == $PROGRAM_NAME
