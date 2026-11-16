# References

## CrossFit Level 1 Training Guide

Source:
https://library.crossfit.com/free/pdf/CFJ_English_Level1_TrainingGuide.pdf

Use this document as the authoritative reference.

## CrossFit Level 2 Training Guide

Source:
https://library.crossfit.com/free/pdf/CFJ_English_L2_TrainingGuide.pdf

## CrossFit Programming Basics Articles

Sources:

- https://www.crossfit.com/pro-coach/programming-basics-part-1
- https://www.crossfit.com/pro-coach/programming-basics-part-2

Use these as practical coaching references for workout-level programming,
variance variables, intensity-preserving workout traits, look-back planning,
template development, targeted blocks, and benchmark-based evaluation.

## CrossFit Hero Workouts

Source:
https://www.crossfit.com/heroes

Use this for canonical Hero workout names, structures, and Rx prescriptions.
The downloadable Hero PDF linked from this page is useful when the page display
does not expose all workout details.

## CrossFit Daily Workouts

Source pattern:
https://www.crossfit.com/YYMMDD

Examples:

- `https://www.crossfit.com/260601`
- `https://www.crossfit.com/260603`

Use daily workout pages to verify current Rx, intermediate, beginner, and
female/male prescription patterns. CrossFit commonly uses compact slash notation
for paired values, such as `800/1,000-meter row` or `105/155-lb push press`.

## CrossFit Games Open Workouts

Source pattern:
https://games.crossfit.com/workouts/open/YYYY/N

Examples:

- `https://games.crossfit.com/workouts/open/2020/4`
- `https://games.crossfit.com/workouts/open/2024/3`

Use these for source-confirmed lb/kg prescription pairs. Open workout weights are
published in the form `♀ 65, 95 lb (29, 43 kg)`, and the equipment notes state the
pound is the official unit with the kilogram as a convenience conversion. These
back the equivalences in `load-and-distance-equivalence.md`.

## CrossFit Movement List

Source:
https://www.crossfit.com/crossfit-movements

Use this page as the source for the base seeded movement names. Seed names are
normalized for app display by removing leading `The`, preserving CrossFit
hyphenation, and deduplicating case variants.

## CrossFit Affiliate Programming (CAP)

Source:
https://affiliate.crossfit.com/tools/programming-resources/benchmarks (affiliate login required)

CAP class plans for the benchmark, Hero, and Open workouts linked from this page
give each workout's Rx, Intermediate, and Beginner versions, its Intended
Stimulus, and a Scaling section (overview plus a movement-substitution table).
A local, gitignored copy lives in `cf/docs/workout-plans/` (see its `README.md`) when it
has been scraped on this machine. It is licensed affiliate content: reference
it, but never commit it or copy it verbatim into tracked files.
