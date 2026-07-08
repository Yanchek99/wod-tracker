module CfWod
  class ExerciseLineParser
    MAX_REPS = /\AMax(?:imum)?[- ](.+)\z/i
    DISTANCE_THEN_MOVEMENT = /\A([\d,]+(?:\.\d+)?)[\s-](meters?|feet|foot|inches?|miles?)\s+(.+)\z/i
    MOVEMENT_THEN_DISTANCE = /\A([A-Za-z][A-Za-z '-]*?)\s+([\d,]+(?:\.\d+)?)\s+(meters?|feet|foot|inches?|miles?)\.?\z/i
    REPS_MOVEMENT_TO_DISTANCE =
      /\A(\d+)\s+([A-Za-z][A-Za-z '-]*?)\s+to\s+(?:an?\s+)?([\d,]+(?:\.\d+)?)[\s-]+(meters?|feet|foot|inches?|miles?)\.?\z/i
    NUMBERED_REPS = /\A(\d+)\s+(.+)\z/
    BARE_MOVEMENT = /\A([A-Za-z][A-Za-z '-]*)\z/

    DISTANCE_UNITS = { 'meter' => :meter, 'meters' => :meter, 'foot' => :foot, 'feet' => :foot,
                       'inch' => :inch, 'inches' => :inch }.freeze

    # CrossFit prose gives mile distances no canonical distance_unit of their own (the model only
    # has meter/foot/inch) -- convert to meters at parse time instead, the same way LoadEquivalence
    # collapses kg/pood into canonical pounds. 1 mile ~ 1600m is the rounded figure CrossFit itself
    # uses on the gym floor, not the precise 1609.34m.
    METERS_PER_MILE = 1600

    def self.call(line) = new(line).parse

    def initialize(line)
      @line = line.to_s.strip
    end

    def parse
      case line
      when MAX_REPS then { movement_name: clean_name(line.match(MAX_REPS)[1]), reps: 0 }
      when DISTANCE_THEN_MOVEMENT then distance_then_movement_attributes
      when MOVEMENT_THEN_DISTANCE then movement_then_distance_attributes
      when REPS_MOVEMENT_TO_DISTANCE then reps_movement_to_distance_attributes
      when NUMBERED_REPS then numbered_reps_attributes
      when BARE_MOVEMENT then { movement_name: clean_name(line), reps: 1 }
      end
    end

    private

    attr_reader :line

    def distance_then_movement_attributes
      value, unit, remaining = line.match(DISTANCE_THEN_MOVEMENT).captures
      { movement_name: clean_name(remaining), reps: 1 }.merge(distance_attributes(value, unit))
    end

    def movement_then_distance_attributes
      movement, value, unit = line.match(MOVEMENT_THEN_DISTANCE).captures
      { movement_name: clean_name(movement), reps: 1 }.merge(distance_attributes(value, unit))
    end

    def distance_attributes(raw_value, raw_unit)
      return mile_distance_attributes(raw_value) if raw_unit.downcase.start_with?('mile')

      { distance: raw_value.delete(',').to_i, distance_unit: DISTANCE_UNITS.fetch(raw_unit.downcase) }
    end

    def mile_distance_attributes(raw_value)
      miles = raw_value.delete(',').to_f
      { distance: (miles * METERS_PER_MILE).round, distance_unit: :meter }
    end

    def reps_movement_to_distance_attributes
      reps, movement, value, unit = line.match(REPS_MOVEMENT_TO_DISTANCE).captures
      { movement_name: clean_name(movement), reps: reps.to_i }.merge(distance_attributes(value, unit))
    end

    def numbered_reps_attributes
      reps, remaining = line.match(NUMBERED_REPS).captures
      { movement_name: clean_name(remaining), reps: reps.to_i }
    end

    def clean_name(raw)
      raw.split(/,| with |\s+\(/i).first.strip
    end
  end
end
