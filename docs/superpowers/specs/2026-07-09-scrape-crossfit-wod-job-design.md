# Daily CrossFit.com scrape job + recurring schedule (#1677) — Design

Brainstormed the orchestration job for the WOD-scraper epic: composes the already-merged
`CfWod::Fetcher` (#1674/#1718) and `CfWod::WorkoutParser` (#1721) into a daily, idempotent
`ScrapeCrossfitWodJob`, with a Solid Queue `recurring.yml` entry.

## Reconciling scope with #1676

Issue #1677's text says a `WodImport` row gets written "for every attempt." Issue #1676's design
(posted as a comment on that issue, not committed to the repo) already flagged this for
reconciliation here:

> Note for #1677: that issue's current text says a WodImport row is written "for every attempt."
> This design narrows that to failed/partial attempts only.

This design keeps that narrowing. `WodImport` stays a failure-only admin review queue:

- A clean parse produces no `WodImport` row — the `Schedule` that gets created is itself the
  record of success.
- A rest day produces no `WodImport` row — it's expected behavior, not an anomaly to review.
- Solid Queue already tracks job-level run/retry/failure history
  (`solid_queue_jobs`, `solid_queue_failed_executions`); the job doesn't duplicate that at the
  domain layer.
- `WodImport#status` currently supports `failed`/`partial`, but `CfWod::WorkoutParser` is
  all-or-nothing today (raises `UnparseableError` or returns a fully-validated `Workout`) — it has
  no "parsed but left content unhandled" signal. So this job only ever produces
  `status: failed`. `partial` stays in the enum, unused, until the parser grows a confidence
  signal (out of scope here).

## Architecture

```
ScrapeCrossfitWodJob#perform(date)
  → CfWod::Fetcher.call(date)                     # existing, #1674
      rest_day? → return (no-op, no WodImport row)
  → CfWod::WorkoutParser.call(page)                # existing, #1721
  → save / absorb_duplicate!                       # existing pattern, WorkoutsController
  → Program('Crossfit.com').schedules
      .find_or_initialize_by(posted_at: date)
      .update!(workout:)
  rescue UnparseableError, or FetchError after retries
      → WodImport.find_or_initialize_by(wod_date: date).update!(status: :failed, ...)
```

No changes to `CfWod::Fetcher`, `CfWod::WorkoutParser`, or the `WodImport` model/schema — this
is purely a new orchestration job plus config.

## `ScrapeCrossfitWodJob`

```ruby
class ScrapeCrossfitWodJob < ApplicationJob
  queue_as :default

  # retry_on's final-failure block runs with `self` bound to the job class (lexical scope,
  # not instance_exec'd), so it can't reach a private instance method -- hence the inlined
  # date expression here matching `perform`'s default, rather than a shared helper.
  retry_on CfWod::Fetcher::FetchError, wait: :polynomially_longer, attempts: 3 do |job, error|
    date = job.arguments.first || ActiveSupport::TimeZone['America/Los_Angeles'].today + 1
    WodImport.find_or_initialize_by(wod_date: date)
             .update!(status: :failed, error_message: error.message)
  end

  def perform(date = ActiveSupport::TimeZone['America/Los_Angeles'].today + 1)
    page = CfWod::Fetcher.call(date)
    return if page.rest_day?

    workout = CfWod::WorkoutParser.call(page)
    workout = persist(workout)
    Program.find_by!(name: 'Crossfit.com')
      .schedules.find_or_initialize_by(posted_at: date)
      .update!(workout: workout)
  rescue CfWod::WorkoutParser::UnparseableError => e
    WodImport.find_or_initialize_by(wod_date: date)
             .update!(status: :failed, raw_text: page&.body_text, error_message: e.message)
  end

  private

  def persist(workout)
    return workout if workout.persisted?

    workout.save!
    workout.absorb_duplicate!
  end
end
```

Key decisions:

- **Default date is "tomorrow in Pacific Time," computed explicitly**, not `Date.current`. The
  app's `config.time_zone` is unset (UTC default), and at the job's 8pm PT run time UTC has
  already rolled to the next calendar day — so `Date.current` would *coincidentally* already equal
  "tomorrow in PT." Relying on that coincidence would silently break if `config.time_zone` is ever
  set to a US zone, or if the run time moves earlier than ~5pm PT. Computing the PT date explicitly
  via `ActiveSupport::TimeZone['America/Los_Angeles']` is correct regardless of app-wide config or
  run time, and documents the timezone choice the issue asked for directly in code.
- **`retry_on` only wraps `CfWod::Fetcher::FetchError`** (transient/network) — 3 attempts,
  polynomial backoff. `CfWod::WorkoutParser::UnparseableError` is not retried at the job level: a
  parse failure is deterministic for a given page, so retrying won't change the outcome. It's
  caught inline and written straight to `WodImport`.
- **`workout.save!` is a bang call.** `WorkoutParser` already validates the `Workout` before
  returning it (`validate_workout!`), so a save failure at this point indicates a genuine bug, not
  a domain anomaly — it should surface as an unhandled job error (visible in Solid Queue's
  failed-executions), not a `WodImport` row.
- **`persist` handles both return shapes from `WorkoutParser`**: it may return an already-persisted
  `Workout` (named/hero-workout match or content-fingerprint match), or a fresh unpersisted one.
  Only the fresh case needs `save!` + `absorb_duplicate!` — the same pattern
  `WorkoutsController#create`/`#update` already use for the same reason (a save can still collide
  on `content_key` after `WorkoutParser`'s own duplicate checks, e.g. a race).
- **`Program.find_by!(name: 'Crossfit.com')` is inlined**, matching `db/seeds.rb`'s existing style.
  No new shared constant/finder — the string is duplicated in two places, accepted as-is per
  discussion (kept in scope; not worth an abstraction for a two-site literal).
- **Schedule upsert is keyed by `posted_at: date`**, not by `workout:`. This differs from the
  `find_or_initialize_by(workout:)` idiom used in hand-authored seed files (`db/seeds/cf_workouts.rb`
  etc.) — that idiom fits a workout-first seeding flow. Here, "today's WOD" is fundamentally a
  date-keyed concept: a same-day re-run must always resolve to at most one `Schedule` row for that
  date, updating its `workout:` in place even if the parsed `Workout` differs slightly between
  runs (e.g. an upstream content edit). Keying by `workout:` instead could produce two `Schedule`
  rows for the same date in that scenario.
- **`WodImport` upserts use `find_or_initialize_by(wod_date:)`**, not `create!` — `wod_date` has a
  DB-level unique index, so a second failure on the same date must update the existing row (fresh
  `raw_text`/`error_message`), not raise a uniqueness error.

## `config/recurring.yml`

```yaml
production:
  scrape_crossfit_wod:
    class: ScrapeCrossfitWodJob
    queue: default
    schedule: "TZ=America/Los_Angeles 0 20 * * *"
```

- **8:00 PM PT** — a two-hour buffer past the ~6pm PT release, reducing the odds of hitting
  CrossFit.com's empty-shell template (which `CfWod::Fetcher` already retries internally up to 3
  times) before the page is fully published.
- **`TZ=America/Los_Angeles` cron prefix** (parsed by Fugit, which Solid Queue's recurring
  scheduler uses) rather than a fixed UTC offset. This is the DST-safe choice: a fixed offset
  (e.g. `0 3 * * *` UTC) would drift an hour off 8pm PT across the PST/PDT transition; the named
  zone makes Fugit recompute the correct UTC instant every day, including on DST-change days.
- **No `args:`** — the job's own default parameter computes "tomorrow" fresh at execution time.
  `recurring.yml` values are static YAML, evaluated once at config load, so they can't express a
  relative "today + 1" that needs to be recomputed daily.
- **Production only** — no `development:` entry, so local dev machines don't automatically hit
  crossfit.com daily just from running `bin/dev`. Manual/local testing goes through
  `ScrapeCrossfitWodJob.perform_now(date)` in a console.

## Testing

New file: `test/jobs/scrape_crossfit_wod_job_test.rb`, using the same webmock pattern as
`test/tasks/cf_wod_rake_test.rb` (stub both the legacy-URL redirect and the modern-slug fetch
against fixtures already present under `test/fixtures/cf_wod/`).

Scenarios (per the issue's acceptance criteria):

1. **New import** — stub a normal WOD page. Assert a `Workout` and a `Schedule(posted_at: date)`
   exist under the `Crossfit.com` program; no `WodImport` row.
2. **Duplicate re-run** — run the job twice against the same date/stub. Assert exactly one
   `Schedule` for that date (updated in place, not duplicated) and no duplicate `Workout` (same
   `content_key`).
3. **Rest day** — stub `test/fixtures/cf_wod/modern_rest_day.html`. Assert no `Workout`,
   `Schedule`, or `WodImport` row is created.
4. **Fetch failure / retry** — stub a failing response for all attempts. Assert the job retries
   (mirroring `NoopJob`'s `assert_enqueued_with`/`perform_enqueued_jobs` idiom) and, after
   exhausting retries, a `WodImport(status: failed)` row exists for the date with `raw_text: nil`.
5. **Parse failure** — stub page content `CfWod::WorkoutParser` can't classify. Assert
   `WodImport(status: failed, raw_text: <body_text>)` and no `Workout`/`Schedule` created.

`config/recurring.yml` itself is not unit-tested — no existing precedent for that in this repo.
Correctness is by inspection plus the `TZ=` reasoning documented above.

## Out of scope

- Any change to `CfWod::Fetcher`, `CfWod::WorkoutParser`, or the `WodImport` schema/model.
- A `partial` status implementation (parser has no signal for it yet).
- A shared `Program.crossfit_com` finder/constant (string stays duplicated in `db/seeds.rb` and
  the job, per discussion).
- A manual-trigger rake task (not required by the issue's acceptance criteria; console
  `perform_now` covers manual/local runs).
