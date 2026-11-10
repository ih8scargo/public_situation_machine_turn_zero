# Assignment 04B — outreading-mentings, Surfacing and Consoling

Implemented at `/workshop`, including the Constitutional Amendment. The ordinary Surfacing Stand contains the Human's Quilling office and a separately identifiable COB Consoling Stand FROM WITHIN it. It does not replace the diagnostic flat-monitor relay.

## Inspected and preserved

Read the [04A report](workshop-approaching-regarding-assignment-four-a.md), working tree, registered geometry, inspection renderer/hook, material/Footing provenance and schemas 1–5 before changing the workshop. Baseline: **172 Phoenix tests, zero failures, one existing skip; 82 JavaScript tests**.

Branch remains `workshop/milestone-one`, HEAD `b3fb3e471fe531784b2adec8203ffed1164d152a`. Existing uncommitted work was preserved. No branch change or commit was made.

No changes were made to `Geometry`, `Steeling`, `Projection`, `Calibration`, `Rehearsal` or `Inspection` geometric/state models. All original stations, CUBICAL regions, U13/N18, Ground, apertures, axle-related witnesses, bearings, Footings and protected operations retain their existing standing. This assignment adds no coordinate registrations to those models and does not validate or invent missing mechanical appointments.

## A. Hover, focus and pinned outreadings

Both the Regarding presentation and computed diagnostic monitor now support:

- Pointer hover preview with a compact tooltip and a readable outreading panel below the images.
- Keyboard focus on registered objects, Enter/Space to pin and Escape to resume preview.
- Click-to-pin; a native object selector provides keyboard access without traversing every mesh face.
- Transparent **14-pixel non-scaling hit strokes** for thin lines. Their enlarged hit area changes neither visual geometry nor coordinates.
- Explicit **Approach the pinned locality**; clicking to pin does not unexpectedly move the Regarding stand.

Records are read from existing primitives, planar registry, original letter stations and acquired Footing records. They disclose names, world coordinates, measured segment directions/surface bearings, frames, architectural relations where appointed, source provenance and display hypotheses. Normals and screen positions do not generate constitutional prepositions.

For example, U13 reads its original `[15,3,0]`, inherited U reference, original station ID and references. Its black extrusion and FROM-face registration are separately marked **PROVISIONAL display geometry**. A Footing marker reads its original acquired transition/provenance while identifying the marker/presentation dimensions as provisional. Planar entries retain their MEASURED/APPOINTED/PROVISIONAL outreadings.

Pinning selects the readout, not the architecture. On redraw it reads the current registration and labels an update; if a source disappears, the retained readout is explicitly historical and approach is disabled. Hover/focus/pin selections are transient inspector UI state, not authored material and not saved as construction/acquisition events. All event listeners stay inside the existing inspection hook and are removed on teardown.

## B. Ordinary Surfacing Stand

Choose **Open Surfacing & Consoling Stand** above the inspection panel. The ordinary flat presentation uses readable HTML text and forms, with **no SVG, projection lines, wireframes or diagnostic overlays**. The diagnostic relay remains separately available below it, unchanged in geometric purpose.

Its canonical identity is registered as:

> THIS ONE SURFACING STAND STANDING TOWARD STAGING WITHIN THIS ONE SITUATIONING FROM HERE.

It is appointed WITHIN THIS ONE STANDINGING LANDINGING, standing TOWARD THIS ONE CONSTITUTIONING HUMAN FROM HERE. Its coordinate field is deliberately `nil`: **physical placement awaits measured architectural registration**. The visual UI layout is presentation, not a claim to a new world-space location or monitor/extent.

## C. COB's Consoling Stand and HERE

Within the Surfacing boundary, a distinct Consoling office has the identity:

> THIS ONE COB'S CONSOLING STAND STANDING FROM WITHIN THIS ONE SURFACING STAND STANDING HERE FROM UPON THIS ONE STANDINGING LANDINGING.

Its registration retains the amendment's full purpose, with explicit relationships:

| Relation | Appointment |
| --- | --- |
| FROM WITHIN | This One Surfacing Stand |
| FROM OUT OF | **THIS HERE APPROACHING LANDINGING** |
| UPON | This One Standinging Landinging |
| TOWARD | This One Constitutioning Human FROM HERE |
| BY-WAY-OF | **This One Stewardly Co-Captain Co-Bobbining Thing** |
| Office | IN-QUESTIONINGMENTING; initially an appointed condition |

HERE links to the existing calibration registry's `HERE` appointment. NEXT remains distinct. That provenance link does not assign the Surfacing/Consoling offices the HERE square's coordinates or assert a measured attachment to the Standinging Landinging. Both new physical placements remain unappointed.

The visible BY-WAY-OF panel and relation outreading identify the Stewardly Co-Captain Co-Bobbining Thing. It is not a generic message channel or an external computation contract. The Consoling Stand is a relational COB office FROM HERE, not another Human or an independent agent.

## D. Quilling and the two routes

The Human can enter multiline Semantical In-Stringing-Mentings, save a draft, revise an existing material witness as a new witness, or begin a new draft while retaining prior records. **Save authored draft** or choose a route before exporting; unsaved textarea edits are not claimed to be persisted. Text is rendered literally and escaped, including markup-looking strings.

Two explicit routing buttons remain distinct:

