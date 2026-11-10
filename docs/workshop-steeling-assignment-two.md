# Construction 02 — JANUSITE STEELING structural index

Implemented on `workshop/milestone-one`, retaining its uncommitted Construction 01 work. HEAD remains `b3fb3e471fe531784b2adec8203ffed1164d152a`; no branch change, commit or publication. Open `/workshop` on the existing Phoenix server, or run `mix assets.build` and `mix phx.server` (development port 4001).

## Corrected standing and implemented instruments

The full rail assembly is **THIS ONE RE-STEPPING AND MAY BE RE-STOMPING CONTRAPTION**. Fresh schema-2 constructions register TC X=0–6, CH X=6–12, Projectioning Crossing X=12–18; each has Y=0–6, Z=−3…3. The architectural center is the Crossing, not longitudinal midpoint X=9. Its stable internal entity ID remains `central`. The lower Ground–monitor cube is X=12–18, Y=−6…0, Z=−3…3, UNDER the Crossing. All four cubes retain independent identities, surfaces, vertices and six-extent dimensions.

TC/CH carriages still move independently through origin X=0…12, with overlap observations and fixed Crossing/lower geometry. Restore initial arrangement resets carriages only. Restore initial structural hypothesis separately resets course parameters. Both actions remain revisioned construction commands. No course adjustment deforms the CUBICAL reservations.

All 25 stable station identities spell THE PUBLIC SITUATION MACHINE, segmented 3/6/9/7, indexed 1–3 / 4–9 / 10–18 / 19–25. Buttons and SVG witnesses select stations. The inspector exposes index, group, world position and structural references. Indices are not spatial extents. THE begins at [0,0,0].

The source model is pure Elixir (`Workshop.Steeling`), independent of SVG and camera. The renderer consumes registered samples/points rather than inventing a decorative path.

## Exact provisional geometry

The shared THE/PUBLIC cubic Bezier has controls:

- P0 = [0,0,0]
- P1 = [1, approach_bend, 0]
- P2 = [6,6,0]
- P3 = [9,6,0]

Its 49 inspection samples evaluate t=0…1 in 1/48 increments. The first nine stations use unequal t values `[0, .04, .12, .23, .36, .53, .69, .87, 1]`. No THE→PUBLIC corner angle is imposed.

SITUATION is an explicitly registered polyline from PUBLIC's final point through:
`[10,5.5,0]`, `[11.25,5,0]`, `[13,4,0]`, **U13 [15,3,0]**, `[16.2,2.5,0]`, `[16.8,1.8,0]`, `[17.4,.9,0]`, `[17.7,.4,0]`, **N18 [18,0,0]**.

PUBLIC and SITUATION share the provisional XY presentation plane, normal +Z. The gallery model records those 15 station IDs and an inspection boundary. It is neither a completed Gallery wall nor a mechanical member connection. All geometry currently lies at Z=0; plan view truthfully shows that plane edge-on, while transverse inspection shows it face-on.

**Return A** is `u-projection-return`, station 13. Its point [15,3,0] is the initial Crossing cube center. The provisional U-post reference spans [15,0,0] to [15,6,0], passing through U. Its upper endpoint supplies a reference TOWARD the future upper aperture; actual aperture frame and dimensions remain null. Changing N heading or reach does not relocate U, its post, or its registered center relation.

**Return B** is `n-ground-return`, station 18. The indexed Ground course runs from [0,0,0] to N, then sharply toward the center. Incoming Ground direction is +X; SITUATION's incoming direction is recorded separately. N's outgoing direction is `[cos(heading), sin(heading), 0]`. MACHINE staging begins at precisely N and inherits that direction. Its seven stations use unequal fractions `[.06,.15,.26,.4,.58,.79,1]` of the staging reach. The geometry therefore connects MACHINE to N instead of placing it behind an unrelated curve.

| Editable parameter | Initial | Trial bounds | Meaning |
| --- | --- | --- | --- |
| `approach_bend` | 3 | 1–6 extents | Y of first Bezier control point |
| `n_heading` | 135° | 105–165° | Outgoing N heading from +X toward +Y; not a prescribed 90° corner |
| `machine_reach` | 6 | 3–8 extents | Distance from N to the final MACHINE staging station |

Controls accept 0.1 increments. These are displayed engineering trial bounds, not constitutional measurements or restrictions. The initial 135° points from N toward U; varying it can make the approach miss U. It does not move U to manufacture registration.

## Inspection and permanent SEEING THROUGHING

Preserved opposed structural views, lower inspection and plan; added transverse gallery view and a −180°…180° vertical-axis camera pivot. Plan yaw rotates its in-plane basis. View and selection changes do not revise construction, alter provenance, modify coordinates, or advance turn indices. Yaw is saved in the separate schema-2 view specification.

U13 and N18 have distinct permanent markers and role labels, plus simultaneous textual return inspection. All 48 cube edges, 24 cube surface outlines, course members, return references and station markers remain drawn in every view. There is no opaque structural fill, depth sorting, culling or hidden-surface removal. Mobile retains all structural paths, return labels and a readable external inspector.

## LOCK, provenance and schema compatibility

