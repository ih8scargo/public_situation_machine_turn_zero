# Assignment 04A — five FROM stands, approaching Regarding and flat monitor

Implemented at `/workshop` under the amendment: **E3, I8, U13, N18, I23** are five inspection appointments along the original course. No straight architectural copy, new letter reservations, station relocation or operational acquisition was introduced.

## Inspected baseline and preserved standing

Branch `workshop/milestone-one`; HEAD `b3fb3e471fe531784b2adec8203ffed1164d152a`. The earlier assignments remain uncommitted/untracked. No commit or branch change was made.

Read [Assignment 04](workshop-calibration-assignment-four.md), the geometry/Steeling registry, projection and rendering, acquisition replay, LiveView controls and schemas 1–4. Baseline passed: **167 Phoenix tests, zero failures, one existing skip; 76 JavaScript tests**.

The initial straight-rail requirement conflicted with actual Steeling data: the first stations sample a Bézier at unequal parameters, followed by a polyline and N-derived MACHINE. That conflict was reported, then resolved by the user's five-stand amendment. The implementation preserves every original station coordinate and the existing curved course. Invariant `Geometry`, `Steeling`, `Projection`, `Rehearsal` and `Calibration` modules were not changed for 04A.

The four CUBICAL regions, rail intervals, U13=[15,3,0], N18=[18,0,0], MACHINE, U bearing, 90° stage limit, pinned 45° aperture, camera appointments, acquired Footings, archive/readiness and construction LOCK retain their prior registrations.

## Using the apparatus

The **APPROACHING REGARDING** panel sits above the original assembly viewport. Its five-position selector is a UI index, not a straight course. Choose E3/I8/U13/N18/I23 to appoint a primary FROM; U13 occupies the center selector position.

Controls are visible beside the presentations:

- **Approach TOWARD / Withdraw FROM**, plus a continuous distance slider.
- **ALONG THROUGH forward/backward**, using the actual next/previous station chord as an inspection bearing. No smooth canonical tangent or straightened course is invented.
- **AROUND ABOUT target**, orbit/elevation sliders, and a separate bearing-turn slider at the inspection eye. Rear and top inspection are independent of the U's architectural quarter-turn limit.
- **Previous/next letter target** and a locality selector for all 25 letters, all four CUBICAL regions and individual ledger surfaces/references. Temporary focus never appoints a sixth primary stand.
- Explicit **TOWARD surface**, **ALONG surface**, and **THROUGH selected aperture** operations. Surface normal is an inspection direction, not a constitutional preposition.
- **Stand TOWARD monitor**, normal-offset control, explicit THROUGH-plane checkbox, **Return to selected FROM**, and **Return to overview**.

The first inspection FROM, selected primary FROM, target, eye coordinates, orbit/bearing and monitor distance are disclosed outside the crowded geometry. The original overview and yaw are captured and restored. The Human's physical Groundward standing is not replaced by an inspection-eye position; CH/TC model positions never move as a consequence of inspection.

Selecting a visible inspection line/body focuses its registered locality. Selecting a surface identifies the corresponding planar ledger entry; the existing ledger also has a direct **Approach this ledger locality** button. Keyboard-accessible buttons, native range/select controls and a responsive stacked mobile presentation support inspection without custom pointer gestures.

## Registered eye movement and limits

The inspector keeps a versioned state separate from construction and calibration. It stores the primary station, original FROM snapshot, original overview, temporary target, distance, orbit, elevation, bearing turn, treatment and monitor-approach appointment. FROM snapshots are validated against the original station coordinates in construction provenance; they are not recalculated from screen dimensions.

For ordinary orbit inspection, with target P, distance d, azimuth a and elevation e:

`eye = P + d [sin(a)cos(e), sin(e), -cos(a)cos(e)]`.

Target approach ranges from 0.08 to 80 extents. Region inspection remains outside a bounding sphere (radius 5.2 plus 0.08 offset). Surface inspection maintains at least 0.08 signed distance on the appointed side unless THROUGH is explicitly selected. This is protection for the selected target, not whole-scene collision detection. Independent inspection may still pass through other outlined apparatus; no physical Traversaling is implied.

ALONG THROUGH stands at the captured FROM with a -Z inspection offset and looks toward a next/previous-station chord. The entire accumulated course is projected from its original points. This is an inspection bearing, not a new traversable route.

## Fixed monitor and actual presentation

The fixed A04 monitor remains centered **[15,3,-2]**, in XY, normal +Z, dimensions **2.4×1.8**, aspect ratio **4:3**. The new panel has two computed views:

