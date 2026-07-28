# PR View Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a movement show multiple personal records at once (one per distinct rep/distance/duration "test"), and add a new page showing the user's best-ever score per workout (Fran, Murph, Open workouts, etc.).

**Architecture:** A new plain-Ruby class `MovementRecordSet` owns the grouping/ranking rule table for movement PRs; `User#personal_records` delegates to it. `User#workout_records` is a simple one-rule method (no separate class needed) that groups logs by workout and keeps the best score per the `score_type` direction. A new `WorkoutRecordsController` mirrors the existing `MovementLogsController`/`personal_records` pattern for the new page.

**Tech Stack:** Ruby on Rails 8.1, PostgreSQL, Minitest with fixtures, Slim views.

Full design context: https://github.com/Yanchek99/wod-tracker/issues/1829

## Global Constraints

- No new persisted/materialized PR table or background jobs — everything is computed from existing `movement_logs`/`logs` data at request time.
- No new "benchmark" flag/categorization on `Workout` — any workout (repeated or logged once) qualifies for a workout PR.
- No cross-user (coach viewing athlete) access changes — mirrors the existing `personal_records` behavior, which is only ever linked for `Current.user` today.
- Run tests with `rvm 4.0.5@wod-tracker do bundle exec rails test <path>`. Run RuboCop on changed files with `rvm 4.0.5@wod-tracker do bundle exec rubocop --parallel <paths>`.

---

## Existing code you need to know about

**`app/models/user.rb`** currently has:
```ruby
def personal_records
  movement_logs
    .where('reps IS NOT NULL OR load IS NOT NULL OR distance IS NOT NULL ' \
           'OR calories IS NOT NULL OR duration_seconds IS NOT NULL')
    .reorder(Arel.sql('COALESCE(load, distance, calories, duration_seconds, reps) DESC'))
    .uniq(&:movement_id)
end
```
This is a leftover from a prior bug-fix session (it used to crash and pick the wrong record; those bugs are fixed, but it still only shows one record per movement). It will be rewritten in Task 2.

**`app/models/movement_log.rb`** columns available on every `MovementLog`: `reps`, `load`, `distance`, `distance_unit`, `duration_seconds`, `calories` (see `db/schema.rb` `create_table "movement_logs"`). All nullable, independent of each other.

**`app/controllers/movement_logs_controller.rb`** (existing, unchanged by Task 1):
```ruby
class MovementLogsController < ApplicationController
  before_action :set_user, only: [:personal_records]

  def personal_records
    @movement_logs = @user.personal_records.sort_by { |m| m.movement.name }
  end

  private

  def set_user
    @user = User.find(params.expect(:user_id))
  end
end
```

**`app/views/movement_logs/personal_records.html.slim`** (existing, unchanged by any task — it already renders one `tr` per element of `@movement_logs`, so it needs no structural change to support multiple rows per movement):
```slim
.container
  h1.mt-3 Personal Records
  table.table.table-hover
    thead
      tr
        th scope="col" Movement
        th scope="col" Record
    tbody
      - @movement_logs.each do |pr|
        tr
          th scope="row" #{pr.movement.name}
          td = link_to pr.log
            span = measurable_reps_msg(pr)
            span = measurable_additional_metrics(pr)
```

**`app/models/log.rb`** relevant bits: `belongs_to :workout`, `enum :score_type, Metric.measurements, prefix: :score` (gives predicate methods like `score_time?`), `has_many :movement_logs, -> { order(:id) }, dependent: :destroy`.

**`app/models/concerns/log_scoring.rb`**: no existing "which log scored better" comparator — Task 4 adds the only one needed (time ascending, everything else descending).

**`Metric.workout_measurements`** (`app/models/metric.rb`): `[:calorie, :rep, :round, :time, :weight]` — the only `score_type` values a `Log`/`Workout` can have.

