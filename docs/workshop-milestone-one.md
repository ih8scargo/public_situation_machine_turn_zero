Historical Construction 01 / schema 1 report. Current workshop: [Construction 02 — JANUSITE STEELING](workshop-steeling-assignment-two.md). Schema-1 witnesses remain inspectable without silent geometry migration.

# Phoenix geometric workshop — Construction 01

Branch: `workshop/milestone-one`. Starting checkpoint: `b3fb3e471fe531784b2adec8203ffed1164d152a`.
Route: `/workshop`. Run `mix assets.build`, then `mix phx.server`; the configured development endpoint is `http://localhost:4001/workshop`.

## Registered construction

This is an independent assembly workshop. It does not use Architecture/Motor/Instrumentation records or perform their operations. The actual Human and actual Terrestrial Computer retain their ordinary Ground relationship.

Provisional right-handed world convention: origin `[0,0,0]` at the rail start; +X longitudinal, TC toward CH; +Y UP; +Z transverse. One extent is a model unit, not a physical measurement. The rail reserves X=0…18. TC initially reserves X=0…6, central X=6…12, CH X=12…18; all reserve Y=0…6 and Z=−3…3. Lower reserves X=6…12, Y=−6…0, Z=−3…3. It is UNDER central, not another rail segment. Its Ground-side surface is Y=−6 and monitor-side surface Y=0. This opposite-face assignment is a provisional assembly choice, not a final Ground–monitor passage.

Each region has an identity, frame origin, identity basis, eight vertices, twelve identified edges, and six identified surfaces. Stable vertex indices belong to their region. The model registers UNDER and opposite-surface relationships. Each CH/TC carriage origin can move continuously through 0…12, keeping its six-extent volume within the rail reservation. Overlap is permitted and reported as longitudinal penetration, not prohibited by invented collision law. Central and lower geometry stays fixed.

Select a carriage, enter its rail start coordinate and Move. Select central/lower to inspect their coordinates. Restore initial arrangement resets both carriages and retains history. Structural selection and Regarding do not revise construction.

## Seeing THROUGHING

SVG renders every registered edge and every inspection surface boundary with `fill="none"`; no depth sorting, culling, masks, opaque planar faces or hidden-surface removal. Ground and monitor references have different dashed outlines. Exact coincident/projected edges can overlap visually, but all paths and their `data-world-points` remain inspectable.

Two opposed horizontal structural bearings both remain elevated, with plan and lower-region inspection views. They are orthographic engineering views, not specialized CAB frames. All views consume the same model. Display scaling and viewport clipping do not modify coordinates. Mobile retains the full outline assembly and a readable external legend; tiny SVG text is suppressed, not geometry.

### Mathematical quarry

`Geometry` adapts box-edge bit enumeration from `assets/js/elementary_opening.js:wireframeEdges`. Dimension/edge tests and a Phoenix-produced fixture verify it for six-extent cubes. `projection.js` reviews the vector/basis method in `crossing_rehearsal.js:locatedRegard/projectLocated`, using explicit orthographic engineering frames instead of those trial offsets, perspective constants, cabinet dimensions, or 45° assumptions. No existing renderer or apparatus CSS is imported into the workshop modules. The application bundles remain shared.

The hook owns only the ignored SVG subtree. LiveView controls stay outside. Local listeners and the server-event handler are removed on teardown. No ResizeObserver or document/window gesture listeners are needed. Styles use the `#geometric-workshop` boundary and unique classes; the existing layout is used with primary navigation hidden.

## LOCK and portable witnesses

Geometric LOCK freezes carriage movement/reset at the current arrangement and records a snapshot including geometry, identities, relationships, revision, provenance, fixed turn reserve and future interfaces. Release changes the lock status without deleting the old snapshot. Re-lock appends a new snapshot. Every construction command checks the submitted revision, including direct requests behind disabled controls.

Witness JSON schema 1 contains construction ID, complete registered model, carriage positions, LOCK and archived snapshots, provenance, and a separate `view.regarding`. Download JSON to preserve the construction. Reload with a file or pasted JSON. Import validates canonical geometry, legal provenance progression, every historical LOCK snapshot against its provenance prefix, active lock consistency, schema, and view. Invalid imports retain the current construction.

The loaded/exported construction and dirty status are shown. View/selection changes are not construction changes. “Download prepared” confirms dispatch to the browser; the user must retain the file. There is no database/server persistence or autosave; a page reload begins a new construction unless a witness is imported. Provenance is an inspectable construction ledger, not cryptographically authenticated authorship.