1. The selected Regarding's perspective (or, during monitor approach, the observer's perspective of the physical display).
2. The unwarped image projected onto the fixed monitor frame.

The original assembly viewport remains available and shows a separate inspection-eye marker, target bearing and monitor-normal measurement. ZERO, ONE, TWO and the Projectioning Thing are not moved or renamed into this instrument.

**Optical relation remains PROVISIONAL.** A04 did not furnish complete optics, so this pass explicitly appoints a two-stage geometric relay:

- Actual world vertices are transformed into the selected Regarding's eye frame. For positive depth z, its normalized field is `(u,v)=(x/z,y/z)`.
- The independent A04 Projectioning Thing, at its existing origin, carries that field with gain **1.5**. At opening β, ray direction is proportional to `[1.5u, sinβ+1.5v cosβ, -cosβ+1.5v sinβ]`.
- Each ray intersects the actual fixed plane Z=-2. Physical XY coordinates map to the 2.4×1.8 display rectangle. This differs from copying the assembly viewport.
- A 0.03 near plane clips geometry before perspective division. Backward/projector-parallel rays are clipped; resulting polygons and lines are clipped to the finite display bounds.

Changing the stand, bearing or opening changes the computed image. During monitor approach the *source field appointment is retained* while the observer moves toward the display. The flat monitor is not a recursively self-observing camera. Its image is then projected from the observer's actual eye for the left-hand view; the right-hand view stays the fixed display frame.

For monitor approach, initial normal distance D and initial eye `(x0,y0,-2+sD)` are recorded. At offset q:

`eye = [15+(x0-15)q/D, 3+(y0-3)q/D, -2+s q]`.

The stand therefore approaches the finite display center, not merely an infinite plane at distant XY. The readout measures `abs(eye.z+2)` and signed normal distance. Ordinary approach stops at 0.08; explicit THROUGH permits signed offsets down to -20. Withdrawal and return preserve the original FROM. The projector origin and monitor do not translate.

The expandable relay record exposes source-field eye, observer eye, projector origin, opening, monitor frame, gain, near plane and U reference. This is an inspectable candidate optical mapping, not a claim to completed Glass/Camera ZERO–ONE mechanics.

## Letter bodies, white registration and source status

All 25 original indexed points receive a **non-destructive presentation extension**, not 25 new CUBICAL reservations. The deterministic block glyphs are extruded pixel geometry: height 0.5, width 5/7 of height, depth 0.08. The display basis is the fixed world basis inherited from the U reference. The FROM face lies at local Z=-0.04. These are explicit display choices; actual constitutional per-letter frames/orientations remain unappointed.

Three treatments are available: solid black; black with white contour/FROM-face registration (default); additional white structural lines. White contours are world-space edges of the extruded glyphs. They do not billboard, turn independently or alter station coordinates. As the inspection camera moves, these edges change perspective and may be occluded.

Black faces use painter depth ordering; architectural outlines retain rear edges. Intersecting display glyphs can produce painter artifacts, especially where original stations are close together. This is disclosed rather than treating the unequal spacing as a reason to relocate letters.

Teal and amber scene lines distinguish **STANDING FOR STAGING** from **STAGING FOR STANDING**. The existing authored material/provenance remains separate from illumination by the TC and from actual COB acquisition. Display geometry never grants acquired standing.

## Surface details and decomposition

Outside the viewport, selected-locality details expose original source records, points, frame/bearing, FROM/WITHIN/UPON/OVER ACROSS appointments, material status, provenance and relevant limits. The existing Planar Prepositioning Ledger remains the source for surfaces; normals do not generate architectural prepositions.

A modest decomposition record distinguishes constituent points of an existing surface, an **unfurnished candidate aperture**, an A04 appointed inspection-aperture witness where present, and **no operational instrument**. Selection never cuts an aperture or converts a surface into a camera. No connectors, rooms or office complex are furnished.

## Persistence and files

Inspection saves use **schema-5 envelopes**, retaining unchanged schema-3 construction and optional `calibration_v1`, plus `inspection_v1`. Inspection has its own optimistic revision and bounded history (500 changes). History, parameter bounds, original FROM registrations and overview are validated. Numeric zero controls are canonicalized for JSON round trips. Older readers reject schema 5 rather than silently dropping it. Schemas 1–4 remain supported; old witnesses acquire no inspection extension until the Human appoints a stand. Imports remain bounded to 16 MB.