**`app/helpers/metrics_helper.rb`** has `log_score_msg(log)`, already used elsewhere to render a log's score as a string (e.g. `"5:30"`, `"202 reps"`). Reused as-is in Task 5's new view.

**Route file `config/routes.rb`** relevant block:
```ruby
resources :users do
  resources :movement_logs, only: [] do
    collection do
      get :personal_records
    end
  end
end
```

**Nav** `app/views/layouts/application.html.slim:26`:
```slim
= link_to 'PRs', personal_records_user_movement_logs_path(Current.user), class: 'nav-item nav-link'
```

**Relevant fixtures** (`test/fixtures/`):
- `movements.yml`: `deadlift` (name: Deadlift), `row` (name: Row) — already exist, reuse them.
- `users.yml`: `mathew` (male), `brooke` (female).
- `logs.yml`: `matt_amrap` (user: mathew, workout: amrap_couplet, score_type: rep, score_value: 202), `matt_murph` (user: mathew, workout: murph, score_type: time, score_value: 3600).
- `workouts.yml`: `fran` (score_type: time), `murph` (score_type: time), `segmented_total_reps` (score_type: rep, not AMRAP-structured — safe for a plain `Log.create!` without triggering AMRAP score normalization or set-based-lifting callbacks).

---

### Task 1: `MovementRecordSet` — the grouping/ranking rule engine

**Files:**
- Create: `app/models/movement_record_set.rb`
- Test: `test/models/movement_record_set_test.rb`

**Interfaces:**
- Consumes: any `Enumerable` of `MovementLog`-like objects responding to `#movement_id`, `#load`, `#reps`, `#distance`, `#duration_seconds`, `#calories`.
- Produces: `MovementRecordSet.new(movement_logs).records` → `Array` of the winning `MovementLog` objects (same objects passed in, not copies), one per `(movement_id, group_key)` group, per the rule table below. Later tasks (`User#personal_records`) call this directly.

Rule table this class implements:

| Recorded dimensions present | Ranked outcome (higher wins unless noted) | Grouped by |
|---|---|---|
| `load` (+ maybe reps/distance/duration/calories) | `load` | every other present dimension |
| `distance` + `duration_seconds`, no `load` | `duration_seconds`, **lower** wins | `distance` |
| `distance` only, no `load`/`duration_seconds` | not a PR — skipped | — |
| `duration_seconds` + `reps`, no `load`/`distance` | `reps` | `duration_seconds` |
| `duration_seconds` + `calories`, no `load`/`distance`/`reps` | `calories` | `duration_seconds` |
| `calories` only | `calories` | — (single record) |
| `reps` only | `reps` | — (single record) |

- [ ] **Step 1: Write the failing tests**

