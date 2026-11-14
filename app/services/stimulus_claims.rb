# What CrossFit's posted Stimulus and Strategy text says about a workout, as checkable claims:
# a finish window, round time, rounds target, working-set percentage, and per-movement loading,
# sets guide and time ceiling. `propose` drafts claims from the text with regular expressions (no
# LLM); a person confirms them in config/stimulus_claims.yml, which StimulusAccuracy reads.
module StimulusClaims
  PATH = Rails.root.join('config/stimulus_claims.yml')
  NUMBERS = %w[zero one two three four five six seven eight nine ten].each_with_index.to_h.freeze
  NUMBER = /\d+|#{NUMBERS.keys.join('|')}/
  LOADS = %w[light moderate heavy].freeze
  FINISH_RANGE = /finish(?:ing)?\s+between\s+(#{NUMBER})\s*(?:-|to)\s*(#{NUMBER})\s+minutes/i
  # "finish" or the whole workout only -- "complete the burpees in under 1 minute" is a
  # per-movement time, not a finish window.
  FINISH_CEILING = /(?:finish|getting through the entire workout)[^.]{0,60}?\bunder\s+(#{NUMBER})(?::(\d{2}))?\s*minutes?/i
  ROUND_RANGE = /(#{NUMBER})-?\s*to\s*(#{NUMBER})-minute rounds/i
  SETS_GUIDE = /in (#{NUMBER}) sets or (?:less|fewer)/i

  # source: crossfit_text (a daily workout's posted text -- matches in production only),
  # open_leaderboard, guide (L1/L2 training guides) or hero_page.
  Claim = Data.define(:workout_name, :claims, :source, :reviewed)

  module_function

  def load(path = PATH)
    entries(path).map do |entry|
      Claim.new(workout_name: entry.fetch('workout'), claims: entry.fetch('claims', {}), source: entry['source'],
                reviewed: entry['reviewed'])
    end
  end

  def entries(path = PATH)
    YAML.safe_load_file(path).fetch('claims', [])
  end

  # Rewrites the claims file, keeping its header comment.
  def write(entries, path = PATH)
    header = File.read(path)[/\A(?:#.*\n)*/]
    File.write(path, header + { 'claims' => entries }.to_yaml(line_width: 110).delete_prefix("---\n"))
  end

  # Claims a text makes, keyed by claim name; movement_names are the workout's movements.
  def propose(text, movement_names)
    sentences = text.to_s.split(/(?<=[.!?])\s+/)
    workout = {
      'finish_seconds' => finish_seconds(text), 'round_seconds' => round_seconds(text),
      'rounds' => rounds(text), 'percent_1rm' => percent(text)
    }
    workout.merge(movement_claims(sentences, movement_names)).compact
  end

  def finish_seconds(text)
    if (match = text.match(FINISH_RANGE))
      return [minutes(match[1]), minutes(match[2])]
    end

    match = text.match(FINISH_CEILING)
    [nil, clock(match[1], match[2])] if match
  end

  def round_seconds(text)
    if (match = text.match(ROUND_RANGE))
      return [minutes(match[1]), minutes(match[2])]
    end

    [nil, 60] if text.match?(/rounds? in (?:about )?a minute or less/i)
  end

  def rounds(text)
    match = text.match(/at least (\d+)(?:\s*-\s*(\d+))? rounds/i)
    [match[1].to_i, (match[2] || match[1]).to_i] if match
  end

  def percent(text)
    if (match = text.match(/(?:at or near|around|about)\s+(\d{2,3})% of your (?:1-rep|one-rep) max/i))
      return [match[1].to_i, match[1].to_i]
    end

    match = text.match(/at least (\d{2,3})% of your (?:1-rep|one-rep) max/i)
    [match[1].to_i, nil] if match
  end

  def movement_claims(sentences, movement_names)
    claims = { 'loading' => {}, 'sets_max' => {}, 'duration_max' => {} }
    movement_names.uniq.each do |name|
      sentences.select { |sentence| mentions?(sentence, name) }.each do |sentence|
        add(claims['loading'], name, loading(sentence))
        add(claims['sets_max'], name, sets_max(sentence))
        add(claims['duration_max'], name, duration(sentence))
      end
    end
    claims.transform_values(&:presence)
  end

  def add(hash, name, value)
    hash[name] ||= value unless value.nil?
  end

  def mentions?(sentence, name)
    stem = name.downcase.delete_suffix('s')
    sentence.downcase.include?(stem) || sentence.downcase.include?(stem.split.last.to_s)
  end

  def loading(sentence)
    found = LOADS.select { |load| sentence.match?(/\b#{load}\b/i) }
    found.first if found.one?
  end

  def sets_max(sentence)
    match = sentence.match(SETS_GUIDE)
    return number(match[1]) if match

    1 if sentence.match?(/\bunbroken\b/i) && !sentence.match?(/if you can go unbroken/i)
  end

  def duration(sentence)
    match = sentence.match(/in (?:under )?(\d+)(?::(\d{2}))?\s*(seconds?|minutes?)? or (?:less|faster)/i) ||
            sentence.match(/in under (\d+)(?::(\d{2}))?\s*(seconds?|minutes?)/i)
    return unless match
    return clock(match[1], match[2]) if match[2]

    match[3].to_s.start_with?('second') ? match[1].to_i : minutes(match[1])
  end

  def number(token)
    NUMBERS.fetch(token.downcase) { token.to_i }
  end

  def minutes(token)
    number(token) * 60
  end

  def clock(minutes, seconds)
    (number(minutes) * 60) + seconds.to_i
  end
end
