module CfWod
  class LoadBearingMovement
    BARBELL_FAMILY_MOVEMENTS = [
      'Back Squat', 'Front Squat', 'Overhead Squat', 'Squat Clean', 'Squat Clean Thruster',
      'Deadlift', 'Sumo Deadlift High Pull',
      'Snatch', 'Power Snatch', 'Squat Snatch', 'Muscle Snatch',
      'Clean', 'Power Clean', 'Hang Clean', 'Hang Power Clean', 'Hang Squat Clean', 'Clean and Jerk',
      'Jerk', 'Push Jerk', 'Split Jerk', 'Push Press', 'Thruster', 'Bench Press'
    ].freeze
    BARBELL_CUE_PATTERN = /overhead|front-rack|back-rack/i

    def self.call(movement, raw_text: nil)
      BARBELL_FAMILY_MOVEMENTS.include?(movement.name) || raw_text.to_s.match?(BARBELL_CUE_PATTERN)
    end
  end
end
