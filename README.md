WOD Tracker
===========
![CI](https://github.com/Yanchek99/wod-tracker/workflows/CI/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/ae3a8c6f161636552525/maintainability)](https://codeclimate.com/github/Yanchek99/wod-tracker/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ae3a8c6f161636552525/test_coverage)](https://codeclimate.com/github/Yanchek99/wod-tracker/test_coverage)

An open source webapp to track your workout of the day capturing key points of data.

## System Requirements
- [PostgreSQL](https://www.postgresql.org)
- [Yarn](https://yarnpkg.com/en/)
- [RVM](https://rvm.io)

## RVM setup
- To install Ruby using RVM `rvm install 4.0.5`
- Set the current ruby to the one installed above `rvm use 4.0.5`
- Create the gemset needed for this project `rvm gemset create wod-tracker` make sure to use it `rvm gemset use wod-tracker`
- Ensure at a minimum bundler is install `gem install bundle`

## Setup
- run `bundle install`
- run `yarn`

## Database
- If using a Mac with homebrew you can install postgresql by running `brew install postgresql`
- Run `rails db:setup` (If this is the first time you are setting the app up, else run `rails db:migrate`)
- Run `rails db:seed`

## Testing
- run `rails test`

## Static Code Analysis
- run `rubocop`

## Local Server
- run `rails s`

## CrossFit.com Workout Fetcher
- Fetch and parse a single day's workout from crossfit.com into a structured `Workout` and print it (does not persist anything):
  ```
  bin/rails "cf_wod:fetch[2026-06-20]"
  ```
- Raises `CfWod::Fetcher::FetchError` on network errors, unexpected HTTP responses, or a page that doesn't match either known crossfit.com template.
- Raises `CfWod::WorkoutParser::UnparseableError` when the workout's prose doesn't match a known format, movement, or prescription pattern.
