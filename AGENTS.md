# CrossFit Knowledge Management

## Knowledge Sources

Before implementing CrossFit domain logic:

1. Read relevant docs in `cf/docs/`.
2. Use source references only when documentation is missing or needs verification.
3. Prefer project documentation over assumptions.

## Documentation Maintenance

The files in `cf/docs/` may start sparse. Treat them as living project knowledge: update them when development clarifies terminology, movement standards, programming rules, or architectural/domain decisions.

When CrossFit domain knowledge is discovered or clarified:

- Update the appropriate file in `cf/docs/`.
- Prefer updating an existing file over creating a new one.
- Keep documentation concise and factual.

## Architectural Decisions

Project-specific decisions belong in:

- `cf/docs/decisions.md`

When a domain decision is made that affects future development:

1. Add an entry to `decisions.md`.
2. Include the rationale.
3. Reference the decision when implementing related features.


# Agent Guidelines

Derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

---

## 1. Think Before Coding

**Don't assume. Surface confusion. Present tradeoffs.**

- State assumptions explicitly before writing code
- When ambiguity exists, present interpretations — don't pick one silently
- Push back if a simpler approach exists
- Stop and ask when confused rather than guessing and running with it

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked
- No abstractions for single-use code
- No "flexibility" that wasn't requested
- No error handling for impossible scenarios
- If 200 lines could be 50, rewrite it

**The test:** Would a senior engineer say this is overcomplicated? If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't improve adjacent code, comments, or formatting
- Don't refactor things that aren't broken
- Match existing style, even if you'd do it differently
- If you notice unrelated dead code, mention it — don't delete it
- Remove imports/variables/functions that YOUR changes made unused

**The test:** Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

| Instead of...     | Transform to...                                      |
|-------------------|------------------------------------------------------|
| "Add validation"  | "Write tests for invalid inputs, then make them pass"|
| "Fix the bug"     | "Write a test that reproduces it, then make it pass" |
| "Refactor X"      | "Ensure tests pass before and after"                 |

For multi-step tasks, state a brief plan upfront:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

---

## How to Know It's Working

- Fewer unnecessary changes in diffs
- Clarifying questions come before implementation, not after mistakes
- Code is simple the first time
- Clean, minimal PRs with no drive-by refactoring

---

## Project-Specific Guidelines

<!-- Add your project rules here. Examples:
- Use TypeScript strict mode
- All API endpoints must have tests
- Follow existing error handling patterns in `src/utils/errors.ts`
-->
