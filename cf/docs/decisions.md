# Decisions

## 2026-06-03: Store Sex-Specific Prescriptions on Metrics

Metrics support nullable `female_value` and `male_value` columns for prescribed
female/male pairs. A metric may have one unisex `value`, both sex-specific
values, or no value. It may not mix `value` with sex-specific values, and it may
not store only one side of a sex-specific pair.

Rationale: exercise prescriptions are already represented as metrics, and the
measurement determines whether the value is load, distance, height, calories, or
time. Keeping the pair on `metrics` avoids recreating a second prescription
model and supports mixed prescriptions such as wall-ball load plus target
height.

Seed definitions must be source-driven. Existing user-created workouts are not
rewritten. Seeded CrossFit workouts may include sex-specific values inline when
CrossFit Hero or daily workout source data clearly identifies the female/male
pair.
