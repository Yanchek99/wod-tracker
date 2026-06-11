@AGENTS.md

## Claude Code
- Run only affected tests, e.g. `bin/rails test test/models/user_test.rb` (or with `:LINE` for a single test). Only run the full suite when asked.
- For full-suite runs, delegate to a subagent and report only failures.