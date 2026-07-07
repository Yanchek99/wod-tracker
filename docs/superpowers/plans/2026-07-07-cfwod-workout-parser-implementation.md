# CfWod::WorkoutParser Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `CfWod::WorkoutParser`, which turns a `CfWod::WodPage`'s free-form `body_text` into a built (unsaved) `Workout` graph, per [issue #1675](https://github.com/matthewyanchek/wod-tracker/issues/1675) and the approved design at `docs/superpowers/specs/2026-07-07-cfwod-workout-parser-design.md`.

**Architecture:** One orchestrator (`WorkoutParser`) and six single-purpose collaborators (`WorkoutFormatClassifier`, `PartSplitter`, `ExerciseLineParser`, `MovementLookup`, `PrescriptionClauseParser`, `PrescriptionClauseAssigner`), all flat files under `app/services/cf_wod/`, matching the existing `Fetcher`/`PageParser`/`WodPage` sibling convention. Any collaborator can raise `CfWod::WorkoutParser::UnparseableError` directly (the same pattern `PageParser` already uses for `Fetcher::UnrecognizedTemplateError`).

**Tech Stack:** Ruby 4.0.5, Rails 8.1, Minitest with fixtures, existing `Movement`/`Workout`/`Exercise`/`Segment` models.

## Global Constraints

- Ruby 4.0.5 / Rails 8.1 / `TargetRubyVersion: 3.4` per `.rubocop.yml`.
- `Layout/LineLength: Max: 160` — keep all new lines under 160 characters.
- `Style/FrozenStringLiteralComment: Enabled: false` — do not add `# frozen_string_literal: true` comments (matches existing `app/services/cf_wod/*.rb` files, which have none).
- New files live flat under `app/services/cf_wod/`, one class per file, matching `Fetcher`/`PageParser`/`WodPage`.
- Run only the affected test file per task (`bin/rails test test/services/cf_wod/<file>_test.rb`), per this repo's `CLAUDE.md`. Do not run the full suite until the final task.
- Every new/modified file must pass `bundle exec rubocop --parallel` on that file before committing.
- Never `find_or_create_by` a `Movement` from this parser — `MovementLookup` only ever reads.
- This parser never persists anything (no `.save`) — every task builds an in-memory graph and asserts on it directly, or on `.valid?`/`.errors`.

---

## Task 1: Add movement test fixtures needed by the corpus

The corpus tasks (9-16) need `Movement` fixtures the strict lookup can match. `test/fixtures/movements.yml` currently has 9 entries (`hspu`, `pistol`, `pullup`, `pushup`, `run`, `row`, `squat`, `thruster`, `back_squat`) used by unrelated existing tests — do not touch those. Add 15 new entries under new keys.

**Files:**
- Modify: `test/fixtures/movements.yml`

**Interfaces:**
- Produces: fixture accessors `movements(:power_snatch)`, `movements(:overhead_walking_lunge)`, `movements(:rope_climb)`, `movements(:sled_drag)`, `movements(:pull_up)`, `movements(:burpee)`, `movements(:handstand_push_up)`, `movements(:single_leg_squat)`, `movements(:freestanding_shoulder_tap)`, `movements(:skin_the_cat)`, `movements(:l_pull_up)`, `movements(:deficit_push_up)`, `movements(:deadlift)`, `movements(:wall_ball_shot)`, `movements(:box_jump)` — each name is exactly what `MovementLookup`'s mechanical normalization will produce from the corpus prose (Task 3 pins down the normalization algorithm; these names were derived by hand-tracing it against every corpus line).

- [ ] **Step 1: Add the new fixture entries**

Append to `test/fixtures/movements.yml` (leave the existing 9 entries untouched):

```yaml
power_snatch:
  name: Power Snatch

overhead_walking_lunge:
  name: Overhead Walking Lunge

rope_climb:
  name: Rope Climb

sled_drag:
  name: Sled Drag

pull_up:
  name: Pull-up

burpee:
  name: Burpee

handstand_push_up:
  name: Handstand Push-up

single_leg_squat:
  name: Single-leg Squat

freestanding_shoulder_tap:
  name: Freestanding Shoulder Tap

skin_the_cat:
  name: Skin-the-cat

l_pull_up:
  name: L Pull-up

deficit_push_up:
  name: Deficit Push-up

deadlift:
  name: Deadlift

wall_ball_shot:
  name: Wall-ball Shot

box_jump:
  name: Box Jump
```

- [ ] **Step 2: Verify fixtures load without error**

Run: `bin/rails test test/services/cf_wod/fetcher_test.rb`
Expected: PASS (this existing test file loads `fixtures :all` via `test_helper.rb`; a syntax or uniqueness error in `movements.yml` would fail every test, so a clean pass here proves the new YAML is valid).

- [ ] **Step 3: Commit**

```bash
git add test/fixtures/movements.yml
git commit -m "Add movement fixtures for the CfWod::WorkoutParser corpus"
```

---

## Task 2: WorkoutParser error shell + WorkoutFormatClassifier

`WorkoutFormatClassifier` reads the WOD's header sentence and derives workout-level scoring attributes. It raises `WorkoutParser::UnparseableError` directly on an unrecognized header (same pattern as `PageParser` raising `Fetcher::UnrecognizedTemplateError`), so the `WorkoutParser` shell (just the error class) must exist first.

**Files:**
- Create: `app/services/cf_wod/workout_parser.rb`
- Create: `app/services/cf_wod/workout_format_classifier.rb`
- Test: `test/services/cf_wod/workout_format_classifier_test.rb`

**Interfaces:**
- Produces: `CfWod::WorkoutParser::UnparseableError` (a `StandardError` subclass).
- Produces: `CfWod::WorkoutFormatClassifier.call(header_line) -> Hash` with keys among `{ score_type:, time:, rounds:, interval:, lift_name: }` (only the keys relevant to that header are present), or raises `CfWod::WorkoutParser::UnparseableError`.

- [ ] **Step 1: Write the failing test**

Create `test/services/cf_wod/workout_format_classifier_test.rb`:

```ruby
require 'test_helper'

module CfWod
  class WorkoutFormatClassifierTest < ActiveSupport::TestCase
    test 'classifies a for-time header' do
      assert_equal({ score_type: :time }, WorkoutFormatClassifier.call('For time:'))
    end

    test 'classifies an AMRAP header, extracting the time cap' do
      result = WorkoutFormatClassifier.call('Complete as many rounds as possible in 10 minutes of:')
      assert_equal({ score_type: :rep, time: 10 }, result)
    end

    test 'classifies an every-minute-on-the-minute header, extracting rounds and time' do
      result = WorkoutFormatClassifier.call('Every minute on the minute for 10 minutes:')
      assert_equal({ score_type: :rep, time: 10, rounds: 10 }, result)
    end

    test 'classifies a rep-ladder header, extracting the interval scheme' do
      result = WorkoutFormatClassifier.call('21-15-9 reps for time of:')
      assert_equal({ score_type: :time, interval: '21-15-9' }, result)
    end

    test 'classifies a find-a-1-rep-max header, extracting the lift name' do
      result = WorkoutFormatClassifier.call('Find a 1-rep-max back squat.')
      assert_equal({ score_type: :weight, lift_name: 'back squat' }, result)
    end

    test 'raises UnparseableError on an unrecognized header' do
      assert_raises(WorkoutParser::UnparseableError) do
        WorkoutFormatClassifier.call('Some completely novel workout format:')
      end
    end
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_format_classifier_test.rb`
Expected: FAIL with `NameError: uninitialized constant CfWod::WorkoutFormatClassifier`

