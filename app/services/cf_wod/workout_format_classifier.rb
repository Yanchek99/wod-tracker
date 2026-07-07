module CfWod
  class WorkoutFormatClassifier
    FOR_TIME = /\Afor time:?\z/i
    AMRAP = /\A(?:complete )?as many rounds(?: and reps)? as possible in (\d+) minutes? of:?\z/i
    EVERY_MINUTE = /\Aevery minute on the minute for (\d+) minutes?:?\z/i
    REP_LADDER = /\A(\d+(?:-\d+)+) reps for time of:?\z/i
    FIND_MAX = /\Afind a 1-rep-max (.+?)\.?\z/i

    def self.call(header_line) = new(header_line).classify

    def initialize(header_line)
      @header_line = header_line.to_s.strip
    end

    def classify
      case header_line
      when FOR_TIME then { score_type: :time }
      when AMRAP then { score_type: :rep, time: header_line.match(AMRAP)[1].to_i }
      when EVERY_MINUTE then emom_attributes
      when REP_LADDER then { score_type: :time, interval: header_line.match(REP_LADDER)[1] }
      when FIND_MAX then { score_type: :weight, lift_name: header_line.match(FIND_MAX)[1] }
      else
        raise WorkoutParser::UnparseableError, "unrecognized format header: #{header_line.inspect}"
      end
    end

    private

    attr_reader :header_line

    def emom_attributes
      minutes = header_line.match(EVERY_MINUTE)[1].to_i
      { score_type: :rep, time: minutes, rounds: minutes }
    end
  end
end
