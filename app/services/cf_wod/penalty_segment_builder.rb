module CfWod
  class PenaltySegmentBuilder
    EXTRACTION = /(?:complete|do|perform)\s+(?<reps>\d+)\s+(?<movement>[^.]+?)(?:\s+with\b|\s+before\b|\z)/i

    def self.build(workout, position, trigger_line) = new(workout, position, trigger_line).build

    def initialize(workout, position, trigger_line)
      @workout = workout
      @position = position
      @trigger_line = trigger_line
    end

    def build
      segment = workout.segments.build(position: position, name: trigger_line[/\A[^,]+/])
      attach_exercise(segment)
      segment
    end

    private

    attr_reader :workout, :position, :trigger_line

    def attach_exercise(segment)
      match = EXTRACTION.match(trigger_line)
      return unless match

      movement_match = MovementMatcher.match(match[:movement])
      return unless movement_match.movement

      segment.exercises.build(movement: movement_match.movement, position: 1, reps: match[:reps].to_i)
    end
  end
end
