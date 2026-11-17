# One letter, two transformations, one source identity

**17 November 2026 · supplement `same-letter-transformations-2026-11-17.v14`**  
Workshop `/experiments/architecture` · [clarification record](same-letter-clarification-2026-11-17.txt) · [before/after witness](diagrams/same-letter-transformations-v14-witness.json) · [verification](same-letter-transformations-v14-verification.json)

The workshop now exposes independent Door angle, Regarding bearing and existing-U curvature-frame controls for **the same `doorway:letter-R`**, carrying original inscription source **`specimen:R:1`**. The R's original leading-toe end-cap is explicitly addressed and follows the source pose through the opening. No source mesh, allocation or ROOM geometry was replaced.

**The second control is a prospective rigid-frame witness, not accomplished curvature standing through lawful PUFFING.** It samples the existing candidate U's frame and co-registers that frame at R's current origin. It does not invent a glyph-bending law or an occupied passage. The missing unit-letter/wedging PUFFING acceptance is exposed as a failing gate. This distinction is part of the test, rather than a visual substitute for lawful operation.

## Authority and scope

| Rule | Canonical requirement / implemented boundary |
|---|---|
| R77 | One source-addressed letter, ONE-CUBICAL allocation, independent observer/door and material-frame transformations; no cloning, enlargement or silent deformation. |
| R78 | Original R leading toe supplies an inspectable issuing locality TOWARD the back-wall YT reference; subsequent PINNING/PITTONING acceptance remains separate. |
| R79 | Invariant SIX ROOM; source-coordinate and pose evidence, actual curvature/mount provenance and PUFFING acceptance must not be inferred from a successful Regarding. |

All 79 existing material source identities and profiles are retained. The previous v13 `RoomFromHere` source definition is archived byte-for-byte at [source archive](source-archive/room_from_here-v13.ex.txt). No Table, axle, computer, U, wall, body-bearing, letter-source or ROOM constructor is changed. Only the existing R and Door's **inspection poses** may differ while this mode is active. The small U inset and toe ray are labeled reference Outreadings, not new material or a second letter.

## T1 — Regarding and Door swing

Use **Inspect the same R and leading toe**, then adjust:

- **Door opening:** 0–90° about the existing Stage Door hinge. Only the existing leaf changes pose; R stays at its current staging/offload origin.
- **T1 bearing:** 0–90° around R, with a fixed orthographic inspection lens of 240 pixels per trial extent. This changes the observer's bearing, not material scale or pose.

At 90° the R inscription's XY face is edge-on: its projected width comes from the actual `.012` finite thickness. No billboard, second R, substituted image or automatic ascent is used. The one-CUBICAL carrier/allocation remains volumetric; it is not confused with the thin inscription face. Before/after tests compare actual glyph projections and require edge-on width below 3% of the Flat width while all R world vertices remain identical.

Door and observer controls are deliberately independent. The source root's identity and hash remain constant, as do the source glyph, toe and unit allocation. Door motion alone neither stitches material nor acquires standing.

## T2 — curvature standing TOWARD Regarding: preview and gate

The U source is the already constructed `doorway:inner-u`, not a new curve. Its source course contains both legs and the 33-point sampled upper arc. The inspector addresses arc samples 0–32 and records their corresponding full-course indices 1–33.

For each selected sample it exposes the original point, local tangent, fixed plane normal, analytic `.8` radius reference, and a measured discrete curvature. The latter is the angle between neighboring sampled tangents divided by their two-chord span, in **radians per trial extent**; it is not silently substituted for the analytic `1/.8` reference, particularly near endpoints.

The same R receives a **rigid orientation** equal to the change between the initial and selected source tangents. Its origin is held fixed. The explicit U-to-letter co-registration translation is recorded and marked **not a proved material mount**. The matrix's vectors are **basis columns**:

`world = origin + x*linear[0] + y*linear[1] + z*linear[2]`.

This frame transport changes the material pose while the selected Regarding bearing remains fixed. Every source vertex can be recovered by the inverse rigid transform. Source distances and the oriented ONE × ONE × ONE allocation remain invariant. A rotated world-axis bounding box may span more than ONE along a world axis; that is reported separately and is not an enlarged letter. All allocation corners remain within the unchanged SIX ROOM.

The co-registered preview can overlap existing candidate material. Exact normalized occupied-allocation intersection IDs are reported in the ledger. The existing unit-passage proof is not claimed to cover these new orientations. The preview does **not** mean that R has traversed the U, that its glyph has been bent, or that the current material mount already furnishes lawful curvature standing.

**Test lawful PUFFING gate** returns `unit_letter_puffing_acceptance_unbound`, with no revision advance, acquired turn or standing-store write. The machine already has an older `Architecture.operate/2` first-PUFFING operation, whose dependencies include `human-standing`, `toy-box-standing`, `cob-square-standing` and `puffer-available`. That operation does not bind the current unit-letter source, sampled U mount and occupied passage to its acceptance. Calling it as though it supplied this new material relationship would be false.

The remaining prerequisites are precisely:

1. A registered material mounting/transport from the existing wedging to this source letter and unit allocation.
2. Its validated occupied curvature passage, rather than a frame co-registration that may overlap stock.
3. Source-bound PITTONING/PUFFING conditions and acceptance producing the claimed curvature standing.

The clarification does not authorize changing ROOM to make these conditions appear satisfied. No such change is made. The active inspector is explicitly prospective until the binding exists.

## Leading toe and issuing locality

The toe is **`specimen:R:1/leading-toe/end-cap`**, source face **25**: the second face of the original final diagonal stroke. Its definition comes from `CoBuilding.glyph/2`, stroke `[.17,.38] → [.48,0]`, placed by the original R source function. The actual finite cap centroid is:

**`[3.26,2.05,-1.04]` in the original inscription source frame.**

The unit carrier already embeds that inscription by rigid translation to its front surface. The witness records this embedding translation, the toe's unit-local point, the original cap vertices and normal, and the posed world cap/point/normal. It is not guessed from the rightmost projected pixel or reassigned when the R becomes edge-on.

The issuing record preserves the ordered relation:

**FROM the original R toe → THROUGH the Stage Door reference → TOWARD back-wall YT `[7.5,6,.5]`.**

It records the direction, actual Stage-plane intersection and whether that point lies inside the registered opening. It separately tests the finite Door leaf on that ray: the initial closed leaf blocks it; the open leaf clears it in the initial R pose. The other material along the whole reference is not thereby certified as a lawful passage. Neither this ray nor an identifiable toe is accepted PINNING/PITTONING.

The full opposite-corner body diagonal retains its own source identity and endpoints. The toe-issued reference is not forced collinear with it. A pointer and dashed reference ray are available in the main aperture, always referring back to the original finite cap, including edge-on inspection.

## Source-to-field / control ledger

| Control / record | Changes | Preserves / acceptance |
|---|---|---|
| `letter-inspect` | Enables inspection of the existing unit R, even when its workflow profile is latent | Existing source ID/profile and current workflow state; no letter creation or acquired standing. |
| `rtb-letter_door` / `Door` | Existing leaf angle and pose | R pose, source and curvature. |
| `rtb-letter_bearing` / `Regarding` | Eye/bearing; lens is explicitly recorded | R and Door material poses, curvature and source hashes. |
| `rtb-letter_curvature` / `curvature`, `material_pose` | Selects an existing U sample and rigidly co-registers R's frame | Unit-local vertices and allocation, current origin and observer bearing; material mount remains prospective. |
| `toe` | Original cap address, embedding and current posed coordinates | Original inscription provenance through both transformations. |
| `issuing` | Toe-to-YT reference, Stage-plane and finite-leaf incidence | Exact ordered prepositioning; no PINNING/PITTONING acceptance. |
| `letter-puffing-gate` / `gate` | Tests the missing unit-letter binding | Rejects; no acquired standing or implicit call to older unrelated PUFFING. |
| `letter-inspection-close` | Restores the workflow's actual candidate pose and Regarding | Leaves its phase/progress, source definitions and standing store unchanged. Other ordinary workshop controls also resume workflow inspection. |

When inspection is closed, its parameters remain available as **retained preview parameters**, not as an assertion of the restored workflow pose. The source ledger and `active` flag distinguish those scopes.

## Witness and validation

The [machine-readable witness](diagrams/same-letter-transformations-v14-witness.json) contains one source mesh, nine same-source snapshots, fixed ROOM bounds, matrix conventions, local curvature bases, original/posed toe faces, observer bearings, leaf incidence, prospective intersections and the failing PUFFING gate. Its source dependencies and preserved material hashes identify the definitions needed to interpret each snapshot.

Tests check material-pose invariance under T1, finite edge-on projection, independent Door motion, inverse recovery of **every** R source vertex under T2, all 79 unchanged source profiles, invariant allocation, actual original toe cap, Door blocking/clearance, stale-request rejection and unchanged standing. Browser inspection exercises Flat, intermediate/open Door, edge-on R, the independent frame preview, toe marker, gate rejection, workflow restoration and mobile layout.

Inspect: [Flat R](../../visual-witnesses/same-letter-transformations-v14/01-same-R-flat.png), [intermediate Door](../../visual-witnesses/same-letter-transformations-v14/02-Door-intermediate-R-stationary.png), [edge-on](../../visual-witnesses/same-letter-transformations-v14/03-same-R-edge-on.png), [rigid curvature-frame preview](../../visual-witnesses/same-letter-transformations-v14/04-rigid-curvature-frame-preview.png), [existing U source](../../visual-witnesses/same-letter-transformations-v14/05-existing-U-source.png).

Final validation: **`mix precommit` — 365 tests, zero failures, one skipped.** Desktop/mobile browser inspection passed with one existing R instance, constant source hash, original toe marker, separate controls, PUFFING rejection, unchanged standing digest and no page errors or horizontal overflow. Artifact validation recovered every posed vertex and toe from the declared basis-column transform, checked the original closed/open leaf incidence, and matched all 79 material source hashes to v13. The **1,119-file** pre-round baseline has eight changed existing integration/documentation paths; original geometry definitions and numerical witnesses remain byte-preserved. Exact paths and hashes are in [verification](same-letter-transformations-v14-verification.json).
