# Workshop Construction Assignment 03 — reciprocal projection and COB rehearsal

Implemented at `/workshop`, on `workshop/milestone-one`. No constitutional RE-STEP is performed. Assignment 02's four cubes, rail intervals, 25 stations, U13/N18 returns, N-derived MACHINE, carriages, yaw, outline rendering, LOCK and saved witnesses remain available. The earlier report is [Assignment 02](workshop-steeling-assignment-two.md).

## Registered apparatus

Coordinates are provisional workshop extents, independent of viewport size. Crossing occupies X=12–18, Y=0–6, Z=-3–3; lower region occupies X=12–18, Y=-6–0, Z=-3–3.

| Reference | Registration |
| --- | --- |
| Shared lower origin | [15,-3,0] |
| Acquisition-order source slots | [12+sequence,-3,0], sequence 1–5 |
| Lower source outline | X=12.5–17.5, Y=-3, Z=-0.5–0.5 |
| Vertical presentation offset | [0,6,0] |
| Oblique presentation offset | [dx,6,dz]; defaults dx=1, dz=1.5 |
| Editable bounds | dx=-1–1, dz=-2–2; UI step 0.1 |
| Crossing reference course | [12.75,3,1.5] → [17.25,3,1.5] |
| COB position | [12.75+4.5t,3,1.5], t=0–1 |
| Separate height reference | [18.5,0,2.5] → [18.5,6,2.5], six extents |

Each bearing has an explicit homogeneous translation matrix. Presentation is source + offset, so both candidates derive from each acquired Footing's same registered source. The common origin's candidate enters Crossing at origin + 0.5 offset (Y=0), exits at origin + 1.5 offset (Y=6), and has an intersection length equal to the offset's Euclidean norm. Its appointed inspection reference is origin + 2 offsets. The oblique candidate is straight and angled; it does not claim final elbow or Glass curvature. Bounds keep all five presentation points inside Crossing.

Vertical, oblique and both modes use the same construction and rehearsal. Departure and reciprocal cameras supplement structural, transverse and lower views. Blue dashed and magenta dotted paths distinguish the bearings; S/V/O with the same sequence number identify one Footing. Selecting its ledger button exposes full indexed identity and coordinates. All structural surfaces remain outlines; rear edges are retained. Dense labels can still overlap in particular views; alternate views and the ledger support inspection.

COB's progress is independently controlled: distance=4.5t along +X, at constant Y=3. Collection never changes t or physical height. Camera, yaw and viewport changes never change registered geometry.

## Deterministic rehearsal and witnesses

All 25 stations remain selectable. Each first acquisition appends a Footing with run-specific identity, acquisition sequence, indexed letter/group, before/after collected sets, acquisition construction revision, original station point, lower source reference/point and explicit provisional attachment description. Geometric reconstruction uses the construction parameters at acquisition, preserving earlier references after later course edits. Each Footing has a visible station association, lower witness, and vertical/oblique presentation witnesses.

Duplicate visits preserve the exact rehearsal state; separate occurrences of E remain distinct by index. Any five distinct stations set `READY TO STAND TOWARD RE-STEPPING`; a sixth new acquisition is rejected. Readiness preserves all five records and does not change the anchored index or local turn. COB's short companion text derives only from count.

Rehearsal has its own optimistic revision and deterministic replay validation. Reset creates a fresh run and retains the previous ledger in an archive. Bounds are 100 changes per run and 20 archived resets. Schema 3 serializes construction, projection, rehearsal and inspection mode. Rehearsal can continue while geometric LOCK remains active; it is deliberately outside the immutable construction LOCK snapshot. Projection edits are construction revisions and require release of LOCK.

Schema 1 and 2 remain inspectable read-only. Explicitly creating an Assignment 03 construction retains the entire original envelope, including view/yaw and LOCK provenance, as `legacy_source`. Original geometry is never silently rewritten. Compatibility readers compare numeric values rather than integer/float representation; Steeling calculations normalize parameter arithmetic so a JSON consumer changing `3.0` to `3` does not invalidate a truthful witness. Import remains bounded to 16 MB. Download/import is portable persistence; there is no database autosave.

