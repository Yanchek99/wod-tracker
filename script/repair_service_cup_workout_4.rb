# One-off: repair "Service Cup Workout 4", where the import copied the Dumbbell Snatch's
# load (female 35 / male 50 lb) onto both Double-under stations too. The intended-stimulus
# notes only describe dumbbell loading for the snatch, so the double-unders should be
# bodyweight.
#
# Run once: bin/rails runner script/repair_service_cup_workout_4.rb
class ServiceCupWorkout4Repair
  WORKOUT_NAME = 'Service Cup Workout 4'.freeze
  WEIGHTED_MOVEMENT = 'Double-under'.freeze

  def initialize(output: $stdout)
    @output = output
  end

  def call
    workout = Workout.find_by!(name: WORKOUT_NAME)
    exercises = workout.segments.flat_map(&:exercises).select { |e| e.movement.name == WEIGHTED_MOVEMENT }
    raise "expected Double-under exercises on #{WORKOUT_NAME.inspect}" if exercises.empty?

    exercises.each do |exercise|
      exercise.update!(female_load: nil, male_load: nil)
      log("Cleared load on ##{exercise.id} (#{WEIGHTED_MOVEMENT}, position #{exercise.position})")
    end
  end

  private

  attr_reader :output

  def log(message)
    output.puts(message)
  end
end

ServiceCupWorkout4Repair.new.call if __FILE__ == $PROGRAM_NAME
