Wod Tracker
===========
[![CircleCI](https://circleci.com/gh/Yanchek99/wod-tracker/tree/master.svg?style=svg)](https://circleci.com/gh/Yanchek99/wod-tracker/tree/master)
[![Maintainability](https://api.codeclimate.com/v1/badges/ae3a8c6f161636552525/maintainability)](https://codeclimate.com/github/Yanchek99/wod-tracker/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ae3a8c6f161636552525/test_coverage)](https://codeclimate.com/github/Yanchek99/wod-tracker/test_coverage)

An open source webapp to track your workout of the day capturing key points of data.

## System Requirements
- [Postgress](https://www.postgresql.org)
- [RVM](https://rvm.io)

## RVM setup
- To install Ruby using RVM `rvm install 2.6.3`
- Set the current ruby to the one installed above `rvm use 2.6.3`
- Create the gemset needed for this project `rvm gemset create wod-tracker` make sure to use it `rvm gemset use wod-tracker`
- Ensure at a minimum bundler is install `gem install bundle`

## Setup
- run `bundle install`

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
