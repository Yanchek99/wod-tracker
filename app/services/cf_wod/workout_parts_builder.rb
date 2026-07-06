module CfWod
  class WorkoutPartsBuilder
    def initialize(workout, body_text, format)
      @workout = workout
      @classifier = LineClassifier.new(body_text)
      @exercise_builder = ExerciseBuilder.new(format)
      @workout_position = PositionCounter.new
      @last_single_exercise = nil
      @reasons = []
    end

    def build
      classifier.paragraphs.each { |paragraph| process_paragraph(paragraph) }
      reasons + exercise_builder.reasons
    end

    private

    attr_reader :workout, :classifier, :exercise_builder, :reasons, :workout_position
    attr_accessor :last_single_exercise

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
      segment = workout.segments.build(position: workout_position.next!, time_seconds: minutes && (minutes * 60))
      build_lines_onto(segment, lines, kinds)
    end

    def process_penalty_block(lines, kinds)
      self.last_single_exercise = nil
      trigger_line = lines[kinds.index(:penalty_trigger)]
      PenaltySegmentBuilder.build(workout, workout_position.next!, trigger_line)
      reasons << 'Event-triggered penalty segment; verify reps semantics'
    end

    def process_gendered_load_block(paragraph)
      unless last_single_exercise
        reasons << 'Male/female load could not be confidently attached to a single movement'
        return
      end

      result = GenderedLoadParser.parse(paragraph)
      ExerciseLoadAssigner.assign(last_single_exercise, result) if result
      self.last_single_exercise = nil
    end

    def process_plain_block(lines, kinds)
      built = build_lines_onto(workout, lines, kinds)
      self.last_single_exercise = built.size == 1 ? built.first : nil
    end

    def build_lines_onto(owner, lines, kinds)
      built = []
      local_position = owner.equal?(workout) ? nil : PositionCounter.new

      lines.each_with_index do |line, index|
        case kinds[index]
        when :movement
          position = counter_for(local_position).next!
          exercise = build_exercise(owner, position, line)
          built << exercise if exercise
        when :rest
          position = counter_for(local_position).next!
          owner.exercises.build(exercise_builder.build_rest_attributes(position, classifier.rest_minutes(line)))
        end
      end

      built
    end

    def build_exercise(owner, position, line)
      attributes, inline_load = exercise_builder.build_attributes(position, line)
      return unless attributes

      exercise = owner.exercises.build(attributes)
      ExerciseLoadAssigner.assign(exercise, inline_load) if inline_load
      exercise
    end

    def counter_for(local_position)
      local_position || workout_position
    end
  end
end
