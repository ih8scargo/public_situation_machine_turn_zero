# Snail House body — Corkscrew, Standing Landinging and Quilling

Engineering Hallway handoff, 2026-11-08. Open **`/workshop/wedging-geometry`** in the existing Phoenix application (`mix phx.server`); the body study is first, with Round Two and Round One retained below. The instrument is **Quilling Stitching Needle** throughout. The possible later Quilting affordment has not been implemented or conflated with Quilling.

## Before this pass and preservation

The existing workshop furnished octagonal locality rules, Round One plan/section hypotheses, shared Gallery views, paired macaroni surfaces/clearance, distinct COB appointments and replayable experimental Footings with inherited PITTONING. It did not furnish the cabinet/table body, side-access apparatus, held-piece needle or measured bobbin resolution.

Reversible checkpoint: **`refs/checkpoints/snail-body-before-bb8377c8d1a2`**, commit **`bb8377c8d1a2fca74c5a48cd4d27874814aec566`**. Created with a temporary index; HEAD, branch and real index were retained. Existing work was already uncommitted. No implementation commit, branch switch, installation or production dependency was added.

SHA-256 comparison against the pre-edit manifest found existing code changes only in the dedicated Wedging LiveView, its scoped stylesheet, and the JS hook registration. The original geometry/rehearsal modules, original `/workshop` and production geometry, routes, station/acquisition registrations and prior tests remain byte-identical. This report and a link in the original workshop document are additional documentation.

## Changes and module boundaries

- [SnailBody](../lib/public_situation_machine_turn_zero/workshop/snail_body.ex): shared body geometry and bounded Quilling/bobbin state machine; side-fold and known planar projection references; replay-validated export/import.
- [SnailBodyPanel](../lib/public_situation_machine_turn_zero_web/components/snail_body_panel.ex): functional Phoenix component for body inspection, folding, held material, ordinary monitor, line controls and ledgers. The existing [WedgingGeometryLive](../lib/public_situation_machine_turn_zero_web/live/wedging_geometry_live.ex) owns the state and events.
- [snail_body.js](../assets/js/workshop/snail_body.js): oblique/opposed oblique, section, plan and FROM WITHIN renderings of the same model; near clipping, world-point outreadings, focus/click pinning and download. Reuses existing projection mathematics, with an explicit presentation frame; world coordinates do not depend on viewport size.
- `assets/js/app.js`: registers the local hook. `assets/css/wedging_geometry.css`: adds body-scoped responsive styling.
- New [domain tests](../test/public_situation_machine_turn_zero/snail_body_test.exs), [LiveView test](../test/public_situation_machine_turn_zero_web/live/snail_body_live_test.exs), [renderer tests](../test/js/snail_body_test.mjs), [browser sequence](../test/browser/snail_body.mjs) and [Elixir-generated geometry fixture](../test/fixtures/snail_body_contract.json).

This is one extended workshop, with an explicitly identified body-study model rather than rewriting acquired Round Two state. Correspondence to the earlier provisional Gallery shell is a review question; the new body does not silently replace its dimensions.

## Witnesses A–F

| Witness | Demonstrated behavior | Visual evidence |
| --- | --- | --- |
| A — Stationary standing | The circular Standing Landinging and persistent HERE square retain their coordinates through every fold/locality, camera change, Quilling and gathering. The computer is fixed too. | [Body](visual-witnesses/snail-body/01-stationary-body.png) |
| B — Quarter-turn wedging | Two partial annular strips share a plane. A radial-axis quarter turn rotates that plane from vertical to horizontal, with opening normal downward. Actual tunnel-wall quads, opening rings, PITTONING patch, THROUGH ALONG line and opposed XT/YT arrows follow that same transform. | [Vertical rings](visual-witnesses/snail-body/02-vertical-partial-rings.png), [downward](visual-witnesses/snail-body/03-downward-quarter-turn.png), [FROM WITHIN](visual-witnesses/snail-body/04-within-downward-tunneling.png) |
| C — Side access | A cutout in the cabinet side admits an instrumentation path. The path turns 90° at an explicit candidate reflection plane before reaching the inner aperture and ordinary monitor plane. Hiding the instrument changes visibility only; its path/provenance remain. | [Side outreading](visual-witnesses/snail-body/06-side-access-outreading.png) |
| D — Held time | Taking the Quilling Stitching Needle holds a piece. Human-authored material is retained with piece/author/affordment provenance. There is no timer, forced turn, automatic acquisition or anchored index. Draft text survives a line withdrawal. | [Held Quilling](visual-witnesses/snail-body/07-held-quilling-and-yt.png) |
| E — Bobbin resolution | Returning the needle relinquishes the hold and initiates gathering. Each action transfers the measured amount from outstanding to gathered. The line retracts along its actual finite routed path; accumulated winding is separately depicted. Zero outstanding readies the line FOR next PINNING without performing PINNING. | [Gathering](visual-witnesses/snail-body/08-measured-gathering.png), [readied with material retained](visual-witnesses/snail-body/09-readied-provenance-retained.png) |
| F — DOWN UNDER | The computer representation stands beneath an intervening shield, distinct from the table opening. The central vertical tabletop path meets that shield before reaching the computer. The table is not a direct computer lid. | [Section](visual-witnesses/snail-body/05-intermediate-and-down-under.png) |