## Files and boundaries

- `lib/public_situation_machine_turn_zero/workshop/projection.ex`: source, bearings, transforms, course and COB registration.
- `lib/public_situation_machine_turn_zero/workshop/rehearsal.ex`: acquisition transitions, Footings, readiness, archives, replay validation and companion text.
- `lib/public_situation_machine_turn_zero/workshop.ex`: schema 3, projection commands, rehearsal boundary, LOCK and earlier-schema derivation.
- `lib/public_situation_machine_turn_zero/workshop/legacy_v2.ex`: preserved Assignment 02 model/reader. `legacy_v1.ex` receives numeric comparison compatibility; `steeling.ex` receives consistent floating-point parameter arithmetic.
- `lib/public_situation_machine_turn_zero_web/live/workshop_live.ex`: controls, streamed station/Footing ledgers, imports and inspection.
- `assets/js/workshop/apparatus.js`, `projection.js`, `renderer.js`, `hook.js`: shared-source presentation, inspection cameras, outlined SVG and local event handling.
- `assets/css/workshop.css`: workshop-scoped apparatus and rehearsal styling.
- `test/public_situation_machine_turn_zero/projection_rehearsal_test.exs`, `test/public_situation_machine_turn_zero_web/live/projection_rehearsal_live_test.exs`: model, geometry and LiveView acceptance/regression tests.
- `test/js/workshop_test.mjs`, `test/browser/projection_rehearsal.mjs`: actual Phoenix-to-JavaScript projection contract, renderer and Chromium acceptance.
- Existing workshop tests/browser checks and `test/fixtures/workshop_initial.json` updated for schema 3; `workshop_assignment_two.json` preserves schema 2 and `workshop_projection_contract.json` records the shared mathematical contract.

Earlier assignments remain uncommitted in this working tree, including their route and asset integration. No commit or branch change was made for this assignment.

## Verification and visual witnesses

- `mix precommit`: 160 tests, zero failures, one existing skip; warnings-as-errors and formatting pass.
- `node --test test/js/*.mjs`: all 16 JavaScript test files pass, including workshop tests.
- `mix assets.build`: CSS and JavaScript build pass.
- Chromium: earlier workshop and Steeling acceptance checks pass. Assignment 03 covers both modes, all inspection cameras/yaw, arbitrary five acquisitions, duplicate suppression, separate E stations, progress independence, LOCK separation, reset/archive, JSON download/upload, mobile resize, and schema-2 import/explicit derivation.

Visual witnesses:

1. [Initial shared apparatus](visual-witnesses/workshop-projection/01-initial-shared-apparatus.png)
2. [Three acquired Footings](visual-witnesses/workshop-projection/02-three-acquired-footings.png)
3. [Both bearings with adjusted oblique parameters](visual-witnesses/workshop-projection/03-both-bearing-inspection.png)
4. [Five Footings through Crossing](visual-witnesses/workshop-projection/04-five-footings-through-crossing.png)
5. [Readiness and ledger](visual-witnesses/workshop-projection/05-readiness-ledger.png)
6. [Mobile readiness](visual-witnesses/workshop-projection/06-mobile-readiness.png)

## Unresolved and reserved

Station-to-lower-slot association is explicitly provisional provenance, not a discovered physical joint. Acquisition slots encode order and do not claim original stations are adjacent. Lower source Y=-3, Ground-side Y=-6, and N18 at Y=0 remain distinct references; their final mechanical attachment is unresolved. No final upper-aperture frame, tunnel curvature, elbow, Glass optics or operational Gallery curvature is appointed. The broad Steeling curve remains a structural hypothesis.

Stopped at inspectable bearings and five-letter rehearsal. No full descent, Camera A/B handoff, complete CAB furnishing, treadmill, production authentication, RE-ZIPPERING, constitutional RE-STEP, anchored-index advancement or local Ground reset was implemented.