Create `test/models/movement_record_set_test.rb`:
```ruby
require 'test_helper'

class MovementRecordSetTest < ActiveSupport::TestCase
  test 'groups load-bearing logs by rep count and keeps the heaviest load per rep count' do
    five_rep_heavy = MovementLog.new(movement_id: 1, load: 275, reps: 5)
    five_rep_light = MovementLog.new(movement_id: 1, load: 225, reps: 5)
    fifty_two_rep = MovementLog.new(movement_id: 1, load: 185, reps: 52)

    records = MovementRecordSet.new([five_rep_heavy, five_rep_light, fifty_two_rep]).records

    assert_includes records, five_rep_heavy
    assert_includes records, fifty_two_rep
    refute_includes records, five_rep_light
    assert_equal 2, records.size
  end

  test 'does not let an earlier-logged low load beat a later-logged high load in the same rep-count group' do
    logged_first_and_lighter = MovementLog.new(movement_id: 8, load: 225, reps: 5)
    logged_second_and_heavier = MovementLog.new(movement_id: 8, load: 275, reps: 5)

    records = MovementRecordSet.new([logged_first_and_lighter, logged_second_and_heavier]).records

    assert_equal [logged_second_and_heavier], records
  end

  test 'ranks distance-plus-duration logs by the fastest time within the same distance' do
    slow_500 = MovementLog.new(movement_id: 2, distance: 500, duration_seconds: 120)
    fast_500 = MovementLog.new(movement_id: 2, distance: 500, duration_seconds: 105)
    a_2000 = MovementLog.new(movement_id: 2, distance: 2000, duration_seconds: 450)

    records = MovementRecordSet.new([slow_500, fast_500, a_2000]).records

    assert_includes records, fast_500
    assert_includes records, a_2000
    refute_includes records, slow_500
    assert_equal 2, records.size
  end

  test 'skips a bare distance with no load or duration' do
    distance_only = MovementLog.new(movement_id: 3, distance: 5000)

    assert_empty MovementRecordSet.new([distance_only]).records
  end

  test 'ranks duration-plus-reps logs by the most reps within the same duration' do
    fewer_reps = MovementLog.new(movement_id: 4, duration_seconds: 60, reps: 40)
    more_reps = MovementLog.new(movement_id: 4, duration_seconds: 60, reps: 55)

    records = MovementRecordSet.new([fewer_reps, more_reps]).records

    assert_equal [more_reps], records
  end

  test 'ranks duration-plus-calories logs by the most calories within the same duration' do
    fewer_calories = MovementLog.new(movement_id: 5, duration_seconds: 240, calories: 60)
    more_calories = MovementLog.new(movement_id: 5, duration_seconds: 240, calories: 75)

    records = MovementRecordSet.new([fewer_calories, more_calories]).records

    assert_equal [more_calories], records
  end

  test 'keeps the highest calories-only log as a single record' do
    fewer = MovementLog.new(movement_id: 6, calories: 20)
    more = MovementLog.new(movement_id: 6, calories: 30)

    records = MovementRecordSet.new([fewer, more]).records

    assert_equal [more], records
  end

  test 'keeps the highest reps-only log as a single record' do
    fewer = MovementLog.new(movement_id: 7, reps: 10)
    more = MovementLog.new(movement_id: 7, reps: 15)

    records = MovementRecordSet.new([fewer, more]).records

    assert_equal [more], records
  end

  test 'keeps records from different movements independent' do
    deadlift = MovementLog.new(movement_id: 9, load: 315, reps: 1)
    back_squat = MovementLog.new(movement_id: 10, load: 405, reps: 1)

    records = MovementRecordSet.new([deadlift, back_squat]).records

    assert_includes records, deadlift
    assert_includes records, back_squat
    assert_equal 2, records.size
  end
end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/models/movement_record_set_test.rb`
Expected: FAIL with `NameError: uninitialized constant MovementRecordSet` (or similar) for every test.

- [ ] **Step 3: Implement `MovementRecordSet`**

Create `app/models/movement_record_set.rb`:
```ruby
# Groups a user's movement logs into "the same test attempted more than once" and keeps the best
# attempt per group. Which dimension counts as the group ("what was fixed") versus the ranked
# outcome ("what you were trying to beat") depends on which columns the log recorded -- see the
# rule table in docs/superpowers/plans/2026-07-28-pr-view-redesign.md.
class MovementRecordSet
  Candidate = Struct.new(:movement_log, :group_key, :rank_value)

  def initialize(movement_logs)
    @movement_logs = movement_logs
  end

  def records
    @movement_logs
      .filter_map { |movement_log| candidate_for(movement_log) }
      .group_by { |candidate| [candidate.movement_log.movement_id, candidate.group_key] }
      .values
      .map { |candidates| candidates.max_by(&:rank_value).movement_log }
  end

  private

  def candidate_for(movement_log)
    if movement_log.load.present?
      load_candidate(movement_log)
    elsif movement_log.distance.present? && movement_log.duration_seconds.present?
      distance_duration_candidate(movement_log)
    elsif movement_log.distance.present?
      nil
    elsif movement_log.duration_seconds.present? && movement_log.reps.present?
      duration_reps_candidate(movement_log)
    elsif movement_log.duration_seconds.present? && movement_log.calories.present?
      duration_calories_candidate(movement_log)
    elsif movement_log.calories.present?
      Candidate.new(movement_log, :calories, movement_log.calories)
    elsif movement_log.reps.present?
      Candidate.new(movement_log, :reps, movement_log.reps)
    end
  end

  def load_candidate(movement_log)
    group_key = [:load, movement_log.reps, movement_log.distance, movement_log.duration_seconds, movement_log.calories]
    Candidate.new(movement_log, group_key, movement_log.load)
  end

  def distance_duration_candidate(movement_log)
    Candidate.new(movement_log, [:distance, movement_log.distance], -movement_log.duration_seconds)
  end

  def duration_reps_candidate(movement_log)
    Candidate.new(movement_log, [:duration_reps, movement_log.duration_seconds], movement_log.reps)
  end

  def duration_calories_candidate(movement_log)
    Candidate.new(movement_log, [:duration_calories, movement_log.duration_seconds], movement_log.calories)
  end
end
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/models/movement_record_set_test.rb`
Expected: PASS, 9 runs, 0 failures.