- [ ] **Step 3: Create the WorkoutParser error shell**

Create `app/services/cf_wod/workout_parser.rb`:

```ruby
module CfWod
  class WorkoutParser
    class UnparseableError < StandardError; end
  end
end
```

- [ ] **Step 4: Implement WorkoutFormatClassifier**

Create `app/services/cf_wod/workout_format_classifier.rb`:

```ruby
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
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bin/rails test test/services/cf_wod/workout_format_classifier_test.rb`
Expected: PASS (6 runs, 0 failures)

- [ ] **Step 6: Rubocop and commit**

```bash
bundle exec rubocop app/services/cf_wod/workout_parser.rb app/services/cf_wod/workout_format_classifier.rb
git add app/services/cf_wod/workout_parser.rb app/services/cf_wod/workout_format_classifier.rb test/services/cf_wod/workout_format_classifier_test.rb
git commit -m "Add WorkoutParser error shell and WorkoutFormatClassifier"
```

---

## Task 3: MovementLookup

Strict, mechanical movement-name normalization and lookup — no `find_or_create_by`, no synonym table. Normalization: downcase, strip a trailing period, singularize (ActiveSupport's `String#singularize` acts on the trailing word), then capitalize only the first letter of each **space-separated** word (never after an internal hyphen — matching this catalog's own convention: `Bent-over Row`, `Handstand Push-up`, not `Bent-Over Row`/`Handstand Push-Up`).

**Files:**
- Create: `app/services/cf_wod/movement_lookup.rb`
- Test: `test/services/cf_wod/movement_lookup_test.rb`

**Interfaces:**
- Produces: `CfWod::MovementLookup.call(name_text) -> Movement | nil` (never raises; the caller in `WorkoutParser` decides whether `nil` is fatal).

- [ ] **Step 1: Write the failing test**

Create `test/services/cf_wod/movement_lookup_test.rb`:

```ruby
require 'test_helper'

module CfWod
  class MovementLookupTest < ActiveSupport::TestCase
    test 'normalizes a plural movement phrase and finds an exact match' do
      assert_equal movements(:power_snatch), MovementLookup.call('power snatches')
    end

    test 'singularizes without breaking a hyphenated suffix' do
      assert_equal movements(:sled_drag), MovementLookup.call('sled drag')
      assert_equal movements(:pull_up), MovementLookup.call('pull-ups')
    end

    test 'strips a trailing period' do
      assert_equal movements(:rope_climb), MovementLookup.call('Rope Climb.')
    end

    test 'returns nil for a name with no catalog match' do
      assert_nil MovementLookup.call('a completely unrecognized movement phrase')
    end
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/movement_lookup_test.rb`
Expected: FAIL with `NameError: uninitialized constant CfWod::MovementLookup`

- [ ] **Step 3: Implement MovementLookup**

Create `app/services/cf_wod/movement_lookup.rb`:

```ruby
module CfWod
  class MovementLookup
    def self.call(name) = new(name).lookup

    def initialize(name)
      @name = name
    end

    def lookup
      Movement.find_by(name: normalized_name)
    end

    private

    attr_reader :name

    def normalized_name
      base = name.to_s.strip.delete_suffix('.').downcase.singularize
      base.split(' ').map { |word| word.sub(/\A\w/) { |char| char.upcase } }.join(' ')
    end
  end
end
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bin/rails test test/services/cf_wod/movement_lookup_test.rb`
Expected: PASS (4 runs, 0 failures)

- [ ] **Step 5: Rubocop and commit**

```bash
bundle exec rubocop app/services/cf_wod/movement_lookup.rb
git add app/services/cf_wod/movement_lookup.rb test/services/cf_wod/movement_lookup_test.rb
git commit -m "Add strict MovementLookup"
```

---

## Task 4: ExerciseLineParser

Parses one prose line into exercise attributes. Tries patterns in order: bare "Max ..." (reps sentinel 0), a leading distance-then-movement ("200-meter run", "1,600-meter sled drag..."), a trailing movement-then-distance ("Run 800 meters"), a leading rep count ("5 power snatches"), or a bare movement name with no number (used in rep-ladder WODs like Fran, where reps are governed by the ladder itself — reps default to 1). Any other line returns `nil`.

**Files:**
- Create: `app/services/cf_wod/exercise_line_parser.rb`
- Test: `test/services/cf_wod/exercise_line_parser_test.rb`