Course edits and structural reset carry revisioned parameters in the construction provenance ledger. LOCK records full course geometry alongside carriage geometry and blocks both until release. Archived LOCK snapshots survive release/reset. Construction indices remain local 0 / anchored 0 throughout.

Schema 2 validates canonical geometry, parameter bounds, legal operation progression, all archived LOCK snapshots, and optional legacy source. It preserves selected structural view/yaw separately. Imports accept up to 8 MB; the existing 100 construction revisions plus final release remain bounded, and maximum history portability is tested.

Schema-1 fixtures, coordinates, names, provenance and LOCKs use frozen `LegacyV1` and `LegacyGeometry` readers. They load read-only and can be exported with their original construction values unchanged. No lettering course is invented for them. An explicit **Create Assignment 02 construction; retain original witness** action creates a new construction ID, corrected initial reservations and initial structural hypothesis. The complete original envelope, including old carriage arrangement and LOCK history, is retained once as `legacy_source`. This is a fresh derived construction, not a silent translation or rewriting of an old LOCK.

## Conflicts and open geometric questions

- The XY embedding, Bezier controls, SITUATION coordinates, U-post endpoints and MACHINE ray are explicit provisional test geometry. Richard/Bill must determine whether that plane and shape furnish the intended broad transverse presentation.
- Indexed N lies at Y=0. The lower Ground-side surface remains Y=−6. Their attachment is explicitly unresolved; no descent, elbow or connecting member has been fabricated.
- An adjusted MACHINE approach can cross the SITUATION course or pass the U reference. Crossings are observations, not inferred joints, collision failures or new constitutional relationships.
- U's post upper endpoint is a provisional reference inside the registered cube. Does the eventual upper aperture share that point, and what exactly constitutes the U center return? Aperture location/frame/dimensions remain unappointed.
- Does the Ground reference return change only heading/reach, or will N's position or its approach plane require editing? This first instrument fixes N and varies the outgoing course only.
- No final THE→PUBLIC corner hypothesis, member connections, loading law or mechanical joint is established.

## Reserved future geometry

Named references preserve counterclockwise descent, one initial winding, future winding-count adjustment, four quadrant angles, candidate stands around all four volumes, Camera A toward U/Fieldside, Camera B OVER ACROSS and reciprocal inspection. Their frames remain null; no descent animation or camera handoff is implemented. CAB furnishing, Glass curvature, NAV/treadmill, actual upper aperture, COB companion/consoling surfacing, Little ROUNDING Footing transitions, RE-ZIPPERING and RE-STEP mechanisms remain reserved. A future Regarding THROUGH Footings TOWARD RE-STEPPING FROM HERE has its own reserve.

## Files changed in this pass

- `lib/public_situation_machine_turn_zero/workshop.ex`: schema-2 state, parameter commands, LOCK/provenance validation, explicit legacy derivation.
- `workshop/geometry.ex`: corrected frames/names, future reserves.
- New `workshop/steeling.ex`: source geometry, stations, U/N returns and attachments.
- New `workshop/legacy_v1.ex`, `workshop/legacy_geometry.ex`: frozen Construction 01 compatibility.
- `lib/public_situation_machine_turn_zero_web/live/workshop_live.ex`: structural forms, streamed station selection, pivot, data inspection and legacy boundary.
- `assets/js/workshop/{projection,renderer,hook}.js`, `assets/css/workshop.css`: yaw, transverse view, visible course/markers and inspection styling.
- New `test/public_situation_machine_turn_zero/steeling_test.exs`; updated workshop domain, LiveView and JS tests.
- `test/fixtures/workshop_initial.json`: schema-2 cross-language fixture; new `workshop_milestone_one.json` preserves schema 1.
- Updated `test/browser/workshop.mjs`; new `test/browser/steeling.mjs`.
- This report and `docs/visual-witnesses/workshop-steeling/*`.

Construction 01's router and entry-point integration remain intact; no new package, migration or external rendering dependency was added.

## Executed verification and visual witnesses

- `mix precommit`: **148 tests, zero failures, one pre-existing skip**; compile/format checks passed.
- `mix assets.build`: passed.
- All 16 individual JS files: **73 tests passed**.
- Existing workshop Chromium circuit: passed carriage movement, overlap, LOCK/release, JSON download/upload, resizing/mobile, navigation and no page errors.
- New steeling Chromium circuit: passed all 25 station selections, U/N distinction, heading/reach edits retaining U/cubes/turn, MACHINE inheritance, camera pivot/view/resize invariants, permanent outline rendering, LOCK and reload, legacy export and explicit migration. No page errors.
- `git diff --check`: passed.

Visual witnesses, captured from the Phoenix workshop and inspected:

- [Overview — registered structural index](visual-witnesses/workshop-steeling/01-structural-index-overview.png)
- [Transverse inspection — separate U13 and N18 returns](visual-witnesses/workshop-steeling/02-u13-n18-return-inspection.png)
- [Mobile return inspection](visual-witnesses/workshop-steeling/03-mobile-returns.png)

Browser runners use the existing temporary Playwright module and cached Chromium via `PLAYWRIGHT_MODULE` / `CHROMIUM_PATH`; they accept `WORKSHOP_URL` and `WITNESS_DIR`. No application package was installed.

**Stopped after the structural index and inspection instruments. Await geometric review.**
