## Final Fix Wave - Issue 1815

### Changes

- Added `id DESC` as the secondary ordering for the workout history feed so pagination remains stable for logs sharing a `created_at` timestamp.
- Added a controller regression covering 26 same-timestamp logs across the first two pages.
- Removed the nested `GET /workouts/:workout_id/logs` route while retaining nested log creation.
- Added routing regressions for nested index removal and nested POST creation.

### Tests

Command:

```sh
rvm 4.0.5@wod-tracker do bin/rails test test/controllers/logs_controller_test.rb
```

Output:

```text
23 runs, 162 assertions, 0 failures, 0 errors, 0 skips
```

Command:

```sh
rvm 4.0.5@wod-tracker do bin/rails test test/routing/logs_routing_test.rb
```

Output:

```text
2 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```
