# WodImport: Admin Review Queue for Unparseable WODs

Design for [#1676](https://github.com/Yanchek99/wod-tracker/issues/1676), part of the [#1679 WOD-scraper epic](https://github.com/Yanchek99/wod-tracker/issues/1679).

## Purpose

`WodImport` is a review queue for scrape/parse attempts that need admin attention. A row exists **only** when a CrossFit.com WOD for a given date could not be cleanly turned into a `Workout` — i.e. `failed` (unparseable) or `partial` (parser left significant content unhandled). A clean parse or a rest day produces no `WodImport` row; the resulting `Workout`/`Schedule` (or the absence of one, for a rest day) is itself the record of success.

This keeps the review queue small and actionable: every row in the table is something an admin should look at, typically resulting in a parser fix filed as a separate GitHub issue (no in-app tracking of that link — handled manually).

## Scope boundary

This issue delivers the migration, model, and RailsAdmin visibility only. It does **not** include the code that fetches/parses a WOD and writes a `WodImport` row — that orchestration belongs to [#1677](https://github.com/Yanchek99/wod-tracker/issues/1677) (`ScrapeCrossfitWodJob`), which already scopes "Fetcher → Parser → upsert Workout + Schedule ... write a WodImport row" as logic inside the job itself.

**Note for #1677:** that issue's current text says a `WodImport` row is written "for every attempt." This design narrows that to failed/partial attempts only — #1677 will need to be reconciled with this when it's brainstormed.

## Schema

`wod_imports` table:

| Column | Type | Notes |
|---|---|---|
| `wod_date` | `date`, `null: false` | Unique index. One row per date under review; re-running an attempt for the same date updates the existing row instead of duplicating it. |
| `status` | `string`, `null: false` | Enum: `failed`, `partial`. |
| `raw_text` | `text`, nullable | Plain body text captured at attempt time (`CfWod::WodPage#body_text`), for admin debugging. No `raw_html` column — the plain text is what was actually fed to the parser. |
| `error_message` | `text`, nullable | Why the attempt is in review (parser exception message / unparsed-content description). |
| `created_at` / `updated_at` | timestamps | |

No `source`/`source_ref` columns. [#1673](https://github.com/Yanchek99/wod-tracker/issues/1673) originally added equivalent columns to `workouts` for idempotency, then closed as superseded: identity is handled by `content_key` (`WorkoutFingerprint`) for workouts and `(program_id, posted_at)` for schedules, and a `source_ref`-style key would have actively fought that dedup behavior. `WodImport`'s own idempotency need (one row per date, update-not-duplicate on re-run) is satisfied by `wod_date` alone.

No `workout_id` column. A `partial` or `failed` attempt never produces a persisted `Workout` — there is nothing valid to link to.

## Model

`app/models/wod_import.rb`:

```ruby
class WodImport < ApplicationRecord
  enum :status, { failed: 'failed', partial: 'partial' }

  validates :wod_date, :status, presence: true
  validates :wod_date, uniqueness: true
end
```

`status` is string-backed (unlike this app's other enums, which are integer-backed hashes, e.g. `User#role`, `Workout#score_type`) — a deliberate choice for this model.

## RailsAdmin

A `config.model 'WodImport'` block in `config/initializers/rails_admin.rb` — the first model-specific block in this app (every other model relies on auto-discovery):

```ruby
config.model 'WodImport' do
  list do
    field :wod_date
    field :status
    field :error_message
    field :created_at
  end
end
```

- `raw_text` is excluded from the list view (long text) but remains visible on `show`/`edit` via RailsAdmin's default field inclusion.
- `wod_date` and `status` are filterable via RailsAdmin's default scaffolding for date/enum columns; no extra filter config needed.
- Authorization is already covered by the existing `can :manage, :all` for admins in `app/models/ability.rb`. No changes needed there.

## Testing

- `test/models/wod_import_test.rb`: presence validations (`wod_date`, `status`), uniqueness on `wod_date`, enum values (`failed`/`partial`).
- RailsAdmin visibility (`/admin/wod_import`) verified manually during implementation rather than via new request-test infrastructure — this app has no admin-fixture or RailsAdmin test precedent yet, and adding one is out of scope for this issue.
- No migration test; `db/schema.rb` is the source of truth per Rails convention.

## Out of scope

- Any code path that creates/updates a `WodImport` row (Fetcher/Parser/Job orchestration) — deferred to #1677.
- Linking a filed GitHub issue back to a `WodImport` row — manual workflow, no schema field.
- A `has_one :wod_import` association on `Workout` — not needed since `WodImport` never references a `Workout`.