[Mobile witness](visual-witnesses/snail-body/10-mobile-body.png). Hover or keyboard-focus geometry for world coordinates; click/Enter pins an outreading and Escape releases it. Some transparent meshes overlap visually; use the section and ledgers to distinguish them. The ordinary HTML monitor contains authored material without projection diagnostics; the geometric monitor/aperture/relay remain separately inspectable.

## Geometry, alternatives and limits

All new dimensions are **unitless experimental presentation registrations**, not new production extents. Existing HERE remains the square at Y=0, corners X/Z ±0.7; Standing Landinging retains center `[0,0,0]` and outer radius `0.48`. The displayed ring has a central opening of radius `0.24`. Neither rotates.

The square cabinet spans X/Z ±1.45, Y=-2.8..-0.2. Its table annulus is at Y=-0.1, outer radius 1.4, supported above the cabinet. The intermediate central shield spans X/Z ±0.45, Y=-0.5..-0.4; the computer representation spans Y=-2.65..-2.25. The central table opening is narrower than the intervening shield. This is a geometric obstruction witness, not a complete model of hand reach or computer hardware. No additional Human/TC entity or Tuple Ship container was introduced; measured placement relative to the actual computer remains open.

The spindle uses the vertical Y axis through the record center. A surfaced helical ribbon of radius 0.77..0.93 descends 1.5 units over 1.5 revolutions, starting at Y=-0.55. Six quarter-localities sample this same helix; they are inspectable emergence appointments, not acquired operational steps. A selected wedge center follows that locality. The two 300° partial-ring strips have radii 0.27..0.33 and center offsets ±0.18 in one plane. Their radius-0.3 centerlines intersect at local `[0, ±0.24]`. This demonstrates shared-plane overlap and an interlocking **candidate**; it does not establish a nonintersecting physical mechanical link.

Fold alternatives **0°, 30°, 45°, 60°, 90°** were tested at all six localities. The transform preserves distances and planarity. With radial basis R and tangent T, the second in-plane basis is `Y*cos(a) + T*sin(a)`; normal is `T*cos(a) - Y*sin(a)`. Thus 0° is vertical, 90° faces DOWN. A radius-0.22, depth-0.35 tube follows that normal. Its two mouths, the PITTONING patch and reciprocal bearings are derived geometrically. FROM WITHIN uses an eye on the selected THROUGH line, looking toward its opening. The patch is a geometric purchase candidate, **not another founding PITTONING acquisition** or a mechanical RE-STEP Foot.

JANUSITE continuity is witnessed as the two faces of the same connected annular-strip mesh under one rigid fold, with unchanged boundaries. No material law, load capacity, full-assembly collision clearance, seal, bodily passage or manufacturable joint has been verified.

The side aperture is in X=-1.45, with the wall genuinely cut around it. The relay runs along +X to `[-0.55,-0.65,-0.75]`, then +Z toward inner Z=0.75 and monitor Z=1.4. A candidate mirror normal `[1,0,-1]/sqrt(2)` reflects +X to +Z. Rays through the inner plane reach the monitor by deterministic homothety factor 1.65 from `[-0.55,-0.65,-0.25]`. The ledger also exposes the existing `Projection.model(defaults).vertical` relationship without changing it. **A measured transform joining this local relay to production Projectioning has not been appointed.** Neither visibility through transparent inspection surfaces nor this local fold proves final optical architecture.

