# WOD Tracker Agent Guide

## Project Baseline

WOD Tracker is a Ruby on Rails app for tracking CrossFit workouts, logs, movements, metrics, programs, and schedules.

- Ruby 4.0.5
- Rails 8.1
- PostgreSQL
- Node 24.x
- Yarn 1.22.22
- Minitest with fixtures and Selenium system tests
- Hotwire Turbo, Stimulus, Slim, Bootstrap/Sass, Sprockets
- Devise, CanCanCan, RailsAdmin, Simple Form, Kaminari

## Setup And Commands

Use the project binaries and Bundler where possible.

Local shells may default to another Ruby. When running Ruby, Rails, Bundler, or test commands from an agent shell, use the project RVM gemset explicitly:

- `rvm 4.0.5@wod-tracker do bundle exec rails test`

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

CrossFit is the subject matter of this app. Before implementing domain logic, read `cf/docs/OVERVIEW.md`.

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

- State assumptions before implementing. If uncertain or multiple interpretations exist, ask rather than picking silently.
- Write the minimum code that solves the problem. No speculative features, abstractions, or flexibility that wasn't asked for.
- Touch only what the request requires. Don't improve adjacent code, refactor unrelated things, or clean up pre-existing dead code — mention it instead.
- Remove imports, variables, or functions that *your own changes* made unused. Leave everything else.
- Match existing style even if you'd do it differently.
- For multi-step tasks, state a brief plan with a verify step for each stage before starting.
- Every changed line should trace directly to the user's request.