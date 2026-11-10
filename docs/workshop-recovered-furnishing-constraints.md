# Recovered UN-FOLDING, centered stand and Footing constraints

The current witness at `/workshop/wedging-geometry` now includes **Recovered furnishing constraints · no solids moved** inside its CUBICAL–Gallery registration disclosure.

This pass records the recovered requirements and exposes implementation conflicts. It does not generate the recovered contraption, cylinder, stand, local COB solid, Room or Footings.

Checkpoint before this change: `refs/checkpoints/snail-constraints-before-890e6eea`, object `890e6eea78fca975dcd6e6cf7fecf78e79719efd`. Active branch/HEAD remain unchanged.

## Recorded requirements

| Relationship | Recorded constraint | Metric implementation status |
| --- | --- | --- |
| Ground | Independent architectural reference; Table does not define it | Snail-frame plane/transform not appointed |
| Human | AT the Table at H BELOW Ground G | No new world elevation selected |
| Table | Proposed diameter THREE; centered on axle; working surface coincident with G; central cylinder THROUGH it | Height transform, thickness and aperture/interface profiles unresolved |
| HERE CUBICAL | SIX units per side; vertical relation furnished through wedge UN-FOLDING when the Human stands and HERE is established | No recovered UN-FOLDING transform yet |
| RE-STEPPING contraption | Height SIX extents | Not inferred from the existing spindle endpoints or a scaled square |
| UP OVER / DOWN UNDER | Two distinct six-unit relationships from independent Ground | Not combined into one twelve-unit object |
| COB stand | Centered with Table/axle; rises ONE extent from G | No solid profile or world placement constructed |
| COB local CUBICAL | 1 × 1 × 1, corresponding WITH surrounding six-unit geometry | Frame, physical occupancy and eye calibration unresolved |
| Two-footing Room | Each Little ROUNDING Footing stands TOWARD half the extent TOWARD original NEXT | Actual Footing/course correspondence not supplied by existing records |
| Lanterning Bugs | ONE per Footing by default, reconfigurable to TWO or THREE | Requirement recorded; no retroactive assignments or configuration operation |
| Subsequent Footings | Accrete FROM WITHIN folding geometry in local 0-to-1 HERE | No new growth operation or numerical accretion cap |

Stand height, local COB CUBICAL and eye height are separate. The one-unit stand and unit CUBICAL are not automatically stacked into a two-unit body. Likewise, the two half-TOWARD relationships are not invented straight three-unit segments. Geometry, appointment counts and the six-unit extent remain separate quantities.

Ground remains independent. The missing item is its metric correspondence to the current Snail frame—not permission to define Ground using the Table's old elevation.

## Physical inspection and conflicts

**Centered stand versus cylinder: clearance is unresolved, not passed.**

The current `SnailBody` supplies a zero-width spindle reference from [0,0.4,0] to [0,-2.12,0]. It supplies no dimensioned central cylinder solid. Pixel stroke width is not shaft radius. The off-axis local tunnel dimensions and prior Table opening are not a verified central-cylinder bore or stand mounting interface.

The recovered stand and cylinder share the central plan axis. If solid components with positive radii occupy a common axial interval, they overlap. Current data do not establish those radii, occupied profiles or vertical spans. A unit reference CUBICAL does not establish the stand's material occupancy.

No bore, hollow support, shared solid, bracket, radial displacement, cylinder extension or Table relocation was presumed. Physical construction/registration stops before those changes. Review needs the cylinder outer/inner profile and span, stand footprint/occupancy and their measured mounting interface.

Additional implementation conflicts are exposed in the witness:

1. **UN-FOLDING:** the existing rigid radial fold and planar HERE matrix do not furnish the recovered six-unit vertical relation. A visual isotropic scale cannot supply it.
2. **Ground/levels:** the historical annulus is at Y=−0.1, while the current Human HERE/Seat reference is Y=0. Identifying that annulus with Ground above the Human would conflict with the current reference. It remains historical; no geometry was moved.
3. **Centered stand:** the old stand preview base [0.2,0,0] is offset and shares HERE's level. It is not the newly recovered centered stand FROM Ground.
4. **COB eye:** [0.2,0.63,0] and the earlier equal-eye-height/ray findings are legacy references, not calibration of the new stand/local CUBICAL.
5. **Footings:** existing records are explicitly local Scooping Footings, not protected RE-STEP acquisitions. Their turn-endpoint addresses do not furnish the recovered Room's two half-TOWARD relationships. They are not reinterpreted or relocated.

The two-turn prototype's operational bound remains a prototype limit; it is not adopted as an architectural limit on subsequent Footing accretion.

## Superseded previews

The active rehearsal no longer draws:

- The isotropically scaled normal-axis box as a furnished vertical CUBICAL.
- The prescribed 45° Craft heading ray.
- The offset, common-HERE-level stand as the recovered centered stand.

The plan-motion ghost remains for conditional square/Gallery comparison. Old scaled-box coordinates and contact calculations are retained under explicit historical labels, not presented as the recovered UN-FOLDING volume or current physical clearance.

45° remains a hypothesis requiring derivation from actual registration. The original aperture's separate registered bearing is not silently changed. HERE's six-unit requirement and HERE TOWARD the original NEXT remain intact.

All 337 source JANUSITE model faces remain in both paired outreadings. The existing body, aperture, axle reference, Table source mesh, material and acquisition records remain unchanged.

## Files and verification

Added `lib/public_situation_machine_turn_zero/workshop/snail_furnishing_constraints.ex`: pure requirement/constraint record with explicit unresolved profiles, superseded previews, source Footing provenance and conflicts.

Updated the existing gallery registration model and panel, renderer, scoped stylesheet, derived fixture and tests. There are no new routes, operation buttons, dependencies, furnishing handlers or canonical persistence fields.

- `mix precommit`: **221 tests, zero failures, one existing skip**.
- JavaScript suite: **24 test files pass**.
- Phoenix/Chromium sequence passes: recovered six/one/three-unit constraints; distinct above/below relationships; no assumed twelve-unit object; no prescribed 45° ray or scaled vertical box; unchanged source mesh count and world coordinates; unchanged canonical export/acquired Footings; unassigned Bug records; provenance, keyboard inspection, existing monitor/Regarding controls and mobile.
- Asset build and `git diff --check`: pass.
- [Protected-source hash witness](visual-witnesses/snail-recovered-dimensions/protected-files-sha256.json) confirms the original body, geometric registrations, apparatus, acquisition logic, Architecture core and original two-turn artifact were not changed.

Visual evidence: [constraint and conflict record](visual-witnesses/snail-recovered-dimensions/10-recovered-furnishing-constraints.png), [source mesh and plan-only ghost](visual-witnesses/snail-recovered-dimensions/01-source-registration.png), [mobile paired inspection](visual-witnesses/snail-recovered-dimensions/08-mobile-paired.png).

**Stopped at the existing boundary.** Requirements are recorded; no new Ground plane, solid interface, Room, Footing, Bug assignment, unfolding operation, RE-STEP or Traversaling was furnished.