**Interfaces:**
- Produces: `CfWod::ExerciseLineParser.call(line) -> Hash | nil` with keys among `{ movement_name:, reps:, distance:, distance_unit: }` on match, `nil` on no match. `distance_unit` is one of `:meter, :foot, :inch` (matching `Exercise#distance_unit`'s enum).

- [ ] **Step 1: Write the failing test**

Create `test/services/cf_wod/exercise_line_parser_test.rb`:

```ruby
require 'test_helper'

module CfWod
  class ExerciseLineParserTest < ActiveSupport::TestCase
    test 'parses a numbered reps line' do
      assert_equal({ movement_name: 'power snatches', reps: 5 }, ExerciseLineParser.call('5 power snatches'))
    end

    test 'strips a trailing comma-qualifier from the movement name' do
      result = ExerciseLineParser.call('1 rope climb, 15-ft. rope')
      assert_equal({ movement_name: 'rope climb', reps: 1 }, result)
    end

    test 'strips a trailing "with" qualifier from the movement name' do
      result = ExerciseLineParser.call('1,600-meter sled drag with a barbell front-rack carry')
      assert_equal({ movement_name: 'sled drag', reps: 1, distance: 1600, distance_unit: :meter }, result)
    end

    test 'parses a leading distance-then-movement line' do
      result = ExerciseLineParser.call('200-meter run')
      assert_equal({ movement_name: 'run', reps: 1, distance: 200, distance_unit: :meter }, result)
    end

    test 'parses a trailing movement-then-distance line' do
      result = ExerciseLineParser.call('Run 800 meters')
      assert_equal({ movement_name: 'Run', reps: 1, distance: 800, distance_unit: :meter }, result)
    end

    test 'parses a bare "Max" line as the reps-zero sentinel' do
      assert_equal({ movement_name: 'skin-the-cats', reps: 0 }, ExerciseLineParser.call('Max skin-the-cats'))
    end

    test 'parses a bare movement-only line as reps 1' do
      assert_equal({ movement_name: 'Thrusters', reps: 1 }, ExerciseLineParser.call('Thrusters'))
    end

    test 'returns nil for a full prose sentence that is not an exercise line' do
      line = 'Any time you stop, you must complete 15 bent-over rows with the barbell before starting again.'
      assert_nil ExerciseLineParser.call(line)
    end
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/exercise_line_parser_test.rb`
Expected: FAIL with `NameError: uninitialized constant CfWod::ExerciseLineParser`

- [ ] **Step 3: Implement ExerciseLineParser**

Create `app/services/cf_wod/exercise_line_parser.rb`:

```ruby
module CfWod
  class ExerciseLineParser
    MAX_REPS = /\AMax(?:imum)?[- ](.+)\z/i
    DISTANCE_THEN_MOVEMENT = /\A([\d,]+)[\s-](meters?|feet|foot|inches?)\s+(.+)\z/i
    MOVEMENT_THEN_DISTANCE = /\A([A-Za-z][A-Za-z '-]*?)\s+([\d,]+)\s+(meters?|feet|foot|inches?)\.?\z/i
    NUMBERED_REPS = /\A(\d+)\s+(.+)\z/
    BARE_MOVEMENT = /\A([A-Za-z][A-Za-z '-]*)\z/

    DISTANCE_UNITS = { 'meter' => :meter, 'meters' => :meter, 'foot' => :foot, 'feet' => :foot,
                       'inch' => :inch, 'inches' => :inch }.freeze

    def self.call(line) = new(line).parse

    def initialize(line)
      @line = line.to_s.strip
    end

    def parse
      case line
      when MAX_REPS then { movement_name: clean_name(line.match(MAX_REPS)[1]), reps: 0 }
      when DISTANCE_THEN_MOVEMENT then distance_then_movement_attributes
      when MOVEMENT_THEN_DISTANCE then movement_then_distance_attributes
      when NUMBERED_REPS then numbered_reps_attributes
      when BARE_MOVEMENT then { movement_name: clean_name(line), reps: 1 }
      end
    end

    private

    attr_reader :line

    def distance_then_movement_attributes
      value, unit, rest = line.match(DISTANCE_THEN_MOVEMENT).captures
      { movement_name: clean_name(rest), reps: 1, distance: value.delete(',').to_i,
        distance_unit: DISTANCE_UNITS.fetch(unit.downcase) }
    end

    def movement_then_distance_attributes
      movement, value, unit = line.match(MOVEMENT_THEN_DISTANCE).captures
      { movement_name: clean_name(movement), reps: 1, distance: value.delete(',').to_i,
        distance_unit: DISTANCE_UNITS.fetch(unit.downcase) }
    end

    def numbered_reps_attributes
      reps, rest = line.match(NUMBERED_REPS).captures
      { movement_name: clean_name(rest), reps: reps.to_i }
    end

    def clean_name(raw)
      raw.split(/,| with /i).first.strip
    end
  end
end
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bin/rails test test/services/cf_wod/exercise_line_parser_test.rb`
Expected: PASS (8 runs, 0 failures)

- [ ] **Step 5: Rubocop and commit**

```bash
bundle exec rubocop app/services/cf_wod/exercise_line_parser.rb
git add app/services/cf_wod/exercise_line_parser.rb test/services/cf_wod/exercise_line_parser_test.rb
git commit -m "Add ExerciseLineParser"
```

---

## Task 5: PartSplitter

Splits body text (everything after the format header line) into parts, stripping boilerplate lines (e.g. "Post rounds completed to comments.") and extracting the trailing prescription (Rx) text block. Detects two segment shapes: time-windowed ("0:00-5:00:") and sequential ("Then, N rounds of the couplet:"); a bare "Then, ..." with no rounds count closes any open segment and continues as a plain top-level line. A body with no segment markers is a single flat part.

**Files:**
- Create: `app/services/cf_wod/part_splitter.rb`
- Test: `test/services/cf_wod/part_splitter_test.rb`

**Interfaces:**
- Produces: `CfWod::PartSplitter.call(body) -> { parts: [Hash], prescription_text: String | nil }`. Each part is `{ segment: true/false, name: String|nil, time_seconds: Integer|nil, rounds: Integer|nil, lines: [String] }`.

- [ ] **Step 1: Write the failing test**

Create `test/services/cf_wod/part_splitter_test.rb`:

```ruby
require 'test_helper'

module CfWod
  class PartSplitterTest < ActiveSupport::TestCase
    test 'returns a single flat part for a body with no segment markers' do
      body = "5 power snatches\n10 overhead walking lunges\n1 rope climb, 15-ft. rope\n\n" \
             "Men: 95 lb.\nWomen: 65 lb.\n\nScroll for scaling options.\nPost rounds completed to comments."

      result = PartSplitter.call(body)

      assert_equal 1, result[:parts].length
      part = result[:parts].first
      assert_not part[:segment]
      assert_equal ['5 power snatches', '10 overhead walking lunges', '1 rope climb, 15-ft. rope'], part[:lines]
      assert_equal "Men: 95 lb.\nWomen: 65 lb.", result[:prescription_text]
    end

    test 'splits sequential parts, closing the segment on a bare "Then," continuation' do
      body = "Run 800 meters\nThen, 10 rounds of the couplet:\n10 handstand push-ups\n10 single-leg squats\n" \
             'Then, run 800 meters'

      parts = PartSplitter.call(body)[:parts]

      assert_equal 3, parts.length
      assert_equal({ segment: false, name: nil, time_seconds: nil, rounds: nil, lines: ['Run 800 meters'] }, parts[0])
      assert parts[1][:segment]
      assert_equal 10, parts[1][:rounds]
      assert_equal ['10 handstand push-ups', '10 single-leg squats'], parts[1][:lines]
      assert_equal({ segment: false, name: nil, time_seconds: nil, rounds: nil, lines: ['run 800 meters'] }, parts[2])
    end

    test 'splits time-windowed parts' do
      body = "0:00-5:00:\n200-meter run\nMax freestanding shoulder taps\n\n5:00-10:00:\n200-meter run\n" \
             'Max skin-the-cats'

      parts = PartSplitter.call(body)[:parts]

      assert_equal 2, parts.length
      assert parts[0][:segment]
      assert_equal '0:00-5:00', parts[0][:name]
      assert_equal 300, parts[0][:time_seconds]
      assert_equal ['200-meter run', 'Max freestanding shoulder taps'], parts[0][:lines]
      assert_equal '5:00-10:00', parts[1][:name]
    end

    test 'extracts a prescription block that binds across the whole workout, not just the last part' do
      body = "0:00-5:00:\n200-meter run\nMax freestanding shoulder taps\n\n15:00-20:00:\n200-meter run\n" \
             "Max deficit push-ups\n\nFemale 2-inch deficit\nMale 4-inch deficit"

      result = PartSplitter.call(body)

      assert_equal "Female 2-inch deficit\nMale 4-inch deficit", result[:prescription_text]
      assert_equal ['200-meter run', 'Max deficit push-ups'], result[:parts].last[:lines]
    end

    test 'returns a nil prescription_text when there is no Rx block' do
      result = PartSplitter.call("5 burpees\n10 air squats")
      assert_nil result[:prescription_text]
    end
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/part_splitter_test.rb`
Expected: FAIL with `NameError: uninitialized constant CfWod::PartSplitter`

- [ ] **Step 3: Implement PartSplitter**

Create `app/services/cf_wod/part_splitter.rb`:

```ruby
module CfWod
  class PartSplitter
    BOILERPLATE_LINE_PATTERNS = [
      /\Ascroll for scaling options\.?\z/i,
      /\Apost .*to comments\.?\z/i
    ].freeze

    TIME_WINDOW = /\A(\d{1,2}:\d{2})-(\d{1,2}:\d{2}):\z/
    ROUNDS_OF = /\AThen,\s*(\d+)\s+rounds?\s+of(?:\s+the\s+couplet)?:\z/i
    BARE_THEN = /\AThen,\s*/i
    PRESCRIPTION_LINE = /\A(?:men|women|male|female|♂|♀)\b/i

    def self.call(body) = new(body).split

    def initialize(body)
      @all_lines = body.to_s.split("\n").map(&:strip).reject(&:blank?)
    end

    def split
      cleaned = all_lines.reject { |line| boilerplate_line?(line) }
      prescription = cleaned.reverse.take_while { |line| line.match?(PRESCRIPTION_LINE) }.reverse
      content = cleaned[0...(cleaned.length - prescription.length)]

      { parts: build_parts(content), prescription_text: prescription.join("\n").presence }
    end

    private

    attr_reader :all_lines

    def boilerplate_line?(line)
      BOILERPLATE_LINE_PATTERNS.any? { |pattern| line.match?(pattern) }
    end

    def build_parts(content_lines)
      parts = [new_part]

      content_lines.each do |line|
        if (match = TIME_WINDOW.match(line))
          parts << segment_part(name: "#{match[1]}-#{match[2]}", time_seconds: window_seconds(match))
        elsif (match = ROUNDS_OF.match(line))
          parts << segment_part(rounds: match[1].to_i)
        elsif line.match?(BARE_THEN)
          parts << new_part
          parts.last[:lines] << line.sub(BARE_THEN, '')
        else
          parts.last[:lines] << line
        end
      end

      parts.reject { |part| part[:lines].empty? }
    end

    def new_part
      { segment: false, name: nil, time_seconds: nil, rounds: nil, lines: [] }
    end

    def segment_part(name: nil, time_seconds: nil, rounds: nil)
      { segment: true, name: name, time_seconds: time_seconds, rounds: rounds, lines: [] }
    end

    def window_seconds(match)
      to_seconds(match[2]) - to_seconds(match[1])
    end

    def to_seconds(clock)
      minutes, seconds = clock.split(':').map(&:to_i)
      (minutes * 60) + seconds
    end
  end
end
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bin/rails test test/services/cf_wod/part_splitter_test.rb`
Expected: PASS (5 runs, 0 failures)

- [ ] **Step 5: Rubocop and commit**

```bash
bundle exec rubocop app/services/cf_wod/part_splitter.rb
git add app/services/cf_wod/part_splitter.rb test/services/cf_wod/part_splitter_test.rb
git commit -m "Add PartSplitter"
```

---

## Task 6: PrescriptionClauseParser

Splits the trailing prescription text into parallel female/male clause lists. Handles both `Men:`/`Women:` and `Male:`/`Female:`/`♂`/`♀` prefixes, splits each sex's text on commas (optionally followed by "and"), and parses each clause into one or two value/unit/implement dicts (a clause like "14-lb medicine ball to a 9-foot target" carries two: the ball's weight and the target's distance).

**Files:**
- Create: `app/services/cf_wod/prescription_clause_parser.rb`
- Test: `test/services/cf_wod/prescription_clause_parser_test.rb`

**Interfaces:**
- Consumes: nothing from earlier tasks (pure text parsing).
- Produces: `CfWod::PrescriptionClauseParser.call(text) -> { female: [Array<Hash>], male: [Array<Hash>] }`. Each list holds one entry per clause, in the order clauses appeared; each entry is an array of 1-2 `{ value:, unit:, implement: }` hashes (`unit` is one of `:lb, :kg, :inch, :foot`).

- [ ] **Step 1: Write the failing test**

Create `test/services/cf_wod/prescription_clause_parser_test.rb`:

```ruby
require 'test_helper'

module CfWod
  class PrescriptionClauseParserTest < ActiveSupport::TestCase
    test 'parses a legacy Men:/Women: bare-weight block with no implement noun' do
      result = PrescriptionClauseParser.call("Men: 95 lb.\nWomen: 65 lb.")

      assert_equal [[{ value: 65, unit: :lb, implement: '' }]], result[:female]
      assert_equal [[{ value: 95, unit: :lb, implement: '' }]], result[:male]
    end

    test 'parses a modern multi-clause block with implement nouns' do
      female = "♀ 185-lb barbell, 20-inch box, and 14-lb medicine ball to a 9-foot target"
      male = "♂ 275-lb barbell, 24-inch box, and 20-lb medicine ball to a 10-foot target"

      result = PrescriptionClauseParser.call("#{female}\n#{male}")

      assert_equal 3, result[:female].length
      assert_equal [{ value: 185, unit: :lb, implement: 'barbell' }], result[:female][0]
      assert_equal [{ value: 20, unit: :inch, implement: 'box' }], result[:female][1]
      assert_equal [{ value: 14, unit: :lb, implement: 'medicine ball' },
                     { value: 9, unit: :foot, implement: 'target' }], result[:female][2]
      assert_equal [{ value: 275, unit: :lb, implement: 'barbell' }], result[:male][0]
    end

    test 'parses Female:/Male: prefixes' do
      result = PrescriptionClauseParser.call("Female 2-inch deficit\nMale 4-inch deficit")

      assert_equal [[{ value: 2, unit: :inch, implement: 'deficit' }]], result[:female]
      assert_equal [[{ value: 4, unit: :inch, implement: 'deficit' }]], result[:male]
    end
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/prescription_clause_parser_test.rb`
Expected: FAIL with `NameError: uninitialized constant CfWod::PrescriptionClauseParser`

- [ ] **Step 3: Implement PrescriptionClauseParser**

Create `app/services/cf_wod/prescription_clause_parser.rb`:

```ruby
module CfWod
  class PrescriptionClauseParser
    MALE_PREFIX = /\A(?:men|male|♂):?\s*/i
    FEMALE_PREFIX = /\A(?:women|female|♀):?\s*/i
    CLAUSE_PATTERN = /\A([\d,]+)[\s-](lb|kg|inch|foot|in|ft)\.?\s*(.*?)\.?\z/i
    TARGET_SUFFIX = /\s+to\s+a\s+([\d,]+)-(foot|ft|inch|in)\.?\s+(.+)\z/i
    UNIT_ALIASES = { 'lb' => :lb, 'kg' => :kg, 'inch' => :inch, 'in' => :inch, 'foot' => :foot, 'ft' => :foot }.freeze

    def self.call(text) = new(text).parse

    def initialize(text)
      @lines = text.to_s.split("\n").map(&:strip).reject(&:blank?)
    end

    def parse
      { female: clauses_for(FEMALE_PREFIX), male: clauses_for(MALE_PREFIX) }
    end

    private

    attr_reader :lines

    def clauses_for(prefix_pattern)
      line = lines.find { |candidate| candidate.match?(prefix_pattern) }
      return [] unless line

      line.sub(prefix_pattern, '').split(/,\s*(?:and\s+)?/i).filter_map { |clause| parse_clause(clause.strip) }
    end

    def parse_clause(clause)
      target_match = clause.match(TARGET_SUFFIX)
      base = target_match ? clause.sub(target_match[0], '').strip : clause
      base_match = base.match(CLAUSE_PATTERN)
      return nil unless base_match

      values = [clause_value(base_match[1], base_match[2], base_match[3])]
      values << clause_value(target_match[1], target_match[2], target_match[3]) if target_match
      values
    end

    def clause_value(raw_value, raw_unit, implement)
      { value: raw_value.delete(',').to_i, unit: UNIT_ALIASES.fetch(raw_unit.downcase), implement: implement.strip }
    end
  end
end
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bin/rails test test/services/cf_wod/prescription_clause_parser_test.rb`
Expected: PASS (3 runs, 0 failures)

- [ ] **Step 5: Rubocop and commit**

```bash
bundle exec rubocop app/services/cf_wod/prescription_clause_parser.rb
git add app/services/cf_wod/prescription_clause_parser.rb test/services/cf_wod/prescription_clause_parser_test.rb
git commit -m "Add PrescriptionClauseParser"
```

---

## Task 7: PrescriptionClauseAssigner

Binds parsed clauses onto built exercise lines, globally across the whole workout. For each clause, find every still-unbound exercise line matching by shared word-token (tokenize both the clause's implement text and the line's raw text, lowercase, split on non-letters, drop stopwords — this is how "medicine ball" binds to "wall-ball shots" via the shared token "ball"). If no line shares a token, fall back to a small `BARBELL_FAMILY_MOVEMENTS` keyword/cue check (for bare clauses with no implement noun, like "95 lb."). A clause binds to **every** matching line, not just one; zero matches raises `UnparseableError`.

**Files:**
- Create: `app/services/cf_wod/prescription_clause_assigner.rb`
- Test: `test/services/cf_wod/prescription_clause_assigner_test.rb`

**Interfaces:**
- Consumes: `exercise_lines` — an array of `{ exercise: Exercise, raw_line: String }` (built but unsaved `Exercise` instances, as produced by `WorkoutParser` in Task 8). `clauses` — the `{ female:, male: }` hash from `PrescriptionClauseParser` (Task 6).
- Produces: `CfWod::PrescriptionClauseAssigner.call(exercise_lines, clauses)` — mutates the `Exercise` instances in place (`female_load`/`male_load` or `female_distance`/`male_distance`/`distance_unit`), returns nothing meaningful. Raises `CfWod::WorkoutParser::UnparseableError` if a clause matches zero candidates.

- [ ] **Step 1: Write the failing test**

Create `test/services/cf_wod/prescription_clause_assigner_test.rb`:

```ruby
require 'test_helper'

module CfWod
  class PrescriptionClauseAssignerTest < ActiveSupport::TestCase
    def exercise_line(movement, raw_line)
      { exercise: Exercise.new(movement: movement), raw_line: raw_line }
    end

    test 'binds a bare no-noun clause to every barbell-family movement, skipping bodyweight ones' do
      snatch = exercise_line(movements(:power_snatch), '5 power snatches')
      lunge = exercise_line(movements(:overhead_walking_lunge), '10 overhead walking lunges')
      rope_climb = exercise_line(movements(:rope_climb), '1 rope climb, 15-ft. rope')
      clauses = { female: [[{ value: 65, unit: :lb, implement: '' }]], male: [[{ value: 95, unit: :lb, implement: '' }]] }

      PrescriptionClauseAssigner.call([snatch, lunge, rope_climb], clauses)

      assert_equal [65, 95], [snatch[:exercise].female_load, snatch[:exercise].male_load]
      assert_equal [65, 95], [lunge[:exercise].female_load, lunge[:exercise].male_load]
      assert_nil rope_climb[:exercise].female_load
    end

    test 'binds a shared-token clause to every occurrence of a repeated movement' do
      box_jump_1 = exercise_line(movements(:box_jump), '40 box jumps')
      box_jump_2 = exercise_line(movements(:box_jump), '40 box jumps')
      deadlift = exercise_line(movements(:deadlift), '10 deadlifts')
      clauses = { female: [[{ value: 20, unit: :inch, implement: 'box' }]],
                  male: [[{ value: 24, unit: :inch, implement: 'box' }]] }

      PrescriptionClauseAssigner.call([box_jump_1, box_jump_2, deadlift], clauses)

      assert_equal [20, 24], [box_jump_1[:exercise].female_distance, box_jump_1[:exercise].male_distance]
      assert_equal [20, 24], [box_jump_2[:exercise].female_distance, box_jump_2[:exercise].male_distance]
      assert_nil deadlift[:exercise].female_distance
    end

    test 'binds a shared-token clause across a synonymous implement noun (medicine ball vs wall-ball)' do
      wall_ball = exercise_line(movements(:wall_ball_shot), '30 wall-ball shots')
      clauses = { female: [[{ value: 14, unit: :lb, implement: 'medicine ball' },
                             { value: 9, unit: :foot, implement: 'target' }]],
                  male: [[{ value: 20, unit: :lb, implement: 'medicine ball' },
                          { value: 10, unit: :foot, implement: 'target' }]] }

      PrescriptionClauseAssigner.call([wall_ball], clauses)

      exercise = wall_ball[:exercise]
      assert_equal [14, 20], [exercise.female_load, exercise.male_load]
      assert_equal [9, 10], [exercise.female_distance, exercise.male_distance]
      assert_equal :foot, exercise.distance_unit.to_sym
    end

    test 'raises UnparseableError when a clause matches no candidate' do
      rope_climb = exercise_line(movements(:rope_climb), '1 rope climb, 15-ft. rope')
      clauses = { female: [[{ value: 20, unit: :inch, implement: 'box' }]],
                  male: [[{ value: 24, unit: :inch, implement: 'box' }]] }

      assert_raises(WorkoutParser::UnparseableError) { PrescriptionClauseAssigner.call([rope_climb], clauses) }
    end
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/prescription_clause_assigner_test.rb`
Expected: FAIL with `NameError: uninitialized constant CfWod::PrescriptionClauseAssigner`

- [ ] **Step 3: Implement PrescriptionClauseAssigner**

Create `app/services/cf_wod/prescription_clause_assigner.rb`:

```ruby
module CfWod
  class PrescriptionClauseAssigner
    # Movement is genuinely load-bearing here, detected by name/line-text for now -- swap this
    # for the equipment/load-bearing taxonomy (#1629) once it lands, same stopgap already used
    # by Movement#supports_implement_count?.
    BARBELL_FAMILY_KEYWORDS = %w[snatch clean jerk squat deadlift press thruster].freeze
    BARBELL_CUE_PATTERN = /overhead|front-rack|back-rack/i

    STOPWORDS = %w[a an the to of and or with for on at in].freeze
    LOAD_UNITS = %i[lb kg].freeze
    DISTANCE_UNITS = %i[inch foot meter].freeze

    def self.call(exercise_lines, clauses) = new(exercise_lines, clauses).assign

    def initialize(exercise_lines, clauses)
      @exercise_lines = exercise_lines
      @clauses = clauses
      @bound = Set.new
    end

    def assign
      clauses[:female].each_with_index do |female_values, index|
        bind_clause_pair(female_values, clauses[:male][index])
      end
    end

    private

    attr_reader :exercise_lines, :clauses, :bound

    def bind_clause_pair(female_values, male_values)
      candidates = matching_candidates(female_values.first)
      if candidates.empty?
        implement = female_values.first[:implement]
        raise WorkoutParser::UnparseableError, "prescription clause matched no movement: #{implement.inspect}"
      end

      candidates.each do |candidate|
        bound << candidate
        female_values.zip(male_values).each { |female_value, male_value| apply_value(candidate, female_value, male_value) }
      end
    end

    def matching_candidates(primary_value)
      by_token = unbound_lines.select { |line| shares_token?(primary_value[:implement], line[:raw_line]) }
      by_token.presence || unbound_lines.select { |line| barbell_family?(line) }
    end

    def unbound_lines
      exercise_lines.reject { |line| bound.include?(line) }
    end

    def shares_token?(implement, raw_line)
      (tokens(implement) & tokens(raw_line)).any?
    end

    def tokens(text)
      text.to_s.downcase.split(/[^a-z]+/).reject(&:blank?) - STOPWORDS
    end

    def barbell_family?(line)
      name = line[:exercise].movement.name.downcase
      BARBELL_FAMILY_KEYWORDS.any? { |keyword| name.include?(keyword) } || line[:raw_line].match?(BARBELL_CUE_PATTERN)
    end

    def apply_value(candidate, female_value, male_value)
      exercise = candidate[:exercise]
      if LOAD_UNITS.include?(female_value[:unit])
        exercise.female_load = female_value[:value]
        exercise.male_load = male_value[:value]
      elsif DISTANCE_UNITS.include?(female_value[:unit])
        exercise.female_distance = female_value[:value]
        exercise.male_distance = male_value[:value]
        exercise.distance_unit = female_value[:unit]
      end
    end
  end
end
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bin/rails test test/services/cf_wod/prescription_clause_assigner_test.rb`
Expected: PASS (4 runs, 0 failures)

- [ ] **Step 5: Rubocop and commit**

```bash
bundle exec rubocop app/services/cf_wod/prescription_clause_assigner.rb
git add app/services/cf_wod/prescription_clause_assigner.rb test/services/cf_wod/prescription_clause_assigner_test.rb
git commit -m "Add PrescriptionClauseAssigner"
```

---

## Task 8: WorkoutParser orchestration

Ties every collaborator together: classify the header, special-case a "find a 1-rep-max" lift (single Exercise, `load: 0` sentinel, no further body to parse), otherwise split the rest of the body into parts, build the `Workout`/`Segment`/`Exercise` graph, bind any prescription text, always set `notes` to the raw `body_text`, and raise `UnparseableError` if the built graph fails validation.

**Files:**
- Modify: `app/services/cf_wod/workout_parser.rb`
- Test: `test/services/cf_wod/workout_parser_test.rb`

**Interfaces:**
- Consumes: `WorkoutFormatClassifier.call`, `PartSplitter.call`, `ExerciseLineParser.call`, `MovementLookup.call`, `PrescriptionClauseParser.call`, `PrescriptionClauseAssigner.call` (Tasks 2-7).
- Produces: `CfWod::WorkoutParser.call(wod_page) -> Workout` (unsaved, valid) or raises `CfWod::WorkoutParser::UnparseableError`. `wod_page` is any object responding to `#body_text` and `#slug` (a real `CfWod::WodPage` in Tasks 9-10, or a directly-constructed one in Tasks 11-16).

- [ ] **Step 1: Write the failing test**

Create `test/services/cf_wod/workout_parser_test.rb`:

```ruby
require 'test_helper'

module CfWod
  class WorkoutParserTest < ActiveSupport::TestCase
    def wod_page(slug:, body_text:)
      WodPage.new(date: nil, slug: slug, title: nil, body_html: nil, body_text: body_text, description: nil,
                  scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
    end

    test 'builds a valid, unsaved flat for-time workout with no prescription' do
      page = wod_page(slug: '300101', body_text: "For time:\n5 burpees")

      workout = WorkoutParser.call(page)

      assert_not workout.persisted?
      assert workout.valid?
      assert_equal 'CF-300101', workout.name
      assert_equal 'time', workout.score_type
      assert_equal 1, workout.exercises.length
      exercise = workout.exercises.first
      assert_equal movements(:burpee), exercise.movement
      assert_equal 5, exercise.reps
      assert_equal 1, exercise.position
      assert_nil exercise.segment
    end

    test 'builds a find-a-1-rep-max workout with the load-zero sentinel' do
      page = wod_page(slug: '300102', body_text: 'Find a 1-rep-max back squat.')

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'weight', workout.score_type
      exercise = workout.exercises.first
      assert_equal movements(:back_squat), exercise.movement
      assert_equal 1, exercise.reps
      assert_equal 0, exercise.load
    end

    test 'raises UnparseableError when the movement is unrecognized' do
      page = wod_page(slug: '300103', body_text: "For time:\n5 completely unrecognized movements")

      assert_raises(WorkoutParser::UnparseableError) { WorkoutParser.call(page) }
    end
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_test.rb`
Expected: FAIL — `WorkoutParser.call` is undefined (only the `UnparseableError` shell exists so far).

- [ ] **Step 3: Implement the full WorkoutParser**

Replace the contents of `app/services/cf_wod/workout_parser.rb`:

```ruby
module CfWod
  class WorkoutParser
    class UnparseableError < StandardError; end

    def self.call(wod_page) = new(wod_page).parse

    def initialize(wod_page)
      @wod_page = wod_page
    end

    def parse
      header, rest = wod_page.body_text.split("\n", 2)
      attrs = WorkoutFormatClassifier.call(header)
      workout = Workout.new(name: "CF-#{wod_page.slug}", notes: wod_page.body_text, **attrs.except(:lift_name))

      if attrs[:lift_name]
        build_max_finding_exercise(workout, attrs[:lift_name])
      else
        build_from_body(workout, rest.to_s)
      end

      unless workout.valid?
        raise UnparseableError, "built workout failed validation: #{workout.errors.full_messages.join(', ')}"
      end

      workout
    end

    private

    attr_reader :wod_page

    def build_max_finding_exercise(workout, lift_name)
      movement = lookup_movement!(lift_name)
      workout.exercises.build(movement: movement, position: 1, reps: 1, load: 0)
    end

    def build_from_body(workout, body)
      split = PartSplitter.call(body)
      exercise_lines = build_exercise_lines(workout, split[:parts])
      return unless split[:prescription_text]

      clauses = PrescriptionClauseParser.call(split[:prescription_text])
      PrescriptionClauseAssigner.call(exercise_lines, clauses)
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
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_test.rb`
Expected: PASS (3 runs, 0 failures)

- [ ] **Step 5: Rubocop and commit**

```bash
bundle exec rubocop app/services/cf_wod/workout_parser.rb
git add app/services/cf_wod/workout_parser.rb test/services/cf_wod/workout_parser_test.rb
git commit -m "Implement WorkoutParser orchestration"
```

---

## Task 9: Corpus — 180110 (AMRAP, real fixture, multi-movement shared load)

End-to-end test through the real, already-existing `legacy_with_scaling.html` fixture (same one `FetcherTest` uses): `CfWod::Fetcher` → `CfWod::PageParser` → `CfWod::WorkoutParser`. Exercises the AMRAP classifier, boilerplate-line stripping, and the barbell-family global bind (power snatch + overhead lunge share the load; rope climb stays bodyweight).

**Files:**
- Test: `test/services/cf_wod/workout_parser_corpus_test.rb` (new file; every remaining corpus task adds to it)

**Interfaces:**
- Consumes: `CfWod::Fetcher.call`, `CfWod::WorkoutParser.call` (already built).

- [ ] **Step 1: Write the failing test**

Create `test/services/cf_wod/workout_parser_corpus_test.rb`:

```ruby
require 'test_helper'

module CfWod
  class WorkoutParserCorpusTest < ActiveSupport::TestCase
    FIXTURES = Rails.root.join('test/fixtures/cf_wod')

    def fixture(name)
      File.read(FIXTURES.join(name))
    end

    test '180110: AMRAP with a load shared across two movements, excluding the bodyweight rope climb' do
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
        .to_return(status: 200, body: fixture('legacy_with_scaling.html'))

      page = Fetcher.call(Date.new(2018, 1, 10))
      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'CF-180110', workout.name
      assert_equal 'rep', workout.score_type
      assert_equal 10, workout.time
      assert_equal 3, workout.exercises.length

      snatch, lunge, rope_climb = workout.exercises.sort_by(&:position)
      assert_equal movements(:power_snatch), snatch.movement
      assert_equal [5, 65, 95], [snatch.reps, snatch.female_load, snatch.male_load]
      assert_equal movements(:overhead_walking_lunge), lunge.movement
      assert_equal [10, 65, 95], [lunge.reps, lunge.female_load, lunge.male_load]
      assert_equal movements(:rope_climb), rope_climb.movement
      assert_equal 1, rope_climb.reps
      assert_nil rope_climb.female_load
    end
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: FAIL if any part of the pipeline mis-parses this real fixture — investigate and fix the relevant collaborator rather than the test if so, since the collaborators were validated against this exact prose during planning.

- [ ] **Step 3: Run again to confirm it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: PASS (1 run, 0 failures)

- [ ] **Step 4: Commit**

```bash
git add test/services/cf_wod/workout_parser_corpus_test.rb
git commit -m "Add corpus test: 180110 AMRAP with shared load"
```

---

## Task 10: Corpus — 260620 (real fixture, fails closed on unparseable prose)

Real WOD text is often messier than the grammar this v1 parser covers. `modern_multi_part.html` (already used by `FetcherTest`) contains a rules-explanation sentence ("Any time you stop, you must complete 15 bent-over rows...") that doesn't match the exercise-line grammar. This test proves the parser fails closed with a useful reason instead of guessing — exactly the review-queue-bound outcome the design expects for prose it doesn't yet cover.

**Files:**
- Modify: `test/services/cf_wod/workout_parser_corpus_test.rb`

- [ ] **Step 1: Write the failing test**

Add to `WorkoutParserCorpusTest`:

```ruby
test '260620: a real instructional sentence embedded in the body fails closed rather than guessing' do
  stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620})
    .to_return(status: 200, body: fixture('modern_multi_part.html'))
  stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/06/20})
    .to_return(status: 301, headers: { 'Location' => '/260620' })

  page = Fetcher.call(Date.new(2026, 6, 20))

  error = assert_raises(WorkoutParser::UnparseableError) { WorkoutParser.call(page) }
  assert_includes error.message, 'Any time you stop'
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: FAIL if the redirect stub or fixture path is wrong, or if `Sled Drag` isn't in the movement catalog yet — add a `sled_drag` fixture reference isn't needed here since it's already in `movements.yml` from Task 1.

