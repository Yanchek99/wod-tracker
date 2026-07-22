module CfWod
  class LoadBearingMovement
    BARBELL_FAMILY_MOVEMENTS = [
      'Back Squat', 'Front Squat', 'Overhead Squat', 'Squat Clean', 'Squat Clean Thruster',
      'Deadlift', 'Stiff-legged Deadlift', 'Sumo Deadlift', 'Sumo Deadlift High Pull',
      'Snatch', 'Power Snatch', 'Hang Snatch', 'Squat Snatch', 'Split Snatch', 'Muscle Snatch',
      'Clean', 'Power Clean', 'Hang Clean', 'Hang Power Clean', 'Hang Squat Clean', 'Split Clean',
      'Clean and Jerk', 'Clean and Push Jerk', 'Hang Clean and Push Jerk', 'Power Clean and Split Jerk',
      'Jerk', 'Push Jerk', 'Split Jerk', 'Tempo Jerk', 'Push Press', 'Thruster', 'Bench Press'
    ].freeze
    BARBELL_CUE_PATTERN = /overhead|front-rack|back-rack/i

    def self.call(movement, raw_text: nil)
      BARBELL_FAMILY_MOVEMENTS.include?(movement.name) || raw_text.to_s.match?(BARBELL_CUE_PATTERN)
    end
  end
end