- [ ] **Step 5: RuboCop**

Run: `rvm 4.0.5@wod-tracker do bundle exec rubocop app/models/movement_record_set.rb test/models/movement_record_set_test.rb`
Expected: no offenses. Fix any and re-run.

- [ ] **Step 6: Commit**

```bash
git add app/models/movement_record_set.rb test/models/movement_record_set_test.rb
git commit -m "Add MovementRecordSet to rank/group movement logs into distinct PRs"
```

---

### Task 2: `User#personal_records` delegates to `MovementRecordSet`

**Files:**
- Modify: `app/models/user.rb:45-51`
- Modify: `test/models/user_test.rb` (replace the existing `personal_records` test with two tests reflecting the new grouping behavior)

**Interfaces:**
- Consumes: `MovementRecordSet.new(movement_logs).records` from Task 1.
- Produces: `User#personal_records` → `Array<MovementLog>`, same contract as before (used by `MovementLogsController#personal_records` in Task 3).

**Note:** `test/models/user_test.rb` currently has a test called `'personal_records picks the best value for a movement, not the first one logged'` (added in a prior session) that creates two Deadlift logs at *different* rep counts (95×5 then 185×52) and asserts only the 185×52 one shows. Under the new grouping rules those are two separate groups (different rep counts), so **both** now legitimately show — that assertion is no longer correct and must be replaced, not kept alongside the new tests.

- [ ] **Step 1: Read the current test to replace**

Run: `grep -n "personal_records picks the best value" -A 10 test/models/user_test.rb`

Confirm it's the block using `movements(:deadlift)`, `logs(:matt_amrap)`, loads `95` and `185` at reps `5` and `52`.

- [ ] **Step 2: Write the failing tests (replacing the old one)**

In `test/models/user_test.rb`, replace that entire test block with:
```ruby
  test 'personal_records keeps the heaviest load within the same rep count, regardless of log order' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 225, reps: 5)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)

    records = users(:mathew).personal_records.select { |pr| pr.movement == deadlift }

    assert_equal [275], records.map(&:load)
  end

  test 'personal_records shows a separate record per rep count for the same movement' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)

    records = users(:mathew).personal_records.select { |pr| pr.movement == deadlift }

    assert_equal [[185, 52], [275, 5]], records.map { |pr| [pr.load, pr.reps] }.sort
  end
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/models/user_test.rb`
Expected: the two new tests FAIL (old `personal_records` implementation still uses `uniq(&:movement_id)`, so only one Deadlift record shows).

- [ ] **Step 4: Rewrite `User#personal_records`**