- [ ] **Step 3: Run again to confirm it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: PASS (2 runs, 0 failures)

- [ ] **Step 4: Commit**

```bash
git add test/services/cf_wod/workout_parser_corpus_test.rb
git commit -m "Add corpus test: 260620 fails closed on unparseable prose"
```

---

## Task 11: Corpus — Fran (rep-ladder, bare movement-only lines)

Fran's canonical, universally-known prescription: `21-15-9 reps for time of: Thrusters / Pull-ups`, with the 95/65 lb load applying only to the thruster (barbell-family), not the pull-up. Constructed directly as a `WodPage` (not a full HTML fixture) since this is standard, well-established CrossFit content — `WorkoutParser` only depends on `WodPage#body_text`/`#slug`, not on how the page was fetched.

**Files:**
- Modify: `test/services/cf_wod/workout_parser_corpus_test.rb`

- [ ] **Step 1: Write the failing test**

Add to `WorkoutParserCorpusTest` (add this helper once, above the first test that needs it):

```ruby
def wod_page(slug:, body_text:)
  WodPage.new(date: nil, slug: slug, title: nil, body_html: nil, body_text: body_text, description: nil,
              scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
end

test 'Fran: rep-ladder with a bare-movement-only line, load applies to the thruster but not the pull-up' do
  page = wod_page(slug: '300201', body_text: "21-15-9 reps for time of:\nThrusters\nPull-ups\n\nMen: 95 lb.\nWomen: 65 lb.")

  workout = WorkoutParser.call(page)

  assert workout.valid?
  assert_equal 'time', workout.score_type
  assert_equal '21-15-9', workout.interval
  thruster, pull_up = workout.exercises.sort_by(&:position)
  assert_equal movements(:thruster), thruster.movement
  assert_equal [1, 65, 95], [thruster.reps, thruster.female_load, thruster.male_load]
  assert_equal movements(:pull_up), pull_up.movement
  assert_equal 1, pull_up.reps
  assert_nil pull_up.female_load
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: FAIL if `wod_page` helper collides or the bare-movement/interval path has a bug.

- [ ] **Step 3: Run again to confirm it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: PASS (3 runs, 0 failures)

- [ ] **Step 4: Commit**

```bash
git add test/services/cf_wod/workout_parser_corpus_test.rb
git commit -m "Add corpus test: Fran rep-ladder"
```

---

## Task 12: Corpus — EMOM (no prescription block at all)

Standard EMOM phrasing with two bodyweight movements and no Rx line — exercises the "no prescription text" path (`split[:prescription_text]` is `nil`, and `WorkoutParser` must skip binding entirely rather than erroring).

**Files:**
- Modify: `test/services/cf_wod/workout_parser_corpus_test.rb`

- [ ] **Step 1: Write the failing test**

Add to `WorkoutParserCorpusTest`:

```ruby
test 'EMOM: every-minute-on-the-minute with no prescription block' do
  page = wod_page(slug: '300202', body_text: "Every minute on the minute for 10 minutes:\n5 burpees\n10 air squats")

  workout = WorkoutParser.call(page)

  assert workout.valid?
  assert_equal 'rep', workout.score_type
  assert_equal 10, workout.time
  assert_equal 10, workout.rounds
  burpee, squat = workout.exercises.sort_by(&:position)
  assert_equal [movements(:burpee), 5], [burpee.movement, burpee.reps]
  assert_equal [movements(:squat), 10], [squat.movement, squat.reps]
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: FAIL if EMOM classification or the no-prescription path has a bug.

