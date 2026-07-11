module CfWod
  class WorkoutParser
    class UnparseableError < StandardError; end

    def self.call(wod_page) = new(wod_page).parse

    def initialize(wod_page)
      @wod_page = wod_page
    end

    def parse
      lines = wod_page.body_text.split("\n")
      find_named_workout(lines) || parse_from_prose(lines)
    end

    private

    attr_reader :wod_page

    def parse_from_prose(lines)
      header, body = extract_header_and_body(lines)
      attrs = WorkoutFormatClassifier.call(header)
      workout = Workout.new(name: "CF-#{wod_page.slug}", **attrs.except(:lift_name, :set_reps))
      build_workout_content(workout, attrs, body)
      validate_workout!(workout)
      find_content_duplicate(workout) || workout
    end

    # A named/hero workout (e.g. "Eva Strong") repeats its exact catalog title on the first
    # line, ahead of the real format header. Its prescription is already correctly modeled
    # under that name, so return the existing Workout directly rather than re-deriving the
    # same content from fragile prose.
    def find_named_workout(lines)
      title = lines.first.to_s.strip
      return nil if title.blank? || recognized_header?(title)

      Workout.find_by(name: title)
    end

    # Content identifies a workout (see WorkoutFingerprint): if the freshly parsed workout's
    # prescription matches one already in the catalog under a different name, return that
    # canonical record instead of a duplicate.
    def find_content_duplicate(workout)
      key = workout.content_fingerprint
      Workout.find_by(content_key: key) if key
    end

    # Falls back to skipping past a not-yet-cataloged title line (and blank separators) to
    # reach the real format header, rather than assuming line 1 is always the header. Falls
    # back to line 1 when nothing in the body classifies, so the original error still reports
    # the true header line.
    def extract_header_and_body(lines)
      index = lines.index { |line| recognized_header?(line) }
      return [lines.first, lines.drop(1).join("\n")] unless index

      [lines[index], lines[(index + 1)..].join("\n")]
    end

    def recognized_header?(line)
      WorkoutFormatClassifier.call(line)
      true
    rescue UnparseableError
      false
    end

    def build_workout_content(workout, attrs, body)
      if attrs[:lift_name]
        build_max_finding_exercise(workout, attrs[:lift_name], attrs[:set_reps] || 1)
        # Unlike build_from_body, nothing here structurally models the trailing body text (this
        # branch never reaches PartSplitter), so none of it is a duplicate of parsed data -- keep
        # it as notes rather than dropping it.
        workout.notes = normalize_leftover_body(body)
      else
        build_from_body(workout, body.to_s)
      end
    end

    def validate_workout!(workout)
      raise UnparseableError, "built workout failed validation: #{workout.errors.full_messages.join(', ')}" unless workout.valid?
    end

    def build_max_finding_exercise(workout, lift_name, reps)
      movement = lookup_movement!(lift_name)
      workout.exercises.build(movement: movement, position: 1, reps: reps, load: 0)
    end

    def build_from_body(workout, body)
      split = PartSplitter.call(body)
      parts = AscendingLadderPartNormalizer.call(workout, split[:parts])
      exercise_lines = build_exercise_lines(workout, parts)
      workout.notes = split[:notes]
      return unless split[:prescription_text]

      clauses = PrescriptionClauseParser.call(split[:prescription_text])
      PrescriptionClauseAssigner.call(exercise_lines, clauses)
    end

    def normalize_leftover_body(body)
      body.to_s.split("\n").map(&:strip).compact_blank.join("\n").presence
    end

    def build_exercise_lines(workout, parts)
      top_level_position = 0
      exercise_lines = []

      parts.each do |part|
        if part[:segment]
          top_level_position += 1
          segment = workout.segments.build(name: part[:name], time_seconds: part[:time_seconds],
                                           rounds: part[:rounds], position: top_level_position)
          part[:lines].each_with_index do |line, index|
            exercise_lines << build_exercise_line(workout, line, position: index + 1, segment: segment)
          end
        else
          part[:lines].each do |line|
            top_level_position += 1
            exercise_lines << build_exercise_line(workout, line, position: top_level_position)
          end
        end
      end

      exercise_lines
    end

    def build_exercise_line(workout, line, position:, segment: nil)
      attrs = ExerciseLineParser.call(line)
      raise UnparseableError, "unrecognized exercise line: #{line.inspect}" unless attrs

      movement = lookup_movement!(attrs[:movement_name])
      exercise = workout.exercises.build(attrs.except(:movement_name).merge(movement: movement, position: position,
                                                                            segment: segment))
      { exercise: exercise, raw_line: line }
    end

    def lookup_movement!(name)
      MovementLookup.call(name) || raise(UnparseableError, "unrecognized movement: #{name.inspect}")
    end
  end
end
