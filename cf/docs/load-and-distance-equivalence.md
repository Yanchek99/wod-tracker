# Load and Distance Equivalence

CrossFit expresses one prescribed load or distance in whichever unit suits the
audience — pounds, kilograms, or pood for load; miles, kilometers, or meters for
distance. These are **display conventions for the same prescription**, not
different prescriptions, so a workout's identity must not depend on which unit it
was published in (see `decisions.md`, "Prescribed Load Identity Is A Canonical
Magnitude"). This document records the source-confirmed equivalences used to
normalize any input unit to one canonical magnitude.

## Canonical units

- **Load → pounds (lb).** CrossFit states the pound is the official unit and the
  kilogram is a convenience conversion: the 2019 Open 19.5 equipment note reads
  *"The official weight is in pounds. For your convenience, the minimum acceptable
  weights in kilograms are 43 kg (95 lb.)"* Every existing seed also stores load
  in lb.
- **Travel distance → meters (m).** SI, and what existing seeds already use for
  runs, rows, and carries.

`pood` is an **input-only** unit (kettlebell prescriptions); it is normalized to lb
and never stored or displayed as pood. Heights (`foot`/`inch` target and box
heights) are out of scope and left unchanged.

## Why not exact arithmetic

The published equivalences are **rounded conventions**, and the rounding varies by
year. CrossFit published 65 lb as **29 kg** in 2024 (Open 24.3) but **29.5 kg** in
2022 (Open 22.3). Converting by physics (kg × 2.20462) would split published pairs
and disagree with the source. Normalization therefore uses the published table
below, with a rounded-conversion fallback only for values the sources do not list.

Because lb is canonical and kg the derived label, several kg labels may map to the
same canonical lb value (e.g. 29 kg and 29.5 kg → 65 lb). That is the intended
direction.

## Barbell / dumbbell lb ↔ kg (source-confirmed)

Each pair is published on games.crossfit.com in the form `♀ 65, 95 lb (29, 43 kg)`.

| lb  | kg    | Source (CrossFit Open) |
|-----|-------|------------------------|
| 35  | 15    | 24.1 (dumbbell)        |
| 50  | 22.5  | 24.1 (dumbbell)        |
| 65  | 29    | 24.3 (also 29.5 in 22.3) |
| 75  | 34    | 22.3                   |
| 85  | 38.5  | 22.3                   |
| 95  | 43    | 19.5, 20.4, 21.3, 23.1, 24.3 |
| 135 | 61    | 20.4, 23.1             |
| 185 | 83    | 20.4                   |
| 225 | 102   | 20.4                   |
| 275 | 124   | 20.4                   |
| 315 | 142   | 20.4                   |

For display (canonical lb → kg for metric users), use the most recent published kg
for each lb (e.g. 65 lb → 29 kg).

## Kettlebell pood ↔ kg ↔ lb (standard implements)

Pood is a standard CrossFit notation unit (L2 abbreviations list `pd (pood)`; L1
prescribes an SDHP with a "1-pood/36-lb. kettlebell"). CrossFit kettlebell
prescriptions are the standard 16/24/32 kg implements, and the benchmark ("Girls"
/ Hero) convention — the values the app's existing seeds use — labels them:

| kg | pood | lb |
|----|------|----|
| 16 | 1    | 35 |
| 24 | 1.5  | 53 |
| 32 | 2    | 70 |

Source variance: L1 renders the 1-pood kettlebell as **36 lb** in one scaled
workout, while benchmark prescriptions and the app seeds use **35 lb**. The
canonical value follows the benchmark/seed convention (35 lb) so imported
kettlebell workouts dedup against the seeded ones; the 36-lb rendering is noted as
a rounding variance, not a second prescription.

## Distance (source-confirmed)

Canonical meters. CrossFit's distance notation units are `m (meter)` and
`km (kilometer)` (L2 abbreviations).

| input   | meters |
|---------|--------|
| 1 mile  | 1600   |
| 1 km    | 1000   |

The mile → 1600 m convention matches CrossFit's benchmark usage (e.g. the 1-mile
runs in Murph and similar) and the app's existing seeds. `foot`/`inch` distances
and all height cases are left unchanged (see scope note above).

## Fallback rule (non-standard values)

For a load or distance whose input unit is not lb/m and whose value is not in the
tables above:

- **Load:** convert kg → lb as `kg × 2.20462`, rounded to the nearest 5 lb; convert
  pood → lb by first mapping to kg (`pood × 16`) then applying the kg rule. Marked
  as an approximation — prefer adding a source-confirmed row when a real
  prescription is encountered.
- **Distance:** convert to meters by exact factor (km × 1000, mile × 1609.344)
  rounded to the nearest meter, except the published mile → 1600 m convention above.

Fallback results are approximations and must not override a source-confirmed pair.