- [ ] **Step 3: Run again to confirm it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: PASS (4 runs, 0 failures)

- [ ] **Step 4: Commit**

```bash
git add test/services/cf_wod/workout_parser_corpus_test.rb
git commit -m "Add corpus test: EMOM with no prescription block"
```

---

## Task 13: Corpus — Back squat find-a-1RM (lifting)

Already covered functionally by Task 8's own unit test, but the corpus is the acceptance-criteria "battle-test deliverable," so it belongs alongside the other formats here too for a single place that demonstrates every format the classifier supports.

**Files:**
- Modify: `test/services/cf_wod/workout_parser_corpus_test.rb`

- [ ] **Step 1: Write the failing test**

Add to `WorkoutParserCorpusTest`:

```ruby
test 'find-a-1-rep-max: a single lifting line with the load-zero sentinel' do
  page = wod_page(slug: '300203', body_text: 'Find a 1-rep-max back squat.')

  workout = WorkoutParser.call(page)

  assert workout.valid?
  assert_equal 'weight', workout.score_type
  assert_equal 1, workout.exercises.length
  exercise = workout.exercises.first
  assert_equal movements(:back_squat), exercise.movement
  assert_equal [1, 0], [exercise.reps, exercise.load]
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: This should already pass, given Task 8's identical coverage — if it fails, something regressed since Task 8.

- [ ] **Step 3: Run again to confirm it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: PASS (5 runs, 0 failures)

- [ ] **Step 4: Commit**

```bash
git add test/services/cf_wod/workout_parser_corpus_test.rb
git commit -m "Add corpus test: find-a-1-rep-max lifting day"
```

---

## Task 14: Corpus — CFJ-181202 (sequential multi-part)

Text cross-validated against the real, already hand-built `CFJ-181202` workout in `db/seeds/cf_workouts.rb` (sourced from `https://www.crossfit.com/workout/2018/12/02`): a top-level exercise, then a 10-round segment, then a bare "Then," continuation back at top level.

