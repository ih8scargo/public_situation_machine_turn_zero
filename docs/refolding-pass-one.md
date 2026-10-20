# RE-FOLD / consequential Standing — Pass One refinement

Branch: experiment/consequential-standing-refold
Pass One baseline: 2828881128dc97526f1b0532d3da031231a47128
Original starting checkpoint: 22b0321eab8aae4bc6a571dd659de26178e206bb

Open /experiments/refolding. The generated URL carries an opaque BY-WAY-OF
key; reopening that URL reconstructs the consequential record.

## Lawful relations and guards

All controls use Refolding.Proof.allowed?/3. The domain checks those same
guards on gestures, including gestures sent directly past disabled controls.

- STAND IN REGARD selects what is Regardable FROM THERE. It neither approaches
  nor seats the Landinging and grants no furnishing authority.
- APPROACH requires Regard toward that same Landinging, distinct from FROM.
  It establishes THIS NEXT APPROACHINGING LANDINGING, without bodily passage.
- Traversaling Segmentationing requires that same approached Landinging.
  It changes only the Segmentationing index, never FROM.
- SEATING requires Regard and Approach. It selects/seats that approaching
  Landinging TOWARD the present FROM HERE. It moves neither Human nor material.
- STEP requires that same approached and seated Landinging. It establishes the
  bodily relation in which furnishing becomes available; it does not ZIPPER.
- FURNISHINGMENTING requires that stepped relation. It works the tiny material
  fixture in the ephemeral apparatus. It changes neither FROM nor persisted material.
- ZIPPERING requires all those relations plus worked furnishing for that same
  Landinging. It atomically establishes the new FROM, consequential material
  relation and consequence. HUCKLEBERRY stands FROM immediately.

Changing Regard to a different locality relinquishes Approach, Seating, STEP,
worked furnishing and Segmentationing. Repeating Regard at the same locality is
idempotent. Targets cannot borrow each other's labor. A stale apparatus cannot
reuse authority from a superseded consequential basis.

The former independent furnishing shortcut is gone. RE-ZIPPERING has no control,
domain operation or consequence variant. Negative tests verify rejection of
that removed verb. Primitive Seating and STEP do not claim later RE- operations.

## Standing, apparatus and material

Refolding.Standing contains FROM, material keyed by Standing, consequence, and
BY-WAY-OF. ENZO is the stipulated initial FROM. Only ZIPPERING consequentializes
subsequent Standing.

Refolding.Apparatus contains its FROM/basis, Regarding, approached Landinging,
seated relation, STEP relation, worked furnishing, and Segmentationing. Those
relations are never persisted. The basis anchors bodily authority to the
consequential Standing from which this apparatus was furnished.

THIS ONE LEASHING is the sole tiny material fixture, furnished as catalogue data
at HUCKLEBERRY so it can be Regarded FROM THERE before furnishing authority
exists. After lawful labor, furnishing works that relation in Apparatus.
ZIPPERING alone places it in Standing.material at HUCKLEBERRY.
Returning can therefore recover actual consequential material rather than
merely render the catalogue fixture again; tests inspect the stored record too.
No String/Leashing ontology, semantic editing or neck functionality is assumed.

Future direction only: THIS ONE LEASHING may later stand TOWARD HUCKLEBERRY'S
NECK FROM HERE, with IN-STRINGING-MENTINGS ALONG THROUGH it. Whether it is,
carries, or later becomes String is deliberately undecided.

## Continuity Line

The line is a read-only domain projection, streamed into the LiveView.
Its consequential portion derives from Standing.consequence: initial FROM and
linked ZIPPERING relations. A new consequence retains its prior relation in the
existing consequence field; there is no second continuity_history. Only lawful
ZIPPERING extends this lineage.

The disposable portion derives from the current Apparatus: furnished FROM,
Regarding, Approach, Seating, STEP, and worked furnishing. Invalid gestures add
nothing; repeated Regard produces no historical duplicates. Material is outread
separately, not as another Landinging or a consequential step.

RE-FOLD removes ephemeral relations from the line without erasing consequential
continuity. Return outreads fresh apparatus furnished FROM HUCKLEBERRY
BY-WAY-OF Standing, alongside the unchanged ENZO → ZIPPERING → HUCKLEBERRY
continuity. Re-furnishing does not re-perform the consequential passage.

## RE-FOLD and return

RE-FOLD takes no persistence action. It relinquishes the apparatus while the
already consequential FROM and material continue to stand, including while
folded. Folding before ZIPPERING discards worked furnishing without committing
it. Return reads Standing and furnishes fresh apparatus Regarding its material,
without restoring Approach, Seating, STEP, furnishing or Segmentationing posture.

One component renders either Standing from differentiated data:
RE-FURNISHINGMENTINGABLE CATERPILLAR TUNNELING ACCORDIONATIONING SEGMENTATIONING,
fashioned of 100% JANUSITE. No named scene component or per-Standing unfolding
flags were introduced.

THE LINE DOES NOT HOLD UP THE VOLUME.
THE CATERPILLAR TUNNELING ACCORDIONATIONING SEGMENTATIONING HOLDS UP THE VOLUME.
This pass implements no full volume or later bodily/visual architecture.

## Persistence

Refolding.Store remains a replaceable contract for atomic Standing transactions.
The supervised MemoryStore stores only Standing records. Ephemeral gestures read
the latest record; ZIPPERING checks authority against that record within the
transaction, protecting against stale apparatuses.

Memory survives LiveView termination/remount, but application/store restart
loses records. Keys/records have no expiry in this bounded spike. This is not a
durable identity or authenticated account system. ParkingingStandRegistry is
uncoupled; no migration or additional dependency is introduced.

## Demonstration

1. Start FROM ENZO. STAND IN REGARD toward HUCKLEBERRY; inspect the Leashing
   FROM THERE. Furnishing and ZIPPERING remain disabled.
2. APPROACH. Traversaling becomes available without changing FROM.
3. SEATING. Inspect the seated TOWARD relation; the material has not moved here.
4. STEP TOWARD. Furnishing becomes available; FROM is still ENZO.
5. FURNISH THIS ONE LEASHING. Inspect worked furnishing and the Continuity Line.
6. ZIPPERING. HUCKLEBERRY and THIS ONE LEASHING immediately stand consequentially.
7. Stand in Regard toward ENZO, APPROACH and Traversal to alter ephemeral posture.
8. RE-FOLD. HUCKLEBERRY, the Leashing and consequential continuity remain standing.
9. RETURN TOWARD STANDING. Inspect fresh apparatus furnished FROM HUCKLEBERRY
   and its Regardable Leashing, with no resurrection of the prior approach posture.
10. Repeat folding/return or reload the generated URL. No passage is re-performed.

## Files and validation

Changed domain files: refolding/standing.ex, apparatus.ex, proof.ex.
Changed interface: live/refolding_live.ex.
Changed tests: refolding/standing_test.exs and live/refolding_live_test.exs.
Added focused projection test: refolding/continuity_test.exs.
Updated this inspection note.

Guard tests cover incomplete prefixes, wrong targets, pivots, stale authority,
folded gestures, pre-ZIPPERING discard and immediate post-ZIPPERING persistence.
LiveView tests inspect disabled controls, direct invalid gestures, differentiated
data rendering, bodily outreadings, continuity, repeated fold/return and remount.

The existing TupleShipFieldLive, route and ParkingingStandRegistry remain
untouched. The shared layout still requires only an active_locality value.
No existing story-state machinery was imported into the proof.

Validation completed: mix precommit passed with 59 tests, zero failures and one
existing skipped test. mix assets.build passed. git diff --check passed.