1. **STAGING FOR STANDING** records Human-authored material TOWARD staging, with the Co-Situationing Doll's appointed co-labouring toward Stitching markings UPON the Road. Each record explicitly says the operation is **unfurnished / not performed**. Displaying or saving a marking does not Stitch it UPON the Road.
2. **INQUIRINGINGMENTING** records the Human's inquiry and its destination at COB's Consoling Stand, THROUGHBY/BY-WAY-OF the Stewardly Co-Captain Co-Bobbining Thing. The Consoling office visibly takes up its **appointed IN-QUESTIONINGMENTING condition following the inquiry**. It displays a Human inquiry reference, not a COB-authored answer or generated question.

Each routed record retains a stable ID, acquisition-independent sequence, revision, exact authored text, Human author, TC illumination distinction, source Surfacing identity, persistent HERE provenance, canonical destination/route, material status, optional `supersedes` link and `operation_performed: false`.

Revising never overwrites an earlier routed record. The previous material remains inspectable; the new record links back to it. Both routes preserve **STAGING FOR STANDING** rather than upgrading material to acquired STANDING FOR STAGING. No COB reasoning, Doll agency, Road operation or completed correspondencing runs.

## E. Persistence and boundaries

The new `surfacing_v1` extension stores stand identity, draft, revision context, material records and a replayable command history. **Schema-6 envelopes** contain the unchanged schema-3 construction and optional existing calibration/inspection extensions. Earlier schemas 1–5 remain supported; earlier readers reject schema 6 rather than silently discarding the new state.

Import replays Quilling/revise/routing commands and compares the canonical state strictly. Altered text, authors, destinations, supersession links or record fields are rejected. Surface material has its own optimistic revision, a 300-change bound and a 12,000 UTF-8 byte draft limit. Existing 16 MB import limits remain. There is no database autosave or external computation.

Geometric LOCK protects the existing construction/calibration while Human authoring remains a separate witness. Save-state tracking includes Surfacing changes. A plain earlier witness import clears the new stand state rather than silently attaching new material to it.

## Files changed

- **New** `lib/public_situation_machine_turn_zero/workshop/surfacing.ex`: canonical relational appointments, Human authoring/routing transitions, immutable revision links and replay validation.
- `lib/public_situation_machine_turn_zero/workshop.ex`: schema-6 envelope and optional-extension compatibility.
- `lib/public_situation_machine_turn_zero_web/live/workshop_live.ex`: ordinary offices, Quilling form, separate streams/routes, relation inspection, save/restore and authored-text component.
- **New** `assets/js/workshop/outreadings.js`: registration-derived object/line/letter/apparatus records.
- `assets/js/workshop/inspection_hook.js`: hover/focus/pin, forgiving hits and local listener cleanup. No projection math changes.
- `assets/css/workshop.css`: scoped ordinary presentation, readable outreadings and responsive layout.
- **New tests:** `test/public_situation_machine_turn_zero/surfacing_test.exs`, `test/public_situation_machine_turn_zero_web/live/surfacing_live_test.exs`, `test/js/outreadings_test.mjs`, `test/browser/surfacing.mjs`.
- This report and `docs/visual-witnesses/workshop-surfacing/`.

## Verification and visual witnesses

- `mix precommit`: **176 tests, zero failures, one existing skip**; formatting and warnings-as-errors pass.
- JavaScript: **84 tests across 18 files**, zero failures.
- `mix assets.build`: passes.
- All six browser suites pass: workshop, Steeling, projection rehearsal, calibration, approaching inspection and Surfacing/Consoling. No browser page errors.
- The new browser suite exercises real pointer hover/click, SVG keyboard focus and Enter/Escape, native keyboard selection, forgiving hit paths in both images, Human draft save/revision, the two routes, HERE/BY-WAY-OF, literal escaped text, schema-6 download/upload, restored draft/history and mobile layout.
- It compares the entire **LOCKed construction and existing acquired Footings** before and after authoring, outreading and restoration. They remain identical. Domain tests also round-trip every optional calibration/inspection combination and reject corrupted authored provenance.

Visual witnesses:

1. [Ordinary Surfacing and Consoling offices](visual-witnesses/workshop-surfacing/01-surfacing-consoling-offices.png)
2. [Human Quilling / staging route](visual-witnesses/workshop-surfacing/02-quilling-staging-route.png)
3. [Human inquiry / Consoling condition / distinct route provenance](visual-witnesses/workshop-surfacing/03-human-inquiry-consoling-condition.png)
4. [Real hover outreading in the preserved diagnostic presentations](visual-witnesses/workshop-surfacing/04-hover-outreading.png)
5. [Mobile ordinary Surfacing and Consoling](visual-witnesses/workshop-surfacing/05-mobile-surfacing-consoling.png)

## Registered, provisional and still unfurnished

**Registered now:** named relational offices, containment and TOWARD relations, persistent HERE source, explicit BY-WAY-OF, Human-authored draft and immutable routed records, appointed destinations and the inquiry-following questioning condition.

**Presented provisionally:** the ordinary flat UI layout; no physical placement of either stand is appointed. Existing black glyphs, inspection relay and geometric display hypotheses retain their prior labels. Diagnostic outreadings expose their sources without conferring acquired standing.

**Still to furnish:** measured placement/attachment within the Standinging Landinging, actual Road Stitching and Doll co-labouring operations, operational COB In-Questioningmenting, completed correspondencing, and any external computation contract. No new extent, protected NAV-STEP, RE-STEP, RE-ZIPPERING or independent agent was introduced.

**Stopped at the requested affordmentings.**