**Files:**
- Modify: `test/services/cf_wod/workout_parser_corpus_test.rb`

- [ ] **Step 1: Write the failing test**

Add to `WorkoutParserCorpusTest`:

```ruby
test 'CFJ-181202: sequential multi-part with a bare "Then," continuation back at top level' do
  body = "For time:\nRun 800 meters\nThen, 10 rounds of the couplet:\n10 handstand push-ups\n" \
         "10 single-leg squats\nThen, run 800 meters"
  page = wod_page(slug: '300204', body_text: body)

  workout = WorkoutParser.call(page)

  assert workout.valid?
  assert_equal 'time', workout.score_type
  top_level = workout.exercises.select { |exercise| exercise.segment.blank? }.sort_by(&:position)
  assert_equal 2, top_level.length
  assert_equal [movements(:run), movements(:run)], top_level.map(&:movement)
  assert_equal [800, 800], top_level.map(&:distance)

  assert_equal 1, workout.segments.length
  segment = workout.segments.first
  assert_equal 10, segment.rounds
  hspu, single_leg_squat = segment.exercises.sort_by(&:position)
  assert_equal [movements(:handstand_push_up), 10], [hspu.movement, hspu.reps]
  assert_equal [movements(:single_leg_squat), 10], [single_leg_squat.movement, single_leg_squat.reps]
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: FAIL if segment-building or the bare-"Then," continuation path has a bug.

- [ ] **Step 3: Run again to confirm it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: PASS (6 runs, 0 failures)

- [ ] **Step 4: Commit**

```bash
git add test/services/cf_wod/workout_parser_corpus_test.rb
git commit -m "Add corpus test: CFJ-181202 sequential multi-part"
```

---

## Task 15: Corpus — CF-260622 (time-windowed multi-part + global distance bind)

Text cross-validated against the real, already hand-built `CF-260622` workout in `db/seeds/cf_workouts.rb` (sourced from `https://www.crossfit.com/260622`): four time-windowed segments, each with a run plus a max-reps gymnastics movement, and a trailing "Female 2-inch deficit / Male 4-inch deficit" prescription that must bind — across all four segments — onto only the one deficit push-up exercise, in the last segment.

