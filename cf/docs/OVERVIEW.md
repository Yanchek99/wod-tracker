# CrossFit Domain Knowledge

Treat `cf/docs/` as the durable project knowledge source for workout terminology, scoring, prescriptions, scaling, movement standards, metrics, and programming rules.

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
