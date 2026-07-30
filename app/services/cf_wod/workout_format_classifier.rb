module CfWod
  class WorkoutFormatClassifier
    FOR_TIME = /\Afor time:?\z/i
    FOR_LOAD = /\Afor load:?\z/i
    AMRAP = /\A(?:complete )?as many (?:rounds(?: and reps)?|reps) as possible in (\d+) minutes? of:?\z/i
    ROUNDS_AMRAP = /\Afor (\d+) rounds,\s*(?:complete )?as many (?:rounds(?: and reps)?|reps) as possible in (\d+) minutes? of:?\z/i
    EVERY_MINUTE = /\Aevery minute on the minute for (\d+) minutes?:?\z/i
    REP_LADDER = /\A(\d+(?:-\d+)+) reps for time of:?\z/i
    FIND_MAX = /\Afind a (\d+)-rep-max (.+?)\.?\z/i
    TIME_WINDOWED = /\Aon a (\d+)-minute clock for total reps:?\z/i
    ROUNDS_FOR_TIME = /\A(\d+) rounds? for time(?: of)?:?\z/i
    SET_BASED_LIFTING = /\A(.+?) (\d+(?:-\d+)+)\s+reps\z/i
    EMOM_SHORT = /\Aemom (\d+)\z/i
    ON_THE_CLOCK_ROUNDS = /\A(?:on|every) the (\d+):00 x (\d+) rounds?:?\z/i
    PLAIN_ROUNDS = /\A(\d+) rounds?:?\z/i
    PARTNER_PREFIX = /\Awith a partner,\s*/i

    FORMATS = [
      [FOR_TIME, :for_time_attributes],
      [FOR_LOAD, :for_load_attributes],
      [AMRAP, :amrap_attributes],
      [ROUNDS_AMRAP, :rounds_amrap_attributes],
      [EVERY_MINUTE, :emom_attributes],
      [REP_LADDER, :rep_ladder_attributes],
      [FIND_MAX, :find_max_attributes],
      [TIME_WINDOWED, :time_windowed_attributes],
      [ROUNDS_FOR_TIME, :rounds_for_time_attributes],
      [SET_BASED_LIFTING, :set_based_lifting_attributes],
      [EMOM_SHORT, :emom_short_attributes],
      [ON_THE_CLOCK_ROUNDS, :on_the_clock_rounds_attributes],
      [PLAIN_ROUNDS, :plain_rounds_attributes]
    ].freeze

    def self.call(header_line) = new(header_line).classify

    def initialize(header_line)
      stripped = header_line.to_s.strip
      @team_size = stripped.match?(PARTNER_PREFIX) ? 2 : nil
      @header_line = stripped.sub(PARTNER_PREFIX, '')
    end

    def classify
      _pattern, handler = FORMATS.find { |pattern, _handler| header_line.match?(pattern) }
      raise WorkoutParser::UnparseableError, "unrecognized format header: #{header_line.inspect}" unless handler

      attrs = send(handler)
      team_size ? attrs.merge(team_size: team_size) : attrs
    end

    private

    attr_reader :header_line, :team_size

    def for_time_attributes
      { score_type: :time }
    end

    def for_load_attributes
      { score_type: :weight }
    end

    def amrap_attributes
      { score_type: :rep, time: header_line.match(AMRAP)[1].to_i }
    end

    def rounds_amrap_attributes
      rounds, minutes = header_line.match(ROUNDS_AMRAP).captures
      { score_type: :rep, rounds: rounds.to_i, time: minutes.to_i }
    end

    def emom_attributes
      minutes = header_line.match(EVERY_MINUTE)[1].to_i
      { score_type: :rep, time: minutes, rounds: minutes }
    end

    def rep_ladder_attributes
      { score_type: :time, interval: header_line.match(REP_LADDER)[1] }
    end

    def find_max_attributes
      reps, lift_name = header_line.match(FIND_MAX).captures
      { score_type: :weight, lift_name: lift_name, set_reps: reps.to_i }
    end

    def time_windowed_attributes
      { score_type: :rep, time: header_line.match(TIME_WINDOWED)[1].to_i }
    end

    def rounds_for_time_attributes
      { score_type: :time, rounds: header_line.match(ROUNDS_FOR_TIME)[1].to_i }
    end

    # e.g. "Front squat 3-3-3-3-3 reps" -- a fixed number of sets at a constant reps-per-set,
    # scored by load (Workout#set_based_lifting?). A varying scheme (e.g. "5-3-3-1-1") doesn't fit
    # this app's single reps-per-set modeling, so it fails closed rather than guessing which set's
    # rep count to use.
    def set_based_lifting_attributes
      lift_name, scheme = header_line.match(SET_BASED_LIFTING).captures
      reps_per_set = scheme.split('-').map(&:to_i)
      raise WorkoutParser::UnparseableError, "unsupported varying rep scheme: #{scheme.inspect}" unless reps_per_set.uniq.one?

      { score_type: :weight, rounds: reps_per_set.length, lift_name: lift_name, set_reps: reps_per_set.first }
    end

    def emom_short_attributes
      minutes = header_line.match(EMOM_SHORT)[1].to_i
      { score_type: :rep, time: minutes, rounds: minutes }
    end

    def on_the_clock_rounds_attributes
      minutes_per_round, rounds = header_line.match(ON_THE_CLOCK_ROUNDS).captures
      { score_type: :rep, time: minutes_per_round.to_i * rounds.to_i, rounds: rounds.to_i }
    end

    def plain_rounds_attributes
      { score_type: :time, rounds: header_line.match(PLAIN_ROUNDS)[1].to_i }
    end
  end
end
