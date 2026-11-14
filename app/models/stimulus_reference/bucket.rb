class StimulusReference
  # Which bucket of the reference table a movement falls in, from its own taxonomy: family,
  # equipment, skill level, primary function and name. A named override wins for the few
  # movements a bucket cannot describe.
  class Bucket
    FUNCTION_FAMILIES = { 'squat' => 'squat', 'hinge' => 'hinge', 'vertical_push' => 'press',
                          'horizontal_push' => 'press' }.freeze
    PROFILE_DEFAULTS = { basis: nil, reference_load: nil, light_below: nil, typical_height: nil, source: nil }.freeze

    def initialize(reference, movement)
      @reference = reference
      @movement = movement
      @override = reference.section(:overrides)[movement.name] || {}
    end

    def profile
      base = from_override || from_taxonomy || bare
      base&.with(paces: @override['paces'] || base.paces, extra_seconds:,
                 source: @override['source'] || base.source)
    end

    # Barbell lift family: snatch and clean by name, then jerk, then the primary function.
    def lift_family
      name = @movement.name.downcase
      return 'snatch' if name.include?('snatch')
      return 'clean' if name.include?('clean') || name.include?('ground to overhead')
      return 'jerk' if name.match?(/jerk|shoulder to overhead/)

      FUNCTION_FAMILIES[primary_function]
    end

    private

    def from_override
      return implement(@override['implement']) if @override['implement']

      lift(@override['lift_family']) if @override['lift_family']
    end

    def from_taxonomy
      case @movement.family
      when 'weightlifting' then @movement.equipment == 'barbell' ? lift(lift_family) : implement(@movement.equipment)
      when 'gymnastics' then gymnastics
      when 'monostructural' then monostructural
      end
    end

    # A named override with its own paces and no bucket (Rest).
    def bare
      build("override:#{@movement.name}", {}) if @override['paces']
    end

    def lift(family)
      attrs = @reference.section(:lift_families)[family]
      return unless attrs

      build("lift:#{family}", attrs['paces'], basis: 'barbell', reference_load: attrs['reference_load'],
                                              light_below: attrs['light_below'], source: attrs['source'])
    end

    def implement(equipment)
      attrs = @reference.section(:implements)[equipment]
      return unless attrs

      build("implement:#{equipment}", @reference.section(:implement_paces),
            basis: 'implement', reference_load: attrs['typical_load'], source: attrs['source'],
            typical_height: StimulusReference.height_inches(attrs['typical_height']))
    end

    def gymnastics
      attrs = @reference.section(:skill_levels)[@movement.skill_level]
      return unless attrs

      height = StimulusReference.height_inches(@reference.section(:typical_heights)[@movement.equipment])
      build("skill:#{@movement.skill_level}", attrs['paces'],
            source: @reference.section(:skill_levels_source), typical_height: height)
    end

    def monostructural
      attrs = @reference.section(:monostructural)[@movement.name]
      return build("mono:#{@movement.name}", attrs['paces'], source: attrs['source']) if attrs

      paces = @reference.section(:monostructural_by_equipment)[@movement.equipment || 'none']
      build("mono:#{@movement.equipment || 'none'}", paces, source: 'drafted -- owner review') if paces
    end

    def build(bucket, paces, **attrs)
      Profile.new(bucket:, paces: paces || {}, extra_seconds: 0, **PROFILE_DEFAULTS, **attrs)
    end

    def extra_seconds
      @reference.section(:components).sum { |key, seconds| @movement.name.include?(key) ? seconds.to_f : 0 }
    end

    def primary_function
      @movement.movement_function_roles.find(&:role_primary?)&.movement_function
    end
  end
end
