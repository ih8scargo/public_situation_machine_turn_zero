# Instrumentation Lab One

Route: `/experiments/instrumentation`. The motor bench remains at
`/experiments/motor`; public opening routes and templates are unchanged.
Run `mix ecto.migrate` and `mix assets.build` before serving the new lab.

The lab creates an independent record on arrival. Save the resulting `?id=…`
URL to resume its completed seating. The initial fixture seats A, with B and C
already standing. This record neither reads nor writes motor records.

## Acceptance drive

1. Stand the Rail tray DOWN. A remains seated.
2. Catch B's loop (or use Lift B). Turn AROUND ABOUT to inspect its second
   bearing, then Return to Rail. A remains seated.
3. Lift C, turn to `toward-place`, Select bearing, Align to meridian.
4. Optionally illuminate the A → C relation and take reciprocal Regard.
5. Stand OVER. A still remains seated. Push DOWN commits C's seating.
6. The incoming bulb descends; the outgoing bulb rises vertically through the
   receiving projection toward its own overhead segmentation. There is no
   sideways return path. Reduced-motion users get the resulting seating directly.
7. Restore the tray, reopen it, and inspect/re-seat A by the same operations.
8. Reload: completed seating survives; tray, inspection, turning, selection,
   alignment, illumination and reciprocal bearing reset.

## Boundary

`Instrumentation.standing` is the only saved payload: Stationing identities,
Rail membership, inner bearings, fixture provenance and the current seating
relation. The downward stroke changes only `seated`. Optimistic locking rejects
stale writes. No PUFF or RE-STEP operation is exposed or accepted.

The flat and curved Rail resolve the same domain rail and identities. Rail order
imposes no dependency. Only the explicit A → C fixture provenance may illuminate;
B remains independently inspectable. Reciprocal Regard reverses projection
positions, never source/target or ancestry.

Projection coordinates, including the current seated Stationing's central
bearing, do not establish identity. Rail centering is ephemeral: when another
bulb is lifted, the presently seated Stationing's overhead segmentation resolves
on the central meridian so its eventual return remains vertical. This spare
projection should be judged in use, rather than treated as final Rail geometry.

## Awkward / yellow

- Alignment is an explicit discrete control; turning alternates two inner
  bearings. This tests the operations without claiming a mature hand-driven dial.
- The two reciprocal bearings mirror the Rail; they are not a general camera.
- Bulb-loop activation works with pointer or keyboard Enter; ordinary buttons
  furnish the same operations. Dragging and continuous rotation remain unbuilt.
- Temporary inspection can occupy the aperture while the previous seating holds.
  There is no second persisted staging relation.
- AT a Stationing FOR Regarding versus FROM WITHIN its inner Pocketing remains
  deliberately unresolved. The fixture's FROM A is an isolated guard value,
  not a connection to a motor extent with the same label.
- Initial SEAT from an empty receiver is not exposed in this first A-seated drive.
- Browser animation feel and spatial coherence still need Richard/Bill's bodily
  drive. Automated tests cover state and rendered affordances, not perceived depth.

## Checks

Domain tests cover each pre-stroke operation preserving Standing, unavailable
operations, turn invalidation, restore/reset, retained Stationings and provenance.
LiveView tests drive A → C → A, verify identical Rail identities, persisted
snapshots, reload, stale writes and invalid records. Run `mix precommit` for the
full suite including the existing motor tests.
