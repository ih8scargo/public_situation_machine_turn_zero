# Assignment 04 — locked U and reciprocal calibration

> Historical implementation witness. Current requirements and supersessions: [Geometry RE-surfacing Table](architecture/geometry/README.md). Source coordinates and original results below retain their historical scope.

## Inspection and baseline

Branch: `workshop/milestone-one`; HEAD: `b3fb3e471fe531784b2adec8203ffed1164d152a`. Earlier workshop work was already uncommitted/untracked. No branch change or commit was made.

Baseline: `mix precommit` passed **160 tests, zero failures, one existing skip**. All **75 JavaScript tests across 16 files** passed. Inspection covered the geometric registry, Steeling, projection matrices, acquisition replay, SVG renderer/hook, saved witnesses and the [Assignment 03 report](workshop-projection-assignment-three.md).

Confirmed unchanged:

- Four 6×6×6 regions: TC X=0–6, CH X=6–12, Crossing X=12–18, lower region beneath Crossing; independent carriage controls remain.
- All 25 indexed stations, U13=[15,3,0], N18=[18,0,0], N-derived MACHINE and the original broad curve hypothesis.
- The shared lower source and original vertical/oblique transforms; independent COB progress; five-Footing acquisition, reset/archive, restore and readiness.
- Camera yaw, existing Regardings, geometric LOCK and original witness snapshots.

The existing U post was explicitly a reference, not a mechanical aperture. No appointed U opening dimensions, enclosure, mechanical hinge or operational theatre existed. This incompatibility was reported before adding geometry. The new layer **adds hypotheses** anchored to U13 and Crossing; it does not replace or relocate existing registrations.

Existing separations are useful: `Steeling` supplies indexed geometry, `Projection` supplies source-to-presentation transforms, `Rehearsal` records acquired transitions, and JavaScript supplies inspection projection. A03's acquisition-order slots are representations, not the original stations or physical Footings. In particular, cross glyphs had no physical bottom. A04 keeps those distinctions and adds explicit inspection envelopes. Authored scene status remains separate from acquired standing.

## Entering the new witness

At `/workshop`, choose **Furnish Assignment 04 calibration witness**, below the assembly viewport. This explicit action preserves the initial working machine and avoids silently attaching new mechanics to older witnesses. Release an existing geometric LOCK before furnishing or editing. New Tunneling and Diorama buttons provide focused inspection; structural and oblique views remain available. The focused views magnify the apparatus, soften surrounding outlines and reduce background labels. Some assembly parts extend outside the focused viewport; their registered primitives remain present. No hidden-surface removal is introduced.

## Geometry and limits

All new sizes and mechanical placements below are **provisional workshop choices**, exposed in controls or the ledger. They are not recovered constitutional dimensions.

| Witness | Registration / constraint |
| --- | --- |
| U bearing | Origin at existing U13 [15,3,0], fixed world basis and transverse +Z reference; never follows camera yaw or stage curvature |
| U aperture | Flat XY opening at Z=0; default width/height 2.4, independently adjustable 1.8–3 |
| Bobbining enclosure | XY envelope 1.2×1.2 centered within U, depth witness Z=-0.4–0.4; no furnished CAB |
| Human relationship | [15,3,-3] → U13 → [15,3,2], THROUGH enclosure WITHIN U; no avatar |
| Related stage pivot | [15,0,0]; selectable X or Z hinge-axis hypothesis; the U itself stays fixed |
| Quarter-turn | Angle α ∈ [0°,90°]; no wrapping, clamping or movement past 90° |
| SIX radius | Default r=1.5, adjustable 0.5–1.8; geometric excursion, not acquired purchase |
| X-axis curve | [15,r sin α,r cos α]; Z-axis alternative [15+r cos α,r sin α,0] |
| Ground resolution | Drop current endpoint to Y=-6, then resolve to [15,-6,0] on the lower Ground reference line |
| Ground line | [12,-6,0] → [18,-6,0]; distinct from original N18 appointment at Y=0 |
| SIX upstage | Line at the quarter-turn 90° endpoint; role APPOINTED, placement/mark spacing PROVISIONAL |
| Six arc marks | Six guide marks at 15° intervals; explicit spacing hypothesis |
| FOUR / SIX / EIGHT | Relative radii r·4/6, r, r·8/6; no purchase or Footing-count interpretation |
| HERE / NEXT | Persistent squares centered [15,0,-1.5] and [15,0,1.5]; NEXT remains OVER ACROSS, projecting TOWARD HERE |
| Apron | Flat witness centered [15,0,-0.6], forward toward HERE; no furnished corridor |

The Situationing Stage shares the registered pivot, quarter-sector and SIX boundary. It contains already-standing and prospective scene material rather than being a theatre silhouette. The separate THREE/two-FOUR-post witness and Lanterning illumination line register conceptual relations without interpreting THREE as three acquisitions or turns.

The Doll's toe pins are [14.8,0,0] and [15.2,0,0]. The planar aperture pivots about that fixed toe line through β ∈ [0°,45°]. Its far corners are rotated from [0,0,0.8]; its toe corners remain exactly fixed. This **45° opening is independent of the 90° stage limit**.