This bounded first workshop permits 100 construction revisions (plus a final LOCK release if needed) and imports up to 2 MB. A test verifies maximum lock/release history still exports/imports within the limit. Export before leaving; a fresh page begins another construction.

## Reserved only

Central upper aperture OVER ACROSS Snail House; UP ACROSS DOWN Ground–monitor passage; separate Human transverse Doll-head passage; CAB-side, within-CAB and Human transverse Regarding frames; future 25-letter XT→XT rail and center U return. These have identity and descriptions with null frames/dimensions. No passage curve, aperture size, head pivot, Snail House placement or lettering geometry is constructed.

Local turn 0 and anchored turning index 0 are reserved, never advanced by construction. No NAV-STEP, RE-STEP, RE-STOMP, PUFFING or POOFING is exposed.

## Inspection sequence

1. Open `/workshop`. Inspect the 18-extent rail, four colored volumes and coordinate convention.
2. Switch opposed structural views and plan. Observe rear edges THROUGH every foreground outline.
3. Select CH; move to 7.5. Select TC; move to 4. Compare coordinates and overlap observations.
4. Inspect central/lower coordinates and Ground/monitor references; neither moves with a carriage.
5. LOCK, download JSON, release, revise/reset. Old LOCK snapshots remain in the exported ledger.
6. Import the downloaded file. Inspect the restored positions, revision, provenance and LOCK.
7. Reserve specialized geometry decisions until this assembly has been bodily inspected.

## Verification

Tests live in `test/.../workshop_test.exs`, `test/.../live/workshop_live_test.exs`, `test/js/workshop_test.mjs`, and `test/browser/workshop.mjs`. JS consumes `test/fixtures/workshop_initial.json`, checked against the Phoenix constructor. Browser screenshots are produced under `/tmp/psm-workshop` by default; selected copies accompany this report.

Run `mix precommit`, `mix assets.build`, and each `test/js/*_test.mjs` with Node. Browser runner accepts `PLAYWRIGHT_MODULE`, `CHROMIUM_PATH`, `WORKSHOP_URL`, and `WITNESS_DIR`; temporary browser tooling is not an application dependency.

Executed against the completed implementation:

- `mix precommit`: **140 tests, zero failures, one existing skip**; warning-free compile, dependency-lock check and formatting completed.
- `mix assets.build`: passed.
- All 16 individual JavaScript files: **71 tests passed**, including four workshop tests.
- Chromium acceptance circuit: passed opposed views, complete outline/rear-edge paths, independent movement, unchanged central/lower geometry and turns, LOCK/release, actual JSON download and file upload, viewport resize, mobile overflow, navigation and no page errors.
- `git diff --check`: passed.
- Desktop and mobile screenshots were visually inspected. [Initial assembly](visual-witnesses/workshop/01-initial-throughing.png), [lower region / restored LOCK](visual-witnesses/workshop/02-lower-locked.png), [mobile](visual-witnesses/workshop/03-mobile.png).

The existing skipped naming-stitch test is unrelated to the workshop. Temporary Playwright tooling was installed under `/tmp/workshop-browser`, using cached Chromium; no application dependency was added. A Phoenix server was already listening on port 4001 and was used for browser verification.

## Changed files

Existing integration points: `assets/css/app.css`, `assets/js/app.js`, `lib/public_situation_machine_turn_zero_web/router.ex`.

New implementation: `lib/public_situation_machine_turn_zero/workshop.ex`, `lib/public_situation_machine_turn_zero/workshop/geometry.ex`, `lib/public_situation_machine_turn_zero_web/live/workshop_live.ex`, `assets/js/workshop/projection.js`, `assets/js/workshop/renderer.js`, `assets/js/workshop/hook.js`, `assets/css/workshop.css`.

New verification: `test/public_situation_machine_turn_zero/workshop_test.exs`, `test/public_situation_machine_turn_zero_web/live/workshop_live_test.exs`, `test/js/workshop_test.mjs`, `test/browser/workshop.mjs`, `test/fixtures/workshop_initial.json`.

This report and three PNG witnesses complete the change. Implementation remains uncommitted on the workshop branch, whose HEAD is the starting checkpoint. No future construction is authorized by this document.


Subsequent bounded geometry inspection: [Seat-to-Spiral Emergence evidence](workshop-seat-to-spiral-emergence.md). This derived registration preserves the preceding operational witness and its historical clearance findings.


Bounded CUBICAL/Gallery follow-up: [CUBICAL–Gallery–RE-SURFACING registration rehearsal](workshop-cubical-gallery-resurfacing-registration.md). This is an inspection ghost and conditional clearance witness; original standing, source material and operations remain unchanged.
