# Panel assembly experiment — November 4, 2026

Branch: `experiment/panel-assembly`.
Pre-experiment checkpoint: `1a68442` on `experiment/constitutional-motor`.
That checkpoint preserves the previously uncommitted inscription-resolutioning work.

Open `/experiments/architecture`, then select **Panels alone** under **Compare
constructions**. The existing apparatus remains the initial view. **Panels with
existing apparatus** superposes both constructions in the same world and Regards.
Independent cabinet and Doll-side folds range from −90° to +90°; reset restores
45° and 0°. Copy current apparatus angles samples its current steering pull
without changing it. All comparison state is browser-local and resets on reload.

## Recovered stock

The first bounded inventory reuses six planar references already present in
`assets/js/crossing_rehearsal.js`:

| Panel | Dimensions | Attachment in this trial |
| --- | --- | --- |
| Monitor | 5 × 5 | Fixed at Z=0 |
| Cabinet face | 4.3 × 4.3 | Independent X-axis fold through head |
| Outward front | 5 × 5 | Fixed at Z=−3 |
| Doll side | 0.8 × 2.4 | Top edge on the same head axis |
| HERE ground square | 5 × 3 | Fixed operating reference |
| Glass | 0.48 × 0.48 | Fixed YZ reference at head |

The cabinet attachment is through its interior, not a claimed cabinet boundary
edge. The shared hinge is inherited as an explicit experimental choice, not a
recovered mechanical law. All rectangles retain their dimensions; no prescribed
inscription arc or swept passage is needed to compose this assembly.

The existing four cabinet side quadrilaterals reshape with the face. They are
excluded from rigid panel stock and remain visible in the existing apparatus.
The panel assembly consequently leaves the enclosure open rather than inventing
rigid sheets or assuming that a changing quadrilateral is a rigid panel.
Apertures are drawn as boundary curves, not Boolean cuts or a collision solid.
No panel thickness, hinge hardware or swept collision proof is asserted.

## Observations

- Equal cabinet and Doll folds make their containing planes coincide. Coincidence
  does not mean their finite panel boundaries or aperture centers register.
- The Doll top edge remains fixed. The cabinet normal and Doll normal are derived
  from those same panel transforms and are independent of Regarding.
- The inner aperture center is 0.5 units from the pinned head. Its radius 0.55
  plus that offset exceeds the cabinet opening radius 0.9: the inner circle is
  not wholly contained in the larger opening. This is an observation of existing
  reference dimensions, not a verdict about the intended physical apertures.
- The inherited Glass/nozzle half-widths yield 0.01 units of assumed margin per
  side. This scalar is reference arithmetic, not verified swept clearance.
- A containing-plane angle is reported without normal orientation; opposite
  normals can still describe coplanar planes.

Panel assembly operations send no domain events and do not alter Standing,
appointed instruments, existing steering pull or inscription geometry. Existing
apparatus controls continue to act on that existing apparatus explicitly.
No PITTONING acquisition, new FROM, Landinging exchange or RE-STEP is inferred.

## Implementation and verification

`assets/js/panel_assembly.js` owns the recovered stock, assembly transforms and
observations. The existing renderer imports shared rectangle and Doll stock
helpers, reducing coordinate drift. The comparison reuses its projection,
near-plane clipping, located Regards and section machinery.

- `mix precommit`: 128 tests, no failures, one existing skip.
- JavaScript suite: 67 tests passed, including rigid dimensions, fixed purchase,
  coplanarity, aperture observations and reference immutability.
- Asset build passed.
- `test/browser/panel_assembly.mjs`: panel-only/overlay visibility, independent
  folds, shared world points across Regards, actual sections, reset/copy,
  unchanged model and no outgoing domain operations, reload, narrow-screen
  layout and finite geometry passed without page errors.
- Browser screenshots were inspected in `/tmp/psm-panel-assembly`.

These observations establish a first panel inventory and assembly comparison.
They do not settle the full architectural composition or mechanical registration.

## Approach correction: lower steering purchase and explicit registration

The steering notice, wheel and pull now occupy a separate lower strip below the
SVG. Neither desktop nor narrow-screen layout overlays the reserved Regarding
projection. The SVG retains its own bounded display region.

The CH now deliberately uses **Lock aperture registration** after completing the
steering pull. Reaching the endpoint alone does not lock. This stores an explicit
registration relation with the head purchase, cabinet/Doll bearings and its
shared-hinge hypothesis basis. LOCK survives reload and prevents steering changes;
**Release registration** relinquishes that relation before another steering pull.
New instrument receipt requires the explicit registration. Previously received
instruments are retained without inventing a historical LOCK for them.

This carries an explicit approach action into the paired-aperture rehearsal. It
holds the appointed bearing; it does not prove that the current trial dimensions
resolve all finite aperture or material clearance questions. Independent panel
folds remain local alternatives for comparison, not changes to the locked apparatus.
The older drawer-return LOCK remains a separate retained mechanical rehearsal.

Validation: 129 application tests (zero failures, one existing skip), 67 JavaScript
tests; browser checks cover lower-strip separation on desktop/mobile, explicit
LOCK, disabled steering, persisted registration and release. Domain tests reject
premature and stale LOCK, prevent locked steering and preserve FROM/events on
release. Receipt tests now explicitly furnish registration.