Two wishbone frames offer independent, linked and counter-presented bearings. The Projectioning frame follows β; the Regarding frame is either its separately controlled -45°–45° value (default -20°), +β, or -β. They need no 180° flip. These are inspectable coupling alternatives, not a discovered linkage law. The bounded XT→YT polyline and pole UNDER the archway are reference witnesses; no tunnel Traversaling runs.

## Cameras, monitor and material

The renderer's inspection cameras are distinct from the following **registered appointments**:

- **ZERO:** Unfurnished until a first acquisition exists. Then begins at the bottom of a provisional 0.2-high inspection envelope centered on that Footing's original lower source point: source+[0,-0.1,0]. The original Footing is unchanged. The exact physical Footing bottom remains unresolved. Its line extends toward ONE.
- **ONE:** Registers the reference RE-STEP line starting [15,-6,-1.5] along +X. It performs no RE-STEP.
- **TWO:** The Human's aperture-toward line from HERE toward U13.
- **Projectioning Thing:** A separate appointment FROM OVER ACROSS THERE, standing WITHIN HERE. No Camera THREE is introduced.

ZERO, ONE and TWO explicitly retain HERE provenance. The monitor is a fixed flat XY plane, center [15,3,-2], with a provisional 2.4×1.8 outline. It does not rotate into the theatre. The Projectioning Thing origin is [15,2.5,-1.5]. Its opening-controlled ray hits the monitor at [15,2.5+0.5 tan β,-2]; at **β=45° it passes through the monitor center**, and other openings show measurable off-center hits. This is a provisional ray coupling, not completed optical machinery. ZERO/ONE's ruled resolution field distinguishes upside-toward and Groundward references working ACROSS one another.

Two scene patches share that monitor: HERE-derived **STANDING FOR STAGING**, centered Y=3.45, and NEXT-derived **STAGING FOR STANDING**, centered Y=2.5. Their explicit planar mapping is (x,y,z)→(x,targetY+z-sourceZ,-2). Prospective material lies below the monitor's Y=3 center-reference line while remaining above physical Ground Y=-6. Scene status does not create an acquisition. UP TOWARD, OVER, and UP OVER ACROSS have separate registered line witnesses and may coexist.

The ledger distinguishes Human-authored scenario material from TC illumination. The TC does not acquire authorship by illuminating it. A separate Lanterning line remains a conceptual reservation.

## Planar Prepositioning Ledger

Each significant new surface, aperture, line and projection surface is selectable through the ledger or its SVG path. The ledger also covers all 24 existing cube surfaces, the rail, U/N returns, original gallery hypothesis, source and vertical/oblique presentation surfaces, and independent COB course.

Each entry includes world points, frame origin and basis, a measured surface normal or first nonzero segment direction, a separately named reference bearing, FROM/WITHIN/UPON/OVER ACROSS appointments, stands/Regards/Projects TOWARD, limits, source provenance, material status and camera invariants. World-aligned frames are explicit; architectural prepositions are **not inferred from normals**.

Examples:

| Entry | MEASURED | APPOINTED / PROVISIONAL |
| --- | --- | --- |
| U aperture | Its actual XY outline and normal | Opening size is PROVISIONAL; fixed U relationship is enforced separately |
| SIX upstage | Its current points at the 90° range end | Upstage-end role is APPOINTED; radius/mark spacing are hypotheses |
| Doll toes | Same two endpoints at every β | PINNING UPON the aperture hinge is APPOINTED; aperture size/linkage remain hypotheses |
| Prospective monitor patch | Z=-2 and Y=2.35–2.65 | Status/source mapping PROVISIONAL; UPON monitor is explicitly registered, not guessed |
| Camera ZERO | Bottom-envelope point and line to ONE | Physical Footing dimensions/bottom are PROVISIONAL, original acquisition is untouched |

The full registry exposes furnishing-role references separately from an empty Traversaling-acquisition collection and an unfurnished `by-way-of`. THIS ONE FURNISHING COB is an inspection interpretation of the existing CH-fashioned rehearsal, not a rewrite of its provenance. THIS ONE TRAVERSALING COB and THIS FELLOW TRAVERSALING COB remain reserved. No autonomous Fellow COB or second ship is created.

Geometric excursions, Groundward relationships, actual acquisitions, authored half-plus-half contributions toward ONE, and completed RE-STEP turns remain separate fields. No half-Footing law is assigned to this rehearsal; completed RE-STEP turns remain zero.

## Persistence and architectural boundaries

Calibration has its own version-1 parameters, optimistic revision and bounded history of up to 100 changes. Geometric LOCK rejects calibration edits; rehearsal may continue under the existing A03 rules. Calibration is a separate witness, outside the original construction LOCK snapshots: those snapshots are preserved verbatim. Saving includes both the original construction and calibration history; the UI tracks unexported calibration changes as well as construction/rehearsal changes.

