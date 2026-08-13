# Set Breakdown Capture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `movement_logs.set_breakdown`, an ordered array of unbroken-set sizes, auto-populated for trivial/single-lift cases and self-reported everywhere else via the logging form.

**Architecture:** A Postgres integer array column on `MovementLog`, validated to sum to `reps` when present. `Log#build_movement_log_for` auto-populates it for two cases (a single logged rep; a dedicated single-lift weightlifting day). The logging form (`logs/_form.html.slim`) renders an optional dynamic add/remove "set size" repeater, driven by a small new Stimulus controller, shown only when the value isn't already known.

**Tech Stack:** Rails 8.1, PostgreSQL (`integer[]` column), Minitest + fixtures, Slim, Simple Form, Stimulus, esbuild.

## Global Constraints

- Work happens in the existing worktree at `.claude/worktrees/fix-1860-set-breakdown` on branch `fix-1860-set-breakdown` (already created, based on current `master`). Do not create a new worktree.
- The `cf/docs/decisions.md` entry for this design is already committed on this branch (commit `4368d19`) — no further doc changes are needed unless a task below says otherwise.
- Run Ruby/Rails commands with the project gemset: prefix with `rvm 4.0.6@wod-tracker do`.
- RuboCop: `Metrics/MethodLength` max 20, `Metrics/AbcSize` max 20, `Layout/LineLength` max 160 (excluding `config/**/*`). `db/**/*` is excluded from RuboCop entirely.
- Run only the tests affected by each task; do not run the full suite until the final task.
- Design reference: [GitHub issue #1860](https://github.com/Yanchek99/wod-tracker/issues/1860).

---

### Task 1: `set_breakdown` column and validation

**Files:**
- Create: `db/migrate/20260812120000_add_set_breakdown_to_movement_logs.rb`
- Modify: `app/models/movement_log.rb`
- Test: `test/models/movement_log_test.rb`

**Interfaces:**
- Produces: `MovementLog#set_breakdown` (Postgres integer array, default `[]`, never nil). `MovementLog` is invalid when `set_breakdown` is present and its elements don't sum to `reps`.

- [ ] **Step 1: Write the migration**

```ruby
class AddSetBreakdownToMovementLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :movement_logs, :set_breakdown, :integer, array: true, default: [], null: false
  end
end
```

- [ ] **Step 2: Run the migration**

Run: `rvm 4.0.6@wod-tracker do bin/rails db:migrate`
Expected: Output includes `AddSetBreakdownToMovementLogs: migrated`, and `db/schema.rb` now has `t.integer "set_breakdown", default: [], null: false, array: true` in the `movement_logs` table with the schema version bumped to `2026_08_12_120000`.

- [ ] **Step 3: Write the failing validation tests**

Append to `test/models/movement_log_test.rb`, inside the `class MovementLogTest < ActiveSupport::TestCase` block, after the existing `'clears the implement count when no load is recorded'` test:

```ruby
  test 'is valid when set_breakdown sums to reps' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 15, set_breakdown: [8, 7])

    assert_predicate movement_log, :valid?
  end

  test 'is invalid when set_breakdown does not sum to reps' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 15, set_breakdown: [8, 6])

    assert_not movement_log.valid?
    assert_includes movement_log.errors[:set_breakdown], 'must sum to reps'
  end

  test 'is valid with a blank set_breakdown regardless of reps' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 15, set_breakdown: [])

    assert_predicate movement_log, :valid?
  end
```

- [ ] **Step 4: Run the tests to verify the new ones fail**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/models/movement_log_test.rb -n "/set_breakdown/"`
Expected: 3 tests, 1+ failures — `'is invalid when set_breakdown does not sum to reps'` fails because no validation exists yet (the record is valid when it shouldn't be).

- [ ] **Step 5: Implement the validation**

Edit `app/models/movement_log.rb` to:

```ruby
class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement

  validate :set_breakdown_sums_to_reps

  private

  def set_breakdown_sums_to_reps
    return if set_breakdown.blank?
    return if set_breakdown.sum == reps.to_i

    errors.add(:set_breakdown, 'must sum to reps')
  end
end
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/models/movement_log_test.rb`
Expected: all tests in the file pass (0 failures, 0 errors).

- [ ] **Step 7: RuboCop**

Run: `rvm 4.0.6@wod-tracker do bundle exec rubocop app/models/movement_log.rb`
Expected: no offenses.

- [ ] **Step 8: Commit**

```bash
git add db/migrate/20260812120000_add_set_breakdown_to_movement_logs.rb db/schema.rb app/models/movement_log.rb test/models/movement_log_test.rb
git commit -m "Add set_breakdown column with sum-must-equal-reps validation"
```

---

### Task 2: Auto-populate `set_breakdown` on build

**Files:**
- Modify: `app/models/log.rb:70-75` (`build_movement_log_for`)
- Test: `test/models/log_test.rb`

**Interfaces:**
- Consumes: `MovementLog#set_breakdown=` (from Task 1). `Exercise#reps_defined_by_interval?`, `Exercise#movement`, `Movement#family_weightlifting?`, `Workout#exercises` (all pre-existing).
- Produces: `Log#build_movement_log_for(exercise)` now also sets `movement_log.set_breakdown` when either (a) the built `reps` is exactly `1`, or (b) the exercise is on a single-exercise, non-interval, weightlifting-family workout. `reps` blank or `0` (this app's existing "unspecified/max effort" sentinel) never triggers auto-population.

- [ ] **Step 1: Write the failing tests**

Append to `test/models/log_test.rb`, inside `class LogTest < ActiveSupport::TestCase`, immediately after the existing `'builds one movement recording per set for set-based lifting workouts'` test (ends at line 16):

```ruby
  test 'auto-populates set_breakdown as one set for a single-exercise weightlifting day' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    log.movement_logs.each do |movement_log|
      assert_equal [5], movement_log.set_breakdown
    end
  end

  test 'does not auto-populate set_breakdown for a single-exercise interval-scheme workout' do
    workout = Workout.new(name: 'Interval Ladder Test', score_type: :time)
    segment = workout.segments.build(position: 1, interval_scheme: '10-5')
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 1)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal 15, movement_log.reps
    assert_empty movement_log.set_breakdown
  end

  test 'does not auto-populate set_breakdown for a multi-exercise weightlifting workout' do
    workout = Workout.new(name: 'Multi Weightlifting Test', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 5)
    segment.exercises.build(movement: movements(:thruster), position: 2, reps: 5)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    log.movement_logs.each do |movement_log|
      assert_empty movement_log.set_breakdown
    end
  end

  test 'does not auto-populate set_breakdown for a single-exercise non-weightlifting workout' do
    workout = Workout.new(name: 'Single Gymnastics Test', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:pullup), position: 1, reps: 10)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal 10, movement_log.reps
    assert_empty movement_log.set_breakdown
  end

  test 'auto-populates set_breakdown for a single logged rep regardless of family or shape' do
    workout = Workout.new(name: 'Single Rep Test', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:pullup), position: 1, reps: 1)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal 1, movement_log.reps
    assert_equal [1], movement_log.set_breakdown
  end

  test 'does not auto-populate set_breakdown for the unspecified max-reps sentinel' do
    workout = Workout.new(name: 'Max Reps Test', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:pullup), position: 1, reps: 0)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal 0, movement_log.reps
    assert_empty movement_log.set_breakdown
  end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/models/log_test.rb -n "/set_breakdown/"`
Expected: 6 tests, failures on `'auto-populates set_breakdown as one set for a single-exercise weightlifting day'` and `'auto-populates set_breakdown for a single logged rep regardless of family or shape'` (both expect `set_breakdown` to be populated but it's still `[]`). The four "does not auto-populate" tests already pass trivially (nothing populates anything yet) — that's fine, they'll stay green through the next step.

- [ ] **Step 3: Implement auto-population**

Edit `app/models/log.rb`. Change `build_movement_log_for` (lines 70-75) to call the new helper, and add two new private methods immediately after it:

```ruby
  def build_movement_log_for(exercise)
    movement_log = movement_logs.build(movement: exercise.movement)
    metrics_for_movement_log(exercise).each do |metric|
      assign_performance(movement_log, metric, movement_log_metric_value(metric, exercise))
    end
    auto_populate_set_breakdown(movement_log, exercise)
  end

  # A single logged rep, or a dedicated single-lift weightlifting day, is unbroken by
  # construction -- no self-report needed. reps: 0 is this app's existing "unspecified/max
  # effort" sentinel (see ExercisePrescription#rep_prescription_metric), not a literal single
  # rep, so it's excluded here and left unpopulated like any other not-yet-known case.
  def auto_populate_set_breakdown(movement_log, exercise)
    return if movement_log.reps.blank? || movement_log.reps.zero?
    return unless movement_log.reps == 1 || single_weightlifting_exercise_day?(exercise)

    movement_log.set_breakdown = [movement_log.reps]
  end

  def single_weightlifting_exercise_day?(exercise)
    exercise.movement.family_weightlifting? &&
      workout.exercises.count == 1 &&
      !exercise.reps_defined_by_interval?
  end
```

Place these two new methods directly after `build_movement_log_for` and before `score_measurement`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/models/log_test.rb`
Expected: all tests in the file pass (0 failures, 0 errors) — this includes the pre-existing tests, confirming no regression.

- [ ] **Step 5: RuboCop**

Run: `rvm 4.0.6@wod-tracker do bundle exec rubocop app/models/log.rb`
Expected: no offenses.

- [ ] **Step 6: Commit**

```bash
git add app/models/log.rb test/models/log_test.rb
git commit -m "Auto-populate set_breakdown for single-rep and single-lift-day movement logs"
```

---

### Task 3: Permit and persist `set_breakdown` from the form

**Files:**
- Modify: `app/controllers/logs_controller.rb:76-89` (`log_params`)
- Test: `test/controllers/logs_controller_test.rb`

**Interfaces:**
- Consumes: `MovementLog#set_breakdown=` (Task 1).
- Produces: `LogsController#create`/`#update` now accept `movement_logs_attributes[N][set_breakdown]` as an array of integers.

- [ ] **Step 1: Write the failing tests**

Append to `test/controllers/logs_controller_test.rb`, inside `class LogsControllerTest < ActionDispatch::IntegrationTest`, immediately after the existing `'should create log with direct movement recordings'` test:

```ruby
  test 'creates log with a set breakdown' do
    assert_difference(['Log.count', 'MovementLog.count'], 1) do
      post workout_logs_url(@workout), params: { log: {
        score_type: :time,
        score_value: '5:30',
        movement_logs_attributes: {
          '0' => {
            movement_id: movements(:pullup).id,
            reps: 45,
            set_breakdown: %w[21 15 9]
          }
        }
      } }
    end

    assert_redirected_to log_url(Log.last)
    movement_log = Log.last.movement_logs.first
    assert_equal [21, 15, 9], movement_log.set_breakdown
  end

  test 'rejects a log whose set breakdown does not sum to reps' do
    assert_no_difference('Log.count') do
      post workout_logs_url(@workout), params: { log: {
        score_type: :time,
        score_value: '5:30',
        movement_logs_attributes: {
          '0' => {
            movement_id: movements(:pullup).id,
            reps: 45,
            set_breakdown: %w[21 15]
          }
        }
      } }
    end

    assert_response :unprocessable_content
  end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/controllers/logs_controller_test.rb -n "/set breakdown/"`
Expected: `'creates log with a set breakdown'` fails (`set_breakdown` stays `[]` because the param is filtered out by strong params — the model validation from Task 1 doesn't even get a chance to run). `'rejects a log whose set breakdown does not sum to reps'` currently passes for the wrong reason (the log is created with `Log.count` difference of 0 expected, but since `set_breakdown` is silently dropped, the record actually saves fine as `assert_no_difference('Log.count')` would then fail too, or the response is `:redirect` not `:unprocessable_content`) — expect 2 failures total.

- [ ] **Step 3: Permit the param**

Edit `app/controllers/logs_controller.rb`, in `log_params` (lines 76-89):

```ruby
  def log_params
    attributes = params.expect(log: [
                                 :score_type,
                                 :score_value,
                                 {
                                   movement_logs_attributes: [[
                                     :id, :movement_id,
                                     :reps, :duration_seconds, :load, :implement_count,
                                     :distance, :distance_unit, :calories, :notes,
                                     { set_breakdown: [] }
                                   ]]
                                 }
                               ])
    canonicalize_recorded_loads(attributes)
    attributes
  end
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/controllers/logs_controller_test.rb`
Expected: all tests in the file pass (0 failures, 0 errors).

- [ ] **Step 5: RuboCop**

Run: `rvm 4.0.6@wod-tracker do bundle exec rubocop app/controllers/logs_controller.rb`
Expected: no offenses.

- [ ] **Step 6: Commit**

```bash
git add app/controllers/logs_controller.rb test/controllers/logs_controller_test.rb
git commit -m "Permit set_breakdown as an array param on movement log recordings"
```

---

### Task 4: Recording form repeater markup and visibility

**Files:**
- Modify: `app/views/logs/_form.html.slim`
- Test: `test/controllers/logs_controller_test.rb`

**Interfaces:**
- Consumes: `ml.set_breakdown`, `ml.reps`, `ml.errors[:set_breakdown]` (Task 1), `ml_form.object_name` (Rails FormBuilder).
- Produces: a `.row.mt-2[data-controller="set-breakdown"]` block per movement-log card, visible only when `reps > 1` and (`set_breakdown` is blank or has a validation error), containing a `[data-set-breakdown-target="container"]` (existing rows), a `template[data-set-breakdown-target="template"]` (row to clone), and an "Add set" button (`data-action="click->set-breakdown#add"`). Each row has a "Remove" button (`data-action="click->set-breakdown#remove"`) and an `input[name="log[movement_logs_attributes][N][set_breakdown][]"]`. The Stimulus controller itself is written in Task 5 — this task only adds markup, so the Add/Remove buttons are inert until then (that's fine: these tests only check server-rendered HTML, not JS behavior).

- [ ] **Step 1: Write the failing tests**

Append to `test/controllers/logs_controller_test.rb`, inside `class LogsControllerTest`, immediately after the existing `'new log form only shows recording fields the workout prescribes'` test:

```ruby
  test 'new log form shows the set breakdown repeater when reps are not auto-populated' do
    get new_workout_log_url(workouts(:fran))

    assert_response :success

    # Fran: Thruster and Pullup both aggregate to 45 reps via the interval scheme, and neither
    # is auto-populated (multi-exercise workout) -- see test/fixtures/exercises.yml.
    thruster_card = css_select('.card.mb-3')[0]
    assert_select thruster_card, "[data-controller~='set-breakdown']" do |elements|
      assert_nil elements.first['hidden']
    end
    assert_select thruster_card, "input[name$='[set_breakdown][]']"
  end

  test 'new log form hides the set breakdown repeater for an auto-populated single-lift day' do
    get new_workout_log_url(workouts(:back_squat_5x5))

    assert_response :success
    card = css_select('.card.mb-3').first
    assert_select card, "[data-controller~='set-breakdown'][hidden]", 1
  end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/controllers/logs_controller_test.rb -n "/set breakdown repeater/"`
Expected: both tests fail — no `[data-controller~='set-breakdown']` element exists anywhere in the rendered form yet.

- [ ] **Step 3: Add the repeater markup**

Edit `app/views/logs/_form.html.slim`. First, add two new local variables inside the `= f.simple_fields_for :movement_logs do |ml_form|` block, right after the existing `- prescribed_reps = exercise&.prescription_metrics&.find(&:rep?)&.value` line (line 29):

```slim
    - prescribed_reps = exercise&.prescription_metrics&.find(&:rep?)&.value
    - show_set_breakdown = ml.reps.to_i > 1 && (ml.set_breakdown.blank? || ml.errors[:set_breakdown].present?)
    - set_breakdown_name = "#{ml_form.object_name}[set_breakdown][]"
```

Then, add a new `.row.mt-2` block right after the existing `.row.g-2` block closes (after the Calories column, which is the last child of `.row.g-2`) and before `.workout-card-toolbar.mt-2`. The full `.card-body` becomes:

```slim
      .card-body
        = ml_form.input :movement_id, collection: Movement.all, prompt: 'Select Movement', input_html: { class: 'movement', data: { controller: 'movement-select', action: 'change->log-exercise#reveal', 'implement-count-target': 'movementSelect' } }, label: false
        .row.g-2
          .col-6.col-md data-log-exercise-target="field" hidden=(relevant && (relevant & %w[rep]).empty?)
            = ml_form.input :reps, label: 'Reps', input_html: { class: 'recording-value', data: { 'lifting-score-target': ('reps' if @workout.calculated_lifting_score?), action: ('input->lifting-score#update' if @workout.calculated_lifting_score?) } }
          .col-6.col-md data-log-exercise-target="field" hidden=(relevant && (relevant & %w[seconds time]).empty?)
            = ml_form.input :duration_seconds, as: :group, label: 'Duration', append: 's', input_html: { class: 'recording-value' }
          .col-6.col-md data-log-exercise-target="field" data-implement-count-target="loadField" hidden=load_hidden
            = ml_form.input :load, as: :group, label: 'Load', append: load_display_unit, input_html: { class: 'recording-value', value: load_input_value(ml.load), data: { 'lifting-score-target': ('load' if @workout.calculated_lifting_score?), action: ('input->lifting-score#update' if @workout.calculated_lifting_score?) } }
          .col-6.col-md data-implement-count-target="field" hidden=(!ml.movement&.supports_implement_count? || load_hidden)
            = ml_form.input :implement_count, label: 'Implements'
          .col-6.col-md data-log-exercise-target="field" hidden=(relevant && (relevant & %w[distance foot inch meter]).empty?)
            = ml_form.input :distance, as: :group, label: 'Distance', append: distance_unit_label, input_html: { class: 'recording-value' }
            = ml_form.hidden_field :distance_unit, value: distance_unit
          .col-6.col-md data-log-exercise-target="field" hidden=(relevant && (relevant & %w[calorie]).empty?)
            = ml_form.input :calories, label: 'Calories', input_html: { class: 'recording-value' }
        .row.mt-2 hidden=!show_set_breakdown data-controller="set-breakdown"
          .col-12
            label.form-label Set breakdown
            p.form-text.mb-1 Optional: how did you break up your sets? Leave blank if unsure.
            div data-set-breakdown-target="container"
              - ml.set_breakdown.each do |set_size|
                .input-group.input-group-sm.mb-1.set-breakdown-row
                  input type="number" name=set_breakdown_name value=set_size class="form-control" placeholder="Reps"
                  button.btn.btn-outline-secondary type="button" data-action="click->set-breakdown#remove" Remove
            template data-set-breakdown-target="template"
              .input-group.input-group-sm.mb-1.set-breakdown-row
                input type="number" name=set_breakdown_name class="form-control" placeholder="Reps"
                button.btn.btn-outline-secondary type="button" data-action="click->set-breakdown#remove" Remove
            button.btn.btn-sm.btn-outline-secondary.mt-1 type="button" data-action="click->set-breakdown#add" Add set
        .workout-card-toolbar.mt-2
          button.btn.btn-sm.btn-outline-secondary type="button" data-log-exercise-target="editButton" data-action="click->log-exercise#reveal click->implement-count#toggle" Edit
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/controllers/logs_controller_test.rb`
Expected: all tests in the file pass (0 failures, 0 errors) — this includes all pre-existing form-rendering tests, confirming no regression to the other recording fields.

- [ ] **Step 5: Commit**

```bash
git add app/views/logs/_form.html.slim test/controllers/logs_controller_test.rb
git commit -m "Add set breakdown repeater markup to the recording form"
```

---

### Task 5: Set breakdown Stimulus controller and system test

**Files:**
- Create: `app/javascript/controllers/set_breakdown_controller.js`
- Modify: `app/javascript/controllers/index.js` (via generator, see Step 1)
- Test: `test/system/log_recording_form_test.rb`

**Interfaces:**
- Consumes: `[data-set-breakdown-target="container"]`, `[data-set-breakdown-target="template"]`, `.set-breakdown-row` (markup from Task 4).
- Produces: a `set-breakdown` Stimulus controller registered under that identifier, with `add(event)` (clones the template row into the container) and `remove(event)` (removes the clicked row's `.set-breakdown-row` ancestor) actions.

- [ ] **Step 1: Generate the controller scaffold**

Run: `rvm 4.0.6@wod-tracker do bin/rails generate stimulus set_breakdown`
Expected: creates `app/javascript/controllers/set_breakdown_controller.js` and adds the corresponding `import`/`application.register('set-breakdown', SetBreakdownController)` lines to `app/javascript/controllers/index.js`.

- [ ] **Step 2: Write the failing system test**

Append to `test/system/log_recording_form_test.rb`, inside `class LogRecordingFormTest < ApplicationSystemTestCase`, immediately after the existing `'Edit button reveals the fields the workout does not prescribe'` test:

```ruby
  test 'set breakdown repeater adds and removes reps-per-set inputs' do
    visit workout_url(workouts(:fran))
    click_on 'Log'

    thruster_card = all('.card.mb-3')[0] # Thruster: reps only -- see test/fixtures/exercises.yml

    within thruster_card do
      assert_no_selector '.set-breakdown-row'

      click_on 'Add set'
      click_on 'Add set'
      assert_selector '.set-breakdown-row', count: 2

      all('.set-breakdown-row input')[0].set('21')
      all('.set-breakdown-row input')[1].set('24')

      within all('.set-breakdown-row')[0] do
        click_on 'Remove'
      end
      assert_selector '.set-breakdown-row', count: 1
      assert_equal '24', find('.set-breakdown-row input').value
    end
  end
```

- [ ] **Step 3: Build JavaScript and run the test to verify it fails**

Run: `yarn build`
Run: `rvm 4.0.6@wod-tracker do bin/rails test test/system/log_recording_form_test.rb -n "/set breakdown repeater/"`
Expected: fails — clicking "Add set" does nothing yet because `SetBreakdownController` (freshly generated) has no `add`/`remove` implementation, so `assert_selector '.set-breakdown-row', count: 2` never becomes true.

- [ ] **Step 4: Implement the controller**

Replace the generated `app/javascript/controllers/set_breakdown_controller.js` with:

```javascript
import { Controller } from "@hotwired/stimulus"

// Dynamically adds/removes reps-per-set number inputs so an optional array field
// (movement_logs[][set_breakdown][]) can be posted as an ordered list, without requiring a
// fixed number of sets up front.
export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()

    this.containerTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML)
  }

  remove(event) {
    event.preventDefault()

    event.target.closest(".set-breakdown-row").remove()
  }
}
```

- [ ] **Step 5: Build JavaScript and run the test to verify it passes**

Run: `yarn build`
Run: `rvm 4.0.6@wod-tracker do bin/rails test test/system/log_recording_form_test.rb`
Expected: all tests in the file pass (0 failures, 0 errors) — this includes the pre-existing system tests, confirming no regression.

- [ ] **Step 6: Commit**

```bash
git add app/javascript/controllers/set_breakdown_controller.js app/javascript/controllers/index.js app/assets/builds test/system/log_recording_form_test.rb
git commit -m "Add set-breakdown Stimulus controller for the recording form repeater"
```

---

### Task 6: Full verification

**Files:** none (verification only).

- [ ] **Step 1: Run the full affected test surface**

Run: `rvm 4.0.6@wod-tracker do bin/rails test test/models/movement_log_test.rb test/models/log_test.rb test/controllers/logs_controller_test.rb test/system/log_recording_form_test.rb`
Expected: 0 failures, 0 errors.

- [ ] **Step 2: RuboCop on all changed Ruby files**

Run: `rvm 4.0.6@wod-tracker do bundle exec rubocop app/models/movement_log.rb app/models/log.rb app/controllers/logs_controller.rb test/models/movement_log_test.rb test/models/log_test.rb test/controllers/logs_controller_test.rb test/system/log_recording_form_test.rb`
Expected: no offenses.

- [ ] **Step 3: Confirm the branch is ready**

Run: `git log --oneline master..HEAD`
Expected: 5 commits (Tasks 1-5), one per task, in order.

No commit for this task — it's verification only.
