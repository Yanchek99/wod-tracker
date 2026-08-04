# Conditional Current Password for Profile Updates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Require `current_password` only when a user changes their email or password.

**Architecture:** Add a custom Devise registrations controller that chooses `update_with_password` for email/password changes and `update_without_password` for profile-only changes. Point the Devise registration routes at it and update the existing Slim form copy. Verify behavior with controller tests.

**Tech Stack:** Ruby 4.0.5, Rails 8.1, Devise, Minitest, Slim.

## Global Constraints

- Preserve existing Devise registration and account deletion behavior.
- Keep controllers thin and follow existing Rails/Minitest conventions.
- Do not add client-side JavaScript or unrelated refactors.

---

### Task 1: Add failing registration controller tests

**Files:**
- Create: `test/controllers/devise/registrations_controller_test.rb`

**Interfaces:**
- Tests use the Devise registration update route and the existing `users(:one)` fixture.

- [ ] **Step 1: Write tests for the four required behaviors**

Cover: profile-only update without `current_password` succeeds; email update without it fails and does not change email; password update without it fails and does not change password; email/password update with the correct current password succeeds.

- [ ] **Step 2: Run the focused test and verify it fails for the missing behavior**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/devise/registrations_controller_test.rb`

Expected: profile-only update fails under Devise's default `update_with_password` behavior.

### Task 2: Implement conditional Devise update behavior

**Files:**
- Create: `app/controllers/devise/registrations_controller.rb`
- Modify: `config/routes.rb`

**Interfaces:**
- `Devise::RegistrationsController#update_resource(resource, params)` selects the Devise update method based on email/password changes.

- [ ] **Step 1: Configure Devise registrations to use the custom controller**

Change the existing `devise_for :users` declaration to reference `devise/registrations`.

- [ ] **Step 2: Implement the minimal `update_resource` override**

Use `update_with_password` when email differs from the persisted email or password is present; otherwise use `update_without_password` after removing password fields and `current_password`.

- [ ] **Step 3: Run the focused controller tests**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/devise/registrations_controller_test.rb`

Expected: all focused tests pass.

### Task 3: Update the profile form and verify the relevant suite

**Files:**
- Modify: `app/views/devise/registrations/edit.html.slim`
- Modify: `test/controllers/devise/registrations_controller_test.rb`

- [ ] **Step 1: Make the current-password field optional in the form**

Set `required: false` and update the hint to say it is needed only for email or password changes.

- [ ] **Step 2: Add an edit-page assertion for the optional field and run focused tests**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/devise/registrations_controller_test.rb`

Expected: all focused tests pass.

- [ ] **Step 3: Build assets and run relevant regression tests**

Run: `yarn build:css && yarn build && rvm 4.0.5@wod-tracker do bundle exec rails test test/controllers/devise/registrations_controller_test.rb test/controllers/turbo_conventions_test.rb test/models/user_test.rb`

Expected: exit code 0 with no test failures or errors.

- [ ] **Step 4: Run RuboCop on changed Ruby files**

Run: `rvm 4.0.5@wod-tracker do bundle exec rubocop app/controllers/devise/registrations_controller.rb test/controllers/devise/registrations_controller_test.rb`

Expected: no offenses.
