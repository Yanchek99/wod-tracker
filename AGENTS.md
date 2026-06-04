# WOD Tracker Agent Guide

## Project Baseline

WOD Tracker is a Ruby on Rails app for tracking CrossFit workouts, logs, movements, metrics, programs, and schedules.

- Ruby 3.4.9
- Rails 8.1
- PostgreSQL
- Node 24.x
- Yarn 1.22.22
- Minitest with fixtures and Selenium system tests
- Hotwire Turbo, Stimulus, Slim, Bootstrap/Sass, Sprockets
- Devise, CanCanCan, RailsAdmin, Simple Form, Kaminari

## Setup And Commands

Use the project binaries and Bundler where possible.

- Install Ruby gems: `bundle install`
- Install JavaScript packages: `yarn install`
- Set up a new database: `bin/rails db:setup`
- Update an existing database: `bin/rails db:migrate`
- Run the app: `bin/dev` or `bin/rails server`
- Build JavaScript: `yarn build`
- Build CSS: `yarn build:css`

Verification commands:

- Rails tests: `bundle exec rails test`
- System tests: `bundle exec rails test:system`
- Full Rails test suite: `bundle exec rails test:all`
- RuboCop: `bundle exec rubocop --parallel`

CI loads the test schema, runs `bundle exec rails test:all`, and runs RuboCop through reviewdog. Keep local changes compatible with those checks.

## Rails Engineering Guidelines

- Prefer Rails conventions and existing app patterns over new abstractions.
- Keep controllers thin. Put business behavior close to the model or concern that owns it.
- Use Rails 8 strong parameter style with `params.expect` where existing code does.
- Preserve the current Minitest, fixture, and system test style.
- Add or update focused tests for behavior changes. Start with the narrowest useful test, then run broader checks when shared behavior is touched.
- Use migrations for schema changes and keep `db/schema.rb` in sync.
- Do not edit generated build artifacts unless the requested change requires it.
- Avoid unrelated refactors, formatting churn, or cleanup outside the requested scope.

## Frontend Guidelines

- Prefer Turbo and Stimulus for interactive behavior before adding heavier JavaScript.
- Keep Stimulus controllers small and tied to clear DOM responsibilities.
- Keep Slim templates consistent with the existing view style.
- Use Bootstrap/Sass conventions already present in the app.
- Ensure forms, nested fields, Turbo frame responses, and system-testable workflows remain accessible and stable.

## CrossFit Domain Knowledge

CrossFit is the subject matter of this app. Treat `cf/docs/` as the durable project knowledge source for workout terminology, scoring, prescriptions, scaling, movement standards, metrics, and programming rules.

Before implementing CrossFit domain logic:

1. Read the relevant docs in `cf/docs/`.
2. Prefer documented project knowledge over assumptions.
3. Use external source references only when documentation is missing or needs verification.

When implementation or research clarifies reusable domain knowledge:

- Update the appropriate file in `cf/docs/`.
- Prefer updating an existing file over creating a new one.
- Keep documentation concise, factual, and source-backed when external references are used.
- Add useful source URLs or source families to `cf/docs/references.md`.
- Put project-specific domain or architecture decisions in `cf/docs/decisions.md` with a short rationale.

Document durable patterns, terminology, and modeling rules rather than one-off examples. If a pattern is plausible but not source-confirmed, mark it as uncertain or leave it out.

## Agent Workflow

- Inspect relevant files before editing.
- State important assumptions when they affect implementation.
- Make minimal, request-scoped changes.
- Match existing style even when another style might also be reasonable.
- Do not revert or overwrite user changes unless explicitly asked.
- Remove only imports, variables, functions, or files made obsolete by your own change.
- Verify changes with the most relevant commands available.
- If verification is skipped or blocked, report exactly what was not run and why.

## Agent Behavioral Guidelines

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.