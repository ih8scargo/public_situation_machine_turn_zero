# Proposed DIRT geometry/acquisition extension

[Geometry RE-surfacing Table](README.md) · **CANDIDATE EXPERIMENT** for future recording. This extends [DIRT's versioned start + ordered consequences](../../dirt-design/README.md); it neither replaces that design nor claims a new CSV importer.

## Versioned starting registry

An export would pin `dirt_profile`, canonical `geometry_contract=geometry-table-2026-11-13.v4`, mechanism algorithm/version, source hashes, frame/unit definitions, transform registry, material IDs and stable material addresses. Source identity, placement state and projected appearance are separate hashes. Every geometric record names its scope: `real-run`, `geometry-preview` or `condition-fixture`. Scope cannot be changed on import.

Start state includes Human persistent FROM, THIS HERE and THIS NEXT identities, furnished frame and its appointed measure, acquisition index, actual acquired localities (possibly empty), minimum capacity, actual material supply, FT/TF office IDs, selected wedging, condition and return registries, physical witness availability and version. Empty actual Footings with capacity TWO is valid; the recorder must not populate fictitious acquisitions.

## Ordered record families

| Record | Required dependencies and result |
|---|---|
| `geometry_proposed` / `geometry_rejected` | Source material/addresses, inherited placement, algorithm/config, candidate geometry, measured first interference face/segment IDs, retained accepted geometry hash. A rejection has no accepted material mutation. |
| `geometry_furnished` | Accepted mathematical/material furnishing, author/FT office, registry version and resulting geometry hash. Does not imply acquired extent. |
| `frame_acquired` | Human selection, already-furnished frame/capacity, measured Ground connection, PITTONING, appropriate RE-STOMPING, RE-ZIPPERING/securing, completed confirmation; before/after FROM and acquisition index. Atomic acceptance required. |
| `material_issued` / `material_taken` | Exact same material ID, FT issuance event, TF taking/encounter, intended target and actual relation; only permitted within lawfully acquired working extent. Historical rehearsal scope must remain rehearsal. |
| `footing_encountered` / `footing_acquired` | Source coil ID, material address, inherited entrance, occupied clearance and completion witness; persistent FROM ZERO is separate from local Footing receipt. No automatic constitutional index increment. |
| `condition_appointed` / `condition_satisfied` | Condition ID/author/version/subject; at least one condition including possible presence; actual satisfaction evidence. Appointment is not satisfaction. |
| `exit_satisfied` / `buttoning_ready` | Exit witness, completed local standing, condition set, next already-furnished tunnel, state readiness, RE-STOMPING and COB RE-ZIPPERING; return source/status. |
| `buttoning_encountered` / `buttoning_activated` / `passage_completed` | Distinct records with readiness event and inherited available tunnel; activation cannot manufacture passage or acquired frame. |
| `ceiling_arrived` | Actual acquired locality/Footing, measured height/extent, bearing, exit/return status and separate provisional occasion name. Does not advance index. Inspection uses `ceiling_reference_inspected` instead. |
| `regarding_changed` / `reference_appointed` | Camera/map/half-screen parameters or Human inscription and reference ID. Source geometry hash, material IDs and acquired FROM unchanged. |
| `axle_or_pocketing_proposed` | Inherited source Footings/turn/transform, candidate orientation, actual vs prospective and unresolved attachment; no pre-populated Gallery. |

Each record includes sequence, event/command ID, previous digest, expected revision, actor/office, exact ordered prepositioning, dependencies, inherited and resulting hashes, effective configuration, status, time measurement provenance where available and separate index/local receipt deltas. Never infer a turn boundary or acquisition from height, elapsed time, entry count or view order.

## Small dependency example

```json
{
  "geometry_contract": "geometry-table-2026-11-13.v4",
  "scope": "geometry-preview",
  "event_id": "proposal-2",
  "kind": "geometry_rejected",
  "subject": "coil-candidate-2",
  "prepositioning": "THROUGH THE CENTER OF THE APERTURE AND FOLDS UNDER FROM WITHIN",
  "object": "table-aperture",
  "dependencies": ["frame-furnished", "coil-candidate-1", "material-ribbon-v1"],
  "configuration": {"width": 0.16, "thickness": 0.04, "unit": "trial extent"},
  "retained_material_ids": ["coil-candidate-1"],
  "result": "common-aperture occupied collision",
  "constitutional_index_delta": 0
}
```

This illustrative entry needs real before/after hashes and measured interfering IDs in a recorder. It must not be imported as an acquired Footing. The current workshop may retain analogous session data but has no validated export/import cycle.

## Validation and acceptance boundary

Validate profile/geometry/mechanism versions first, then ordered chain and dependency scopes. Rebuild source geometry under the pinned algorithm; verify transforms and dimensions, material address/identity, fold order, collision result and acquisition prerequisites. Reject unsupported correspondences, missing condition evidence, falsely declared acquisition or a result the machine cannot reproduce. Mathematical asymptotic fit cannot override finite occupied contact. A historical adapter needs explicit compatibility review; changing its version label is forbidden.

Use the existing design's single DB transaction for accepted standing plus DIRT consequence, expected revision and unique command ID. Geometry and constitutional state have distinct acceptance types; atomic persistence does not grant physical authority to a preview. An imported run should be reviewed before mounting isolated Regarding; no live source overwrite.

Phoenix LiveView remains the interaction/evaluation orchestrator. User-configurable webhooks may supply bounded external evidence with version/response provenance. Local Python scripts are not a production evaluator. A webhook result alone cannot bypass the declared physical/constitutional witness contract.

## Current-turn and continuation lifecycle

**ESTABLISHED ARCHITECTURAL REQUIREMENT — [R20](diagonals-pillar.md).** Version 2 separates these four records:

| Record | What it establishes / required inheritance |
|---|---|
| `current_turn_line_furnished` | Current-turn ID, Diagonal B source ID, endpoints [0,6,0]→[6,0,0], center [3,3,0], actual length SIX√2 in the registered frame; inherited XT TO XT FROM HERE identity and its ZERO-TO-ONE measure. This is a furnished line measure, not acquisition of a protected Human turn. |
| `future_continuation_proposed` | Proposed YT TOWARD YT relation, basis in the current-turn measure and original XT TO XT FROM HERE; explicitly unresolved physical join/interface and candidate source data. An empty-material joining-reference overlay is a Regarding event, not even a furnished material proposal. |
| `future_continuation_furnished` | Particular issued material source/identity, measured extent, actual registered joining geometry, issuing office, conditions and dependencies on the prior current-turn line. This record cannot be synthesized from a selector or the presence of B. |
| `future_continuation_lawfully_acquired` | Furnished continuation plus actual Ground/secure acquisition witnesses, prior/resulting FROM and index, original unit/current-turn ancestry and actual taking office. No authority is inherited merely from proposal or projection. |

Retain `turn_scope=geometry_preview` for the current workshop's preview-turn ID; do not import it as an actual protected acquired Discrete Turn. Keep measured current length, prospective joining boundary, frame vertical height and eventual continuation extent in different fields. The preview marker [6,0,0] is a known B endpoint, **not** an appointed physical join point. `physical_join_point=null`, `material_points=[]`, next status `not_furnished` and acquisition false are intentional current witness values.

An attempted future furnishing without actual material joining evidence, or acquisition without furnished continuation, must stop validation. Reordered/missing unit/current-turn dependencies reject. Proposed or furnished continuation cannot automatically resize the constitutional SIX frame or introduce a RE-STEP. The existing DIRT versioned-start/ordered-record and atomic acceptance policy continues to apply; no recorder/importer is implemented here.

## Alongside staging and acquired relationship lifecycle

**ESTABLISHED ARCHITECTURAL REQUIREMENT — R21–R23; CANDIDATE EXPERIMENT — R24.** Version 3 preserves these distinct events and dependencies:

| Event | Required record / limits |
|---|---|
| `regarding_pivoted` | Observer bearing, registered aperture/frame and invariant material/geometry hashes. No automatic wedging appointment or material mutation. |
| `wedging_appointed` | Human appointment ID, bearing, source Regarding, intended office and inherited frame. An appointment alone furnishes no new material. |
| `material_staged_alongside` | New source/material ID, inherited already-standing IDs, shared opening/Projectioning ID, exact UP FROM HERE OVER ACROSS / THROUGH-BY / STAGED ALONGSIDE relations, independent acquisition status. Never infer FROM DOWN UNDER. |
| `material_furnished` | Actual furnishing evidence and issued material/office, material registration, inherited standing and intended target. Workshop `candidate_material_furnished` is a preview scope, not a completed constitutional furnishing/acquisition. |
| `landinging_lawfully_acquired` | Human frame already lawfully acquired, material furnished, actual COB Landinging receipt/completion/securing witnesses and resulting local standing. It cannot authorize a new unacquired frame. |
| `material_from_down_under_established` | The particular material, acquired Landinging event and actual prior/resulting relation. Projection or display relabeling cannot synthesize this event. |
| `cob_work_permitted` / `segmentation_inspected` | Actual permitted work references the same acquired frame and required local acquisition; Human inspection/preview remains distinct. No extra RE-STEP for a scan, local movement or deformation. |
| `axle_registration_proposed` | Source materials/angles, appointment and furnishing events, actual vs proposed acquisition provenance and derived control/deflection values. A control polygon is not an occupied-curvature proof. |

Every stage retains source, office, frame/unit, material identity/address, algorithm version, current-turn Diagonal B and XT TO XT FROM HERE ancestry. A staging fixture's stipulated inherited standing is scoped `staging_geometry_preview` and must never be imported as actual acquired standing. Future physical records need verified material passage through the registered opening, not just a shared center or reference ray.

Reconstruction must reproduce the distinction between camera, Human appointment, furnishing and acquisition. Reject missing prior Human frame acquisition, unsupported physical aperture correspondence, out-of-frame occupied material, interference, a FROM DOWN UNDER consequence without the Landinging event, or work authorized by a preview fixture. Keep the existing atomic accepted-standing/DIRT boundary; no complete recorder/importer is added by the workshop witness.

## HERE wedging and SIX provenance

Version 4 must preserve the local XT TO XT source ID/ONE measure separately from continuous HERE SIX; Seat-point and Table bearing; inherited return-line ID, actual original frame and previous acquisition receipt (currently not attested); current return-line appointment (currently missing, not inferred from B); each wedge hypothesis; source Snail version/arc addresses; exact scale, translation and sixth-purchase correspondence status; source/target extent checks and blocked fit. Left/right Regarding cannot create another unit or change acquisition history. A candidate sample association or line intersection must never import as a proved Segmentationing SIX material seam. Unknown physical transforms remain hard blockers, not coordinate guesses.

Current [v6 assembled CUBICAL / Crossing requirements R31–R36](cubical-construction-2026-11-15.md) preserve this source witness. Initial straight-UP approach, whole-frame versus local ceilings, distinct LEFT/RIGHT material and THREE/FOUR comparison must be read under that refinement. No historical candidate or failed fit becomes actual acquisition.