Geometric LOCK continues to protect construction/calibration. Inspection may continue without rewriting LOCK snapshots, acquisitions or calibration history. Save-state tracking includes inspection; plain older witness import clears the inspection appointment. Inspection persistence is portable download/upload, not autosave.

Files added:

- `lib/public_situation_machine_turn_zero/workshop/inspection.ex`: five appointments, recoverable state/history, localities, measured eye/monitor movement and validation.
- `assets/js/workshop/inspection.js`: perspective, near/display clipping, projector intersections, immutable letter meshes and selected-target poses.
- `assets/js/workshop/inspection_hook.js`: isolated paired SVG presentation and local selection/lifecycle.
- `test/public_situation_machine_turn_zero/inspection_test.exs`, `test/public_situation_machine_turn_zero_web/live/inspection_live_test.exs`, `test/js/inspection_test.mjs`, `test/browser/inspection.mjs`, `test/fixtures/workshop_inspection_contract.json`.
- This report and `docs/visual-witnesses/workshop-inspection/`.

Files extended:

- `workshop.ex`: schema-5 import/export boundary.
- `workshop_live.ex`: discoverable controls, inspection/ledger coordination, original overview recovery and save-state tracking.
- `assets/js/app.js`: register the isolated hook.
- `assets/js/workshop/renderer.js` and `hook.js`: instrument position overlay and surface identification in the original overview.
- `assets/css/workshop.css`: scoped responsive controls, paired display, mobile intrinsic-width fix.

## Acceptance and visual witnesses

Final checks: **172 Phoenix tests, zero failures, one existing skip; 82 JavaScript tests across 17 files; asset build passes**. `mix precommit` includes formatting and warnings-as-errors.

The original workshop, Steeling, A03 projection rehearsal and A04 calibration browser suites pass. The new inspection browser suite checks all five primary stands, differing actual-course projections, close U13, side/rear/top views, three letter treatments, explicit aperture inspection, all four region/surface selections, along/toward surface controls, decreasing monitor distance with fixed monitor, calibration-responsive image, schema-5 restoration, original overview and mobile layout. No browser page errors.

Programmatic invariance evidence compares entire station arrays, entity geometry, acquired Footing records and rehearsal state before/after the five-stand sequence and later inspection. Those records remain identical. The test changes projection/opening only when explicitly exercising the pre-existing calibration controls; those edits are separately recorded, and acquisitions remain unchanged.

Visual evidence shows the apparatus/feed comparison side by side:

- Five FROMs: [E3](visual-witnesses/workshop-inspection/01-stand-3.png), [I8](visual-witnesses/workshop-inspection/01-stand-8.png), [U13](visual-witnesses/workshop-inspection/01-stand-13.png), [N18](visual-witnesses/workshop-inspection/01-stand-18.png), [I23](visual-witnesses/workshop-inspection/01-stand-23.png).
- [Close U13](visual-witnesses/workshop-inspection/02-u13-close.png), [white lines from the side](visual-witnesses/workshop-inspection/03-u13-white-lines-side.png), [rear/top](visual-witnesses/workshop-inspection/04-u13-rear-top.png).
- [Stand approaching the fixed monitor / actual computed image](visual-witnesses/workshop-inspection/05-monitor-approach-and-image.png).
- [Lower CUBICAL surface inspection](visual-witnesses/workshop-inspection/06-lower-surface-inspection.png), [mobile U13 and monitor](visual-witnesses/workshop-inspection/07-mobile-u13-monitor.png).
- [Temporary T1 target retaining primary U13 FROM](visual-witnesses/workshop-inspection/08-temporary-t1-from-u13.png), [U13 enclosure inspection](visual-witnesses/workshop-inspection/09-u13-enclosure.png).

## Remaining hypotheses and firm stop

The local glyph frame/body size, selection offsets, finite lens gain and two-stage relay are presentation/inspection hypotheses. A constitutional orientation for each letter, final relation of its FROM face to the inner U, and complete optics connecting ZERO/ONE/TWO, the Projectioning Thing and monitor remain unresolved. The U reference remains fixed, but it does not establish every letter's physical face by implication. Depth ordering is approximate for intersecting opaque glyphs; the rest of the architecture remains explicitly outlined.

The Human can now appoint FROM along the actual curve, inspect accumulated curvature, approach individual architecture at useful scale, bring a separately registered eye toward the fixed monitor, and return without losing the original FROM. No invariant geometry was changed. No acquisition, RE-STEP, RE-ZIPPERING, protected NAV-STEP, new Traversaling course, half-shell sculpture, lamppost suspension or Groundward office complex was introduced. Stopped for review.