A calibrated download uses **schema-4 envelope / `extensions.calibration_v1`** containing the unchanged schema-3 construction. Import validates both the original construction/Footing replay and the bounded calibration history. It rejects malformed extensions, unknown extension members, or calibration smuggled into view fields. Earlier readers reject schema 4 instead of silently dropping calibration. Plain schema-3 files remain plain schema 3; absent calibration stays absent until explicitly furnished. Schema-1/2 read-only inspection and explicit migration remain supported. Import is still limited to 16 MB; there is no database autosave.

A minimal TC return line associates HERE, the lower Ground reference, and the current TC carriage center. It preserves FROM HERE WITH CH as provenance. It is not a furnished corridor, room, teleport or office complex.

## Files changed for this assignment

- `lib/public_situation_machine_turn_zero/workshop/calibration.ex`: new pure calibration registry, constraints, mechanical hypotheses, planar outreadings, role/context fields and history validation.
- `lib/public_situation_machine_turn_zero/workshop.ex`: new inspection-view names and explicit schema-4 export/import envelope. Existing construction coordinates and Footing operations unchanged.
- `lib/public_situation_machine_turn_zero_web/live/workshop_live.ex`: explicit furnishing, bounded forms, individual surface inspection, save-state tracking and restore.
- `assets/js/workshop/projection.js`, `renderer.js`, `hook.js`: focused Tunneling/Diorama/oblique inspection and local ledger selection; all-outline geometry retained.
- `assets/css/workshop.css`: scoped calibration controls, standing/prospective line treatments and focused-view presentation.
- `test/public_situation_machine_turn_zero/calibration_test.exs`: limits, fixed U/pins, curve/monitor geometry, ledger and persistence tests.
- `test/public_situation_machine_turn_zero_web/live/calibration_live_test.exs`: controls, selection, viewpoints, LOCK and restoring calibration/plain witnesses.
- `test/js/workshop_test.mjs`, `test/fixtures/workshop_calibration_contract.json`: Phoenix-generated geometry contract and renderer invariance.
- `test/browser/calibration.mjs`: browser acceptance and screenshots.
- This report and `docs/visual-witnesses/workshop-calibration/`.

## Acceptance evidence

- Baseline: **160 Phoenix tests**, zero failures, one existing skip; **75 JavaScript tests**.
- Final `mix precommit`: **167 tests**, zero failures, one existing skip; warnings-as-errors and formatting pass.
- Final JavaScript: **76 tests across all 16 files**, zero failures; workshop renderer alone has nine tests.
- `mix assets.build`: passes.
- All four browser suites pass: original workshop, Steeling, A03 projection rehearsal and A04 calibration. No browser page errors.
- A04 exercises α=0/45/90, β=0/30/45, both axis hypotheses, all three coupling alternatives, U and pin invariants, separate cameras, simultaneous material statuses, geometric LOCK, five acquisitions, archived reset, schema-4 download/upload restoration, all three requested inspection types and mobile registration invariance. Out-of-range input fails browser validity; domain tests also reject forged commands rather than relying on HTML bounds.

Visual witnesses:

1. [Initial Diorama calibration](visual-witnesses/workshop-calibration/01-diorama-initial.png)
2. [Diorama at the 90° limit / SIX endpoint](visual-witnesses/workshop-calibration/02-diorama-quarter-turn-90.png)
3. [Tunneling Regarding / pinned 45° aperture](visual-witnesses/workshop-calibration/03-tunneling-pinned-opening.png)
4. [Oblique reciprocal Regarding](visual-witnesses/workshop-calibration/04-oblique-reciprocal.png)
5. [Planar ledger / prospective monitor material](visual-witnesses/workshop-calibration/05-planar-ledger.png)

## Confirmed, provisional and unresolved

**Confirmed by this implementation:** bounded independent angle controls; fixed U registration; nested enclosure witness; fixed toe endpoints; measured Ground resolution; distinguished U13/N18; individually inspectable camera and Projectioning appointments; fixed flat monitor; persistent HERE/NEXT; separate authored material status and acquisition provenance; intact five-Footing readiness/archive/restore.

**Provisional:** physical aperture/enclosure dimensions, X/Z hinge alternatives, stage radius and sector, SIX marking spacing/location, wishbone coupling, 45° ray-to-monitor calibration, physical Footing envelope, camera/reference-line placements, XT/YT attachment and Ground-side TC return line. The original broad Steeling curve is still not declared operational Roundabout Gallery curvature.

**Unresolved:** exact mechanical axis/joints, final U aperture frame/depth, actual Footing size and bottom, final monitor/Zero/One optical apparatus, the connection between the N18 Groundward appointment at Y=0 and the lower Ground-side reference at Y=-6, final FOUR/SIX/EIGHT purchase interpretations, authored half-Footing contributions and operational pathways. Dense overlapping linework remains possible; selected ledger entries supply exact coordinates without claiming a completed physical mechanism.

The Human can now regard a fixed U and nested enclosure while related curvature changes within an enforced quarter-turn; compare it against separately pinned aperture opening and alternative wishbone bearings; inspect camera jobs separately from the Projectioning Thing; and read each surface's source, status and relational appointments without changing acquired standing.

**Stopped here.** No operational RE-STEP/RE-ZIPPERING, full tunnel/NAV-STEP, Fellow automation, full Lanterning behavior, purchase laws or office complex was implemented.
