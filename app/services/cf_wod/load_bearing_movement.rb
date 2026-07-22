module CfWod
  class LoadBearingMovement
    LOAD_BEARING_MOVEMENTS = [
      'Back Squat', 'Barbell Back-rack Step-up', 'Barbell Carry', 'Barbell Front-rack Lunge',
      'Barbell Step-up', 'Bench Press', 'Bent-over Row', 'Clean', 'Clean and Jerk', 'Clean and Push Jerk',
      'Clean Squat',
      'Deadlift', 'Stiff-legged Deadlift', 'Sumo Deadlift', 'Sumo Deadlift High Pull',
      'Front Squat', 'Good Morning', 'Ground to Overhead',
      'Hang Clean', 'Hang Clean and Push Jerk', 'Hang Power Clean', 'Hang Power Snatch', 'Hang Snatch',
      'Hang Squat Clean',
      'Jerk', 'Muscle Snatch', 'Overhead Squat', 'Overhead Walk', 'Overhead Walking Lunge',
      'Power Clean', 'Power Clean and Split Jerk', 'Power Snatch', 'Push Jerk', 'Push Press',
      'Shoulder Press', 'Shoulder to Overhead', 'Snatch', 'Snatch Balance', 'Sots Press',
      'Split Clean', 'Split Jerk', 'Split Snatch', 'Squat Clean', 'Squat Clean Thruster', 'Squat Snatch',
      'Tempo Jerk', 'Thruster', 'Zercher Squat'
    ].freeze
    BARBELL_CUE_PATTERN = /overhead|front-rack|back-rack/i

    def self.call(movement, raw_text: nil)
      LOAD_BEARING_MOVEMENTS.include?(movement.name) || raw_text.to_s.match?(BARBELL_CUE_PATTERN)
    end
  end
end