In `app/models/user.rb`, replace:
```ruby
  def personal_records
    movement_logs
      .where('reps IS NOT NULL OR load IS NOT NULL OR distance IS NOT NULL ' \
             'OR calories IS NOT NULL OR duration_seconds IS NOT NULL')
      .reorder(Arel.sql('COALESCE(load, distance, calories, duration_seconds, reps) DESC'))
      .uniq(&:movement_id)
  end
```
with:
```ruby
  def personal_records
    candidates = movement_logs
                 .where('reps IS NOT NULL OR load IS NOT NULL OR distance IS NOT NULL ' \
                        'OR calories IS NOT NULL OR duration_seconds IS NOT NULL')
                 .reorder(nil)
    MovementRecordSet.new(candidates).records
  end
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/models/user_test.rb`
Expected: PASS, 7 runs (5 pre-existing + 2 new), 0 failures.

- [ ] **Step 6: RuboCop**

Run: `rvm 4.0.5@wod-tracker do bundle exec rubocop app/models/user.rb test/models/user_test.rb`
Expected: no offenses.

- [ ] **Step 7: Commit**

```bash
git add app/models/user.rb test/models/user_test.rb
git commit -m "Show one personal record per distinct rep/distance/duration test, not just one per movement"
```

---

### Task 3: Multi-record display ordering on the Personal Records page

**Files:**
- Modify: `app/controllers/movement_logs_controller.rb:5`
- Test: `test/controllers/movement_logs_controller_test.rb` (new file)

**Interfaces:**
- Consumes: `User#personal_records` from Task 2 (now may return several `MovementLog`s per movement).
- Produces: `@movement_logs` sorted so same-movement rows sit next to each other, in a readable progression (ascending by whichever secondary dimension applies) — consumed by the unchanged `personal_records.html.slim` view.

The view needs no changes — it already renders one row per element of `@movement_logs`. Only the controller's sort needs to widen from "by movement name" to "by movement name, then by the secondary dimension" so multiple rows for one movement appear together and in a sensible order (e.g. Deadlift 1-rep before 5-rep before 52-rep).

- [ ] **Step 1: Write the failing test**

Create `test/controllers/movement_logs_controller_test.rb`:
```ruby
require 'test_helper'

class MovementLogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'personal_records renders every distinct rep-count record for a movement' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)

    get personal_records_user_movement_logs_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Deadlift', count: 2
  end

  test 'personal_records orders a movement\'s records by ascending rep count' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)

    get personal_records_user_movement_logs_url(users(:mathew))

    assert_response :success
    deadlift_rows = css_select('th').map(&:text).each_index.select { |i| css_select('th')[i].text == 'Deadlift' }
    body_after_deadlift_header = response.body[/Deadlift.*?Deadlift.*?<\/tr>/m]
    assert_match(/275.*185/m, body_after_deadlift_header.to_s.gsub(/\s+/, ' '))
  end
end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/movement_logs_controller_test.rb`
Expected: first test PASSES already (multiple rows already render — Task 2 handled that); second test FAILS because rows aren't ordered by rep count yet (still just sorted by movement name, so insertion order — 52 then 5 — is preserved).

- [ ] **Step 3: Update the controller's sort**

In `app/controllers/movement_logs_controller.rb`, replace:
```ruby
  def personal_records
    @movement_logs = @user.personal_records.sort_by { |m| m.movement.name }
  end
```
with:
```ruby
  def personal_records
    @movement_logs = @user.personal_records.sort_by { |m| [m.movement.name, m.reps.to_i, m.distance.to_i, m.duration_seconds.to_i] }
  end
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/movement_logs_controller_test.rb`
Expected: PASS, 2 runs, 0 failures.

If the second test's string-matching assertion proves flaky against the actual rendered HTML, simplify it to directly assert record order instead of scraping response body — replace the test body with:
```ruby
  test 'personal_records orders a movement\'s records by ascending rep count' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)

    get personal_records_user_movement_logs_url(users(:mathew))

    assert_response :success
    load_values = response.body.scan(/(\d+) lbs/).flatten.map(&:to_i)
    deadlift_index_275 = load_values.index(275)
    deadlift_index_185 = load_values.index(185)
    assert_operator deadlift_index_275, :<, deadlift_index_185
  end
```
Run the test again after simplifying and confirm it passes before moving on.

