module CfWod
  class ExerciseLineParser
    MAX_REPS = /\AMax(?:imum)?[- ](.+)\z/i
    DISTANCE_THEN_MOVEMENT = /\A([\d,]+)[\s-](meters?|feet|foot|inches?)\s+(.+)\z/i
    MOVEMENT_THEN_DISTANCE = /\A([A-Za-z][A-Za-z '-]*?)\s+([\d,]+)\s+(meters?|feet|foot|inches?)\.?\z/i
    NUMBERED_REPS = /\A(\d+)\s+(.+)\z/
    BARE_MOVEMENT = /\A([A-Za-z][A-Za-z '-]*)\z/

    DISTANCE_UNITS = { 'meter' => :meter, 'meters' => :meter, 'foot' => :foot, 'feet' => :foot,
                       'inch' => :inch, 'inches' => :inch }.freeze

    def self.call(line) = new(line).parse

    def initialize(line)
      @line = line.to_s.strip
    end

    def parse
      case line
      when MAX_REPS then { movement_name: clean_name(line.match(MAX_REPS)[1]), reps: 0 }
      when DISTANCE_THEN_MOVEMENT then distance_then_movement_attributes
      when MOVEMENT_THEN_DISTANCE then movement_then_distance_attributes
      when NUMBERED_REPS then numbered_reps_attributes
      when BARE_MOVEMENT then { movement_name: clean_name(line), reps: 1 }
      end
    end

    private

    attr_reader :line

    def distance_then_movement_attributes
      value, unit, remaining = line.match(DISTANCE_THEN_MOVEMENT).captures
      { movement_name: clean_name(remaining), reps: 1, distance: value.delete(',').to_i,
        distance_unit: DISTANCE_UNITS.fetch(unit.downcase) }
    end

    def movement_then_distance_attributes
      movement, value, unit = line.match(MOVEMENT_THEN_DISTANCE).captures
      { movement_name: clean_name(movement), reps: 1, distance: value.delete(',').to_i,
        distance_unit: DISTANCE_UNITS.fetch(unit.downcase) }
    end

    def numbered_reps_attributes
      reps, remaining = line.match(NUMBERED_REPS).captures
      { movement_name: clean_name(remaining), reps: reps.to_i }
    end

    def clean_name(raw)
      raw.split(/,| with /i).first.strip
    end
  end
end
