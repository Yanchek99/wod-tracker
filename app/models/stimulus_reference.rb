# The reference table the intended-stimulus calculator reads (config/stimulus_reference.yml):
# per-movement paces and reference loads for the Rx gym athlete, lift-class light boundaries,
# and the calculation constants. Plain data, reviewed in PRs -- see the YAML header for sources.
class StimulusReference
  PATH = Rails.root.join('config/stimulus_reference.yml')

  # paces: { unit => seconds } or { unit => { load class => seconds } }.
  Entry = Data.define(:name, :paces, :reference_load, :lift_class, :source) do
    # Seconds per unit (rep, meter, calorie, second). A load-dependent pace needs a load class;
    # nil when the entry has no pace for that unit or class.
    def seconds_per(unit, loading)
      pace = paces[unit.to_s]
      pace.is_a?(Hash) ? pace[loading.to_s]&.to_f : pace&.to_f
    end
  end

  attr_reader :movements

  def self.current
    @current ||= new(YAML.safe_load_file(PATH))
  end

  def initialize(data)
    @constants = data.fetch('constants', {})
    @lift_classes = data.fetch('lift_classes', {})
    @movements = data.fetch('movements', {}).to_h do |name, attrs|
      [name, Entry.new(name:, paces: attrs.fetch('paces', {}), reference_load: attrs['reference_load'],
                       lift_class: attrs['lift_class'], source: attrs['source'])]
    end
  end

  def movement(name)
    movements[name]
  end

  def constant(key)
    @constants.fetch(key.to_s)
  end

  def light_boundary(lift_class)
    @lift_classes.dig(lift_class.to_s, 'light_below')&.to_f
  end
end