- [ ] **Step 5: RuboCop**

Run: `rvm 4.0.5@wod-tracker do bundle exec rubocop app/controllers/movement_logs_controller.rb test/controllers/movement_logs_controller_test.rb`
Expected: no offenses.

- [ ] **Step 6: Commit**

```bash
git add app/controllers/movement_logs_controller.rb test/controllers/movement_logs_controller_test.rb
git commit -m "Order multiple personal-record rows for a movement by rep/distance/duration"
```

---

### Task 4: `User#workout_records`

**Files:**
- Modify: `app/models/user.rb` (add method after `personal_records`)
- Modify: `test/models/user_test.rb` (add three tests)

**Interfaces:**
- Consumes: `User#logs` (existing association), `Log#score_time?` (existing enum predicate from `enum :score_type, Metric.measurements, prefix: :score` in `app/models/log.rb`).
- Produces: `User#workout_records` → `Array<Log>`, one `Log` per distinct `workout_id`, the best score in each. Consumed by `WorkoutRecordsController` in Task 5.

- [ ] **Step 1: Write the failing tests**

In `test/models/user_test.rb`, add:
```ruby
  test 'workout_records keeps the lowest score for a time-scored workout' do
    workout = workouts(:fran)
    slow = users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 400)
    fast = users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 330)

    records = users(:mathew).workout_records.select { |log| log.workout == workout }

    assert_equal [fast], records
  end

  test 'workout_records keeps the highest score for a rep-scored workout' do
    workout = workouts(:segmented_total_reps)
    fewer = users(:mathew).logs.create!(workout: workout, score_type: :rep, score_value: 100)
    more = users(:mathew).logs.create!(workout: workout, score_type: :rep, score_value: 150)

    records = users(:mathew).workout_records.select { |log| log.workout == workout }

    assert_equal [more], records
  end

  test 'workout_records shows a workout logged only once' do
    records = users(:mathew).workout_records

    assert_includes records, logs(:matt_murph)
  end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/models/user_test.rb`
Expected: the three new tests FAIL with `NoMethodError: undefined method 'workout_records'`.

- [ ] **Step 3: Implement `User#workout_records`**

In `app/models/user.rb`, add after `personal_records` (before the closing `end` of the class):
```ruby
  def workout_records
    logs
      .group_by(&:workout_id)
      .values
      .map { |workout_logs| workout_logs.max_by { |log| log.score_time? ? -log.score_value : log.score_value } }
  end
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/models/user_test.rb`
Expected: PASS, 10 runs (7 from Task 2 + 3 new), 0 failures.

- [ ] **Step 5: RuboCop**

Run: `rvm 4.0.5@wod-tracker do bundle exec rubocop app/models/user.rb test/models/user_test.rb`
Expected: no offenses.

- [ ] **Step 6: Commit**

```bash
git add app/models/user.rb test/models/user_test.rb
git commit -m "Add User#workout_records for best-score-per-workout tracking"
```

---

### Task 5: Workout Records page (route, controller, view, nav)

**Files:**
- Modify: `config/routes.rb`
- Create: `app/controllers/workout_records_controller.rb`
- Create: `app/views/workout_records/index.html.slim`
- Modify: `app/views/layouts/application.html.slim:26`
- Test: `test/controllers/workout_records_controller_test.rb` (new file)

**Interfaces:**
- Consumes: `User#workout_records` from Task 4, `log_score_msg(log)` helper (existing, `app/helpers/metrics_helper.rb`).
- Produces: `GET /users/:user_id/workout_records` (route helper `user_workout_records_path`/`_url`), rendering `WorkoutRecordsController#index`.

