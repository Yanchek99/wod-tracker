# The reference table the intended-stimulus calculator reads (config/stimulus_reference.yml):
# paces and reference loads by bucket -- barbell lift family, implement, gymnastics skill level,
# monostructural movement -- for the Rx gym athlete, plus the calculation constants. Plain data,
# reviewed in PRs -- see the YAML header for sources.
class StimulusReference
  PATH = Rails.root.join('config/stimulus_reference.yml')
  INCHES = { 'inch' => 1.0, 'foot' => 12.0, 'meter' => 39.37 }.freeze

  # What the calculator needs for one movement. paces: { unit => seconds } or
  # { unit => { load class => seconds } }. basis: 'barbell' (loading against reference_load, a
  # 1RM), 'implement' (against reference_load, the typical load) or nil (no loading).
  # typical_height: inches, or nil. extra_seconds: added to each rep (components).
  Profile = Data.define(:bucket, :paces, :basis, :reference_load, :light_below, :typical_height,
                        :extra_seconds, :source) do
    # Seconds per unit (rep, meter, calorie, second; a foot is read as a meter). A
    # load-dependent pace needs a load class; nil when the profile has no pace for it.
    def seconds_per(unit, loading)
      unit = unit.to_s
      return seconds_per('meter', loading)&.*(0.3048) if unit == 'foot'

      seconds = pace_for(paces[unit], loading)
      seconds && unit == 'rep' ? seconds + extra_seconds : seconds
    end

    def pace_for(pace, loading)
      pace.is_a?(Hash) ? pace[loading.to_s]&.to_f : pace&.to_f
    end
  end

  attr_reader :data

  def self.current
    @current ||= new(YAML.safe_load_file(PATH))
  end

  def self.inches(value, unit)
    value.to_f * INCHES.fetch(unit.to_s) if value && INCHES.key?(unit.to_s)
  end

  # A { 'value', 'unit' } height from the table, in inches; nil without one.
  def self.height_inches(height)
    inches(height['value'], height['unit']) if height
  end

  def initialize(data)
    @data = data
    @constants = data.fetch('constants', {})
  end

  # The movement's profile, or nil when no bucket fits it (the calculator then leaves it blank).
  def profile(movement)
    Bucket.new(self, movement).profile
  end

  def constant(key)
    @constants.fetch(key.to_s)
  end

  def section(key)
    data.fetch(key.to_s, {})
  end
end