**Files:**
- Modify: `test/services/cf_wod/workout_parser_corpus_test.rb`

- [ ] **Step 1: Write the failing test**

Add to `WorkoutParserCorpusTest`:

```ruby
test 'CF-260622: time-windowed multi-part with a prescription binding across segments' do
  body = "On a 20-minute clock for total reps:\n0:00-5:00:\n200-meter run\nMax freestanding shoulder taps\n\n" \
         "5:00-10:00:\n200-meter run\nMax skin-the-cats\n\n10:00-15:00:\n200-meter run\nMax L pull-ups\n\n" \
         "15:00-20:00:\n200-meter run\nMax deficit push-ups\n\nFemale 2-inch deficit\nMale 4-inch deficit"
  page = wod_page(slug: '300205', body_text: body)

  workout = WorkoutParser.call(page)

  assert workout.valid?
  assert_equal 4, workout.segments.length
  windows = workout.segments.sort_by(&:position)
  assert_equal ['0:00-5:00', '5:00-10:00', '10:00-15:00', '15:00-20:00'], windows.map(&:name)
  assert windows.all? { |segment| segment.time_seconds == 300 }

  gymnastics_movements = windows.map { |segment| segment.exercises.max_by(&:position).movement }
  assert_equal [movements(:freestanding_shoulder_tap), movements(:skin_the_cat), movements(:l_pull_up),
                movements(:deficit_push_up)], gymnastics_movements

  deficit_push_up = windows.last.exercises.max_by(&:position)
  assert_equal 0, deficit_push_up.reps
  assert_equal [2, 4], [deficit_push_up.female_distance, deficit_push_up.male_distance]
  assert_equal :inch, deficit_push_up.distance_unit.to_sym

  other_gymnastics = windows[0..2].map { |segment| segment.exercises.max_by(&:position) }
  assert other_gymnastics.all? { |exercise| exercise.female_distance.nil? }
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: FAIL if the global (cross-segment) prescription binding has a bug — this is the case that originally motivated correcting the spec's binding scope.

- [ ] **Step 3: Run again to confirm it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: PASS (7 runs, 0 failures)

- [ ] **Step 4: Commit**

```bash
git add test/services/cf_wod/workout_parser_corpus_test.rb
git commit -m "Add corpus test: CF-260622 time-windowed multi-part with cross-segment bind"
```

---

## Task 16: Corpus — deadlift/box-jump/wall-ball chipper (compound multi-clause bind)

The real, user-supplied example that drove the design's compound-clause handling: a reverse-pyramid chipper where one trailing Rx line encodes three *different* equipment dimensions (barbell weight, box height, medicine-ball weight *and* target distance) for three *different*, sometimes-repeated movements, while pull-ups and the row stay bodyweight.

**Files:**
- Modify: `test/services/cf_wod/workout_parser_corpus_test.rb`

- [ ] **Step 1: Write the failing test**

Add to `WorkoutParserCorpusTest`:

```ruby
test 'chipper: one Rx line encodes three different equipment dimensions across repeated movements' do
  body = "For time:\n10 deadlifts\n20 pull-ups\n30 wall-ball shots\n40 box jumps\n1,000-meter row\n" \
         "40 box jumps\n30 wall-ball shots\n20 pull-ups\n10 deadlifts\n\n" \
         "♀ 185-lb barbell, 20-inch box, and 14-lb medicine ball to a 9-foot target\n" \
         "♂ 275-lb barbell, 24-inch box, and 20-lb medicine ball to a 10-foot target"
  page = wod_page(slug: '300206', body_text: body)

  workout = WorkoutParser.call(page)

  assert workout.valid?
  assert_equal 9, workout.exercises.length
  by_movement = workout.exercises.group_by(&:movement)

  by_movement[movements(:deadlift)].each { |exercise| assert_equal [185, 275], [exercise.female_load, exercise.male_load] }
  by_movement[movements(:box_jump)].each do |exercise|
    assert_equal [20, 24], [exercise.female_distance, exercise.male_distance]
    assert_equal :inch, exercise.distance_unit.to_sym
  end
  by_movement[movements(:wall_ball_shot)].each do |exercise|
    assert_equal [14, 20], [exercise.female_load, exercise.male_load]
    assert_equal [9, 10], [exercise.female_distance, exercise.male_distance]
    assert_equal :foot, exercise.distance_unit.to_sym
  end
  by_movement[movements(:pull_up)].each { |exercise| assert_nil exercise.female_load }
  assert_nil by_movement[movements(:row)].first.female_load
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: FAIL if the compound-clause (two value/unit pairs in one clause) or repeated-movement binding has a bug — this is the case that motivated the "bind to every matching candidate, not just one" correction to the spec.