## Quilling and YT accounting

The standing anchor at HERE `[0,0,0]` has a persistent lead to the bobbin readying point `[-1.15,-0.6,0.6]`. The ledger distinguishes that fixed association from paid-out excess; it does not claim a calibrated physical string circuit. Amounts are integers in thousandths of a unit. While held, withdrawal extends a measured prefix of one finite polyline, bounded to six outstanding units. At return, held provenance is relinquished but not erased. The needle remains at the Inkwell during gathering. Taking another hold is blocked until gathering completes.

At every transition:

`total withdrawn = outstanding + total gathered`

The browser witnesses withdrawal 1.5, partial gathering 0.5 (outstanding 1.0), then final gathering 1.0. The stored piece retains its original withdrawn trace, gathered amount, readying point, status and material associations. Authored records remain after relinquishment and restoration. The winding uses a helical arc-length parameter; its polygonal drawing is a sampled depiction rather than a calibrated physical spool. Capacity, tension, line thickness and physical winding fit remain open.

Controls advance gathering by 0.5 or resolve the entire measured remainder. No automatic time progression is introduced. Revision and piece IDs are bookkeeping provenance, not a new recurring constitutional turn or persistent ANCHORED TURNING INDEX. Returning with no withdrawn line readies immediately. No material is claimed already Stitched UPON the Road.

Download/restore uses schema `snail-body-quilling-v1`, separate from earlier round witnesses. Import replays at most 160 validated events, checks exact derived state, rejects corrupt amounts/state and limits input to 1 MB. State persists by explicit file download/restore; reload/reset discards the live session. Camera/fold selection, visibility and unsubmitted draft text are inspection/UI state and are not persisted as acquired standing.

## Tests and visual inspection

- `mix precommit`: **192 tests, 0 failures, 1 existing skip**; compile with warnings as errors, format and dependency checks pass.
- `node --test test/js/*_test.mjs`: **21 test files pass**, including two new body renderer tests.
- `mix assets.build`: passes, with no new packages.
- New real Chromium sequence: A–F, five Regardings, 0/45/90° browser folds, fixed-coordinate comparison, focus/pin/keyboard, hidden-instrument invariance, retained Quilling draft, exact partial/full gathering, readying, witness restore, unchanged Gallery export, 390px mobile and no page errors pass.
- Existing Round Two browser sequence passes paired courses, both appointments/Footings, inherited founding PITTONING, growth, saved witnesses and mobile.
- Existing `/workshop` browser sequence passes original geometry, opposed views, carriage/LOCK, persistence, Regarding, draw-out and mobile.

Separately inspected actual screenshots of oblique body, section, fold, FROM WITHIN, held Quilling/ordinary monitor and mobile. Framing was enlarged after visual inspection; the corkscrew now has ribbon surfaces as well as a centerline. No outstanding automated failures. Opaque occlusion and physical behavior are not covered by the diagnostic SVG renderer.

## Architectural review and stopping point

Remaining decisions: final handedness/axis/pitch and scale registration; whether partial rings should overlap, engage or interleave in separate planes; which folds acquire standing; measured registration of the cabinet-side relay; shield/shaft fittings and bodily side access; JANUSITE material continuity versus geometric continuity; bobbin capacity/tension and physical readying/PINNING conditions. The earlier Gallery dimensions remain intact rather than silently reconciled to these prototypes.

Stopped after the requested geometric and operative Pretending witnesses. No Great Big RE-STEP Foot, Landinging sweep, Projectioning reset, operational PINNING, new RE-STEP, automatic NAV-STEP, new ANCHORED TURNING INDEX, Gallery excursion, independent COB agent or Python production engine was added. THIS HERE APPROACHING LANDINGING/HERE remains distinct from THIS NEXT APPROACHING LANDINGING.

## Subsequent integration clarification

The [Zeroeth Bearinging integration](workshop-snail-zeroeth-turn-weaving.md) supersedes this pass's literal shield/mirror interpretation in the default apparatus. Those shapes remain in the historical body witness, while the integrated surface treats the intermediate furnishing as a relationship requiring registration, not an automatically appointed opaque component. The cabinet dimensions and prior replay schema remain intact.
