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
      workout = Workout.new(name: "CF-#{wod_page.slug}", **attrs.except(:lift_name, :set_reps, :rounds, :time, :interval))
      exercise_lines = build_workout_content(workout, attrs, header_scheme(attrs), body)
      mark_manually_scored_lifts_load_bearing(workout, exercise_lines)
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

      Workout.find_by(name: title) || find_open_rerun_workout(title)
    end

    # Match loosely on the workout number rather than the exact "Open Workout 20.5" title wording,
    # anchored at the end so a trailing-letter variant like "15.1a" can't match a search for "15.1".
    def find_open_rerun_workout(title)
      (number = title[/\AOpen\b.*?(\d+\.\d+[a-z]?)/i, 1]) && Workout.where('name LIKE ?', "%#{number}").first
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

    def build_workout_content(workout, attrs, scheme, body)
      if attrs[:lift_name]
        build_max_finding_exercise(workout, attrs[:lift_name], attrs[:set_reps] || 1, scheme)
        # Unlike build_from_body, nothing here structurally models the trailing body text (this
        # branch never reaches PartSplitter), so none of it is a duplicate of parsed data -- keep
        # it as notes rather than dropping it.
        workout.notes = normalize_leftover_body(body)
        []
      else
        build_from_body(workout, body.to_s, scheme)
      end
    end

    def validate_workout!(workout)
      raise UnparseableError, "built workout failed validation: #{workout.errors.full_messages.join(', ')}" unless workout.valid?
    end

    # The format header (e.g. "21-15-9 reps for time:", "Every minute on the minute for 10
    # minutes:") classifies to a rounds/time/interval scheme that used to live on Workout itself;
    # amrap?/interval?/etc. now read it from a Segment instead (see Workout#governing_segment), so
    # it has to be carried onto whichever segment(s) this method's caller builds.
    def header_scheme(attrs)
      {
        rounds: attrs[:rounds],
        time_seconds: (attrs[:time] * 60 if attrs[:time].present?),
        interval_scheme: attrs[:interval]
      }.compact
    end

    def build_max_finding_exercise(workout, lift_name, reps, scheme)
      movement = lookup_movement!(lift_name)
      segment = workout.segments.build(position: 1, **scheme)
      segment.exercises.build(movement: movement, position: 1, reps: reps, load: 0)
    end

    def build_from_body(workout, body, scheme)
      split = PartSplitter.call(body)
      parts = AscendingLadderPartNormalizer.call(workout, split[:parts])
      exercise_lines = build_exercise_lines(workout, parts, scheme)
      workout.notes = split[:notes]
      return exercise_lines unless split[:prescription_text]

      clauses = PrescriptionClauseParser.call(split[:prescription_text])
      PrescriptionClauseAssigner.call(exercise_lines, clauses)
      exercise_lines
    end

    def mark_manually_scored_lifts_load_bearing(workout, exercise_lines)
      return unless manually_scored_lifting_workout?(workout)

      exercise_lines.each do |line|
        mark_load_bearing_exercise(line[:exercise], line[:raw_line])
      end
    end

    def manually_scored_lifting_workout?(workout)
      workout.score_type == 'weight' && !workout.calculated_lifting_score?
    end

    def mark_load_bearing_exercise(exercise, raw_line)
      return unless load_missing?(exercise)
      return unless LoadBearingMovement.call(exercise.movement, raw_text: raw_line)

      exercise.load = 0
    end

    def load_missing?(exercise)
      exercise.load.blank? && exercise.female_load.blank? && exercise.male_load.blank?
    end

    def normalize_leftover_body(body)
      body.to_s.split("\n").map(&:strip).compact_blank.join("\n").presence
    end

    def build_exercise_lines(workout, parts, scheme)
      validate_scheme_applies_once!(parts, scheme)
      top_level_position = 0
      exercise_lines = []

      parts.each do |part|
        top_level_position += 1
        segment = build_part_segment(workout, part, top_level_position, scheme)
        part[:lines].each_with_index do |line, index|
          exercise_lines << build_exercise_line(line, position: index + 1, segment: segment)
        end
      end

      exercise_lines
    end

    # A header scheme describes a single contiguous run of otherwise-flat exercise lines (see the
    # already-merged db/migrate/20260713120000_backfill_segments_for_top_level_exercises.rb, which
    # backfilled this same shape from existing data). More than one such run means the header
    # scheme can't unambiguously apply to any single segment.
    def validate_scheme_applies_once!(parts, scheme)
      return if scheme.blank?

      unscoped_runs = parts.count { |part| !part[:segment] }
      return if unscoped_runs <= 1

      raise UnparseableError,
            "workout header declares a scheme (#{scheme.inspect}) but has #{unscoped_runs} separate unscoped exercise runs"
    end

    # A schemed part (rounds/time-window) becomes its own named/scoped segment; a plain,
    # unschemed run of top-level exercise lines becomes an implicit segment carrying the header's
    # own scheme (if any -- validate_scheme_applies_once! already guarantees at most one such run).
    def build_part_segment(workout, part, position, scheme)
      if part[:segment]
        workout.segments.build(name: part[:name], time_seconds: part[:time_seconds], rounds: part[:rounds],
                               position: position)
      else
        workout.segments.build(position: position, **scheme)
      end
    end

    def build_exercise_line(line, position:, segment:)
      attrs = ExerciseLineParser.call(line)
      raise UnparseableError, "unrecognized exercise line: #{line.inspect}" unless attrs

      movement = lookup_movement!(attrs[:movement_name])
      exercise = segment.exercises.build(attrs.except(:movement_name).merge(movement: movement, position: position))
      { exercise: exercise, raw_line: line }
    end

    def lookup_movement!(name)
      MovementLookup.call(name) || raise(UnparseableError, "unrecognized movement: #{name.inspect}")
    end
  end
end
