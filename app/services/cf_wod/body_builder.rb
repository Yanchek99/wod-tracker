module CfWod
  class BodyBuilder
    def initialize(workout, body_text, format)
      @workout = workout
      @classifier = LineClassifier.new(body_text)
      @exercise_builder = ExerciseBuilder.new(format)
      @position = 0
      @last_single_exercise = nil
      @reasons = []
    end

    def build
      classifier.paragraphs.each { |paragraph| process_paragraph(paragraph) }
      reasons + exercise_builder.reasons
    end

    private

    attr_reader :workout, :classifier, :exercise_builder, :reasons
    attr_accessor :position, :last_single_exercise

    def process_paragraph(paragraph)
      lines = paragraph.split("\n").map(&:strip).reject(&:empty?)
      kinds = lines.map { |line| classifier.classify(line) }

      case paragraph_kind(kinds)
      when :segment then process_segment_block(lines, kinds)
      when :penalty then process_penalty_block(lines, kinds)
      when :gendered_load then process_gendered_load_block(paragraph)
      else process_plain_block(lines, kinds)
      end
    end

    def paragraph_kind(kinds)
      return :segment if kinds.include?(:segment_header)
      return :penalty if kinds.include?(:penalty_trigger)
      return :gendered_load if kinds.any? && kinds.all?(:gendered_load)

      :plain
    end

    def process_segment_block(lines, kinds)
      self.last_single_exercise = nil
      minutes = classifier.segment_header_minutes(lines[kinds.index(:segment_header)])
      self.position += 1
      segment = workout.segments.build(position: position, time_seconds: minutes && (minutes * 60))
      build_lines_onto(segment, lines, kinds)
    end

    def process_penalty_block(lines, kinds)
      self.last_single_exercise = nil
      trigger_line = lines[kinds.index(:penalty_trigger)]
      self.position += 1
      PenaltySegmentBuilder.build(workout, position, trigger_line)
      reasons << 'Event-triggered penalty segment; verify reps semantics'
    end

    def process_gendered_load_block(paragraph)
      unless last_single_exercise
        reasons << 'Male/female load could not be confidently attached to a single movement'
        return
      end

      result = GenderedLoadParser.parse(paragraph)
      ExerciseLoadAttacher.apply(last_single_exercise, result) if result
      self.last_single_exercise = nil
    end

    def process_plain_block(lines, kinds)
      built = build_lines_onto(workout, lines, kinds)
      self.last_single_exercise = built.size == 1 ? built.first : nil
    end

    def build_lines_onto(owner, lines, kinds)
      built = []
      local_position = owner.equal?(workout) ? nil : 0

      lines.each_with_index do |line, index|
        case kinds[index]
        when :movement
          local_position = advance_position(local_position)
          exercise = exercise_builder.build(owner, local_position, line)
          built << exercise if exercise
        when :rest
          local_position = advance_position(local_position)
          exercise_builder.build_rest(owner, local_position, classifier.rest_minutes(line))
        end
      end

      built
    end

    def advance_position(local_position)
      return local_position + 1 if local_position

      self.position += 1
    end
  end
end