- [ ] **Step 1: Write the failing test**

Create `test/controllers/workout_records_controller_test.rb`:
```ruby
require 'test_helper'

class WorkoutRecordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index shows the best score per workout, one row per workout' do
    workout = workouts(:fran)
    users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 400)
    fast = users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 330)

    get user_workout_records_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Fran', count: 1
    assert_select 'a[href=?]', log_path(fast)
  end

  test 'index shows a workout logged only once' do
    get user_workout_records_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Murph'
  end
end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/workout_records_controller_test.rb`
Expected: FAIL with a routing error (`user_workout_records_url` undefined) since the route doesn't exist yet.

- [ ] **Step 3: Add the route**

In `config/routes.rb`, replace:
```ruby
  resources :users do
    resources :movement_logs, only: [] do
      collection do
        get :personal_records
      end
    end
  end
```
with:
```ruby
  resources :users do
    resources :movement_logs, only: [] do
      collection do
        get :personal_records
      end
    end
    resources :workout_records, only: [:index]
  end
```

- [ ] **Step 4: Create the controller**

Create `app/controllers/workout_records_controller.rb`:
```ruby
class WorkoutRecordsController < ApplicationController
  before_action :set_user

  def index
    @logs = @user.workout_records.sort_by { |log| log.workout.name }
  end

  private

  def set_user
    @user = User.find(params.expect(:user_id))
  end
end
```

- [ ] **Step 5: Create the view**

Create `app/views/workout_records/index.html.slim`:
```slim
.container
  h1.mt-3 Workout Records
  table.table.table-hover
    thead
      tr
        th scope="col" Workout
        th scope="col" Record
    tbody
      - @logs.each do |log|
        tr
          th scope="row" #{log.workout.name}
          td = link_to log
            span = log_score_msg(log)
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/workout_records_controller_test.rb`
Expected: PASS, 2 runs, 0 failures.

- [ ] **Step 7: Add the nav link**

In `app/views/layouts/application.html.slim`, replace:
```slim
              = link_to 'PRs', personal_records_user_movement_logs_path(Current.user), class: 'nav-item nav-link'
```
with:
```slim
              = link_to 'PRs', personal_records_user_movement_logs_path(Current.user), class: 'nav-item nav-link'
              = link_to 'Workout Records', user_workout_records_path(Current.user), class: 'nav-item nav-link'
```

- [ ] **Step 8: Manually verify the nav link**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/application_layout_visibility_test.rb`
Expected: PASS (confirms the layout still renders for signed-in/out states with the new link added).

- [ ] **Step 9: RuboCop**

Run: `rvm 4.0.5@wod-tracker do bundle exec rubocop app/controllers/workout_records_controller.rb test/controllers/workout_records_controller_test.rb`
Expected: no offenses.

- [ ] **Step 10: Commit**

```bash
git add config/routes.rb app/controllers/workout_records_controller.rb app/views/workout_records/index.html.slim app/views/layouts/application.html.slim test/controllers/workout_records_controller_test.rb
git commit -m "Add Workout Records page showing best score per workout"
```

---

## Final verification

After all 5 tasks:
- [ ] Run the full non-system suite: `rvm 4.0.5@wod-tracker do bundle exec rails test` (delegate to a subagent per project convention and report only failures if this is run standalone rather than task-by-task).
- [ ] Run RuboCop across all changed files: `rvm 4.0.5@wod-tracker do bundle exec rubocop --parallel app/models/movement_record_set.rb app/models/user.rb app/controllers/movement_logs_controller.rb app/controllers/workout_records_controller.rb test/models/movement_record_set_test.rb test/models/user_test.rb test/controllers/movement_logs_controller_test.rb test/controllers/workout_records_controller_test.rb`
- [ ] Start the app (`bin/dev`) and manually click through: Personal Records page shows multiple Deadlift-style rows once seeded with multi-rep-count data; new "Workout Records" nav link loads the new page.