- [ ] **Step 3: Run again to confirm it passes**

Run: `bin/rails test test/services/cf_wod/workout_parser_corpus_test.rb`
Expected: PASS (8 runs, 0 failures)

- [ ] **Step 4: Rubocop the full corpus test file, then run every new test file together**

```bash
bundle exec rubocop test/services/cf_wod/workout_parser_corpus_test.rb
bin/rails test test/services/cf_wod/workout_format_classifier_test.rb test/services/cf_wod/movement_lookup_test.rb \
  test/services/cf_wod/exercise_line_parser_test.rb test/services/cf_wod/part_splitter_test.rb \
  test/services/cf_wod/prescription_clause_parser_test.rb test/services/cf_wod/prescription_clause_assigner_test.rb \
  test/services/cf_wod/workout_parser_test.rb test/services/cf_wod/workout_parser_corpus_test.rb
```

Expected: PASS, all files, 0 failures.

- [ ] **Step 5: Commit**

```bash
git add test/services/cf_wod/workout_parser_corpus_test.rb
git commit -m "Add corpus test: multi-implement chipper with compound prescription clauses"
```

---

## Final Verification

- [ ] Run the full new-code test suite one more time (command in Task 16, Step 4) and confirm all green.
- [ ] Run `bundle exec rubocop --parallel app/services/cf_wod test/services/cf_wod test/fixtures/movements.yml` and confirm no offenses.
- [ ] Do **not** run the full `bin/rails test:all` suite unless asked — per this repo's `CLAUDE.md`, only affected tests are run during implementation; a full-suite run (if ever requested) should be delegated to a subagent reporting only failures.
