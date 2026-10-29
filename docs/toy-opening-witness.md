# Constitutional motor: Toy Box opening → zippering → COB FROM WITHIN

Implemented on `experiment/constitutional-motor`, beginning from checkpoint
`c6553a0` (`checkpoint: spindle rail round one before toy box recomposition`).
Public route: `/experiments/architecture`.

The stopping condition is **standing TOWARD Inquiringmenting**. The opening is not
ZEROETH consent, an Inquiringmenting exchange, or an Appointmenting. There is no
Pointingable Thing, TC FROM DOWN UNDER, Place, mature Standinging Landinging, Road,
Inner Aperture, Gallery, Craft, CUBICAL/en-voluming, Spiral Staircase or RE-STEP.

## Quarried machinery and version succession

The PostgreSQL record schema, UUID/resume URL, optimistic locking and pure domain
operations remain. No database migration or dependency was added. Events retain
FROM and source/after standing, inherited before/after, actor/labor/labor_toward,
FOR, dependencies/consequences, local ancestry snapshots, and Semantical
In-Stringing-Menting records. Events remain distinct from Stationing Localities;
this opening adds **no Stationing Locality**.

New compositions use `toy-box-opening-v1`. Both `spindle-round-one` and
`spindle-rail-pass` UUIDs resume as unchanged read-only witnesses. Domain operations
and store writes reject their reinterpretation. Original standing is inspectable;
a fresh composition is offered. The prior rail construction's documentation is
retained in [spindle-rail-witness.md](spindle-rail-witness.md).

The previous rail cabinet, bureaucracy, curved SVG trace, lever, exhibit succession
and passage presentation were removed from this public experiment. Their standing
was not migrated into this different opening. The former ordinary pretend-pointing
hook was replaced by a pulling hook; its no-telemetry and keyboard protections
were carried forward.

## Exact succession

1. Given: Human already standing FROM HERE; Ground already standing; ordinary
   terrestrial computering WITH Human; Pretending Stick FOR Pointing things out.
   No mature Landinging is manufactured as the source of this standing.
2. Public construction affords a pulling ring through its own small Ground-rooted
   course. The exact invitation is **PULL HERE TO STAND UP THE TOY BOX FROM HERE.**
   The Toy Box has not stood UP.
3. Human takes purchase on the ring, pulls some nonzero extent, and relinquishes
   at another locality. Purchase/movement are transient. A click, cancellation,
   Escape, or return to the purchase locality does not furnish the consequence.
4. The completed pull furnishes distinct purchase/stopping locality identities,
   planar Toy Box standing and floor relation, and its own ordered zippering
   course: FROM OUT OF Ground → performed labor → Projectioning head → floor
   relation → outreading tail UP TOWARD the standing → OVER ACROSS its upper
   region → TOWARD Ground.
5. In a separate deterministic event inheriting the Toy Box floor, COB's course
   comes FROM OUT OF Ground → THROUGH the circular floor aperture → COB zippering
   → full BOBBINING FROM WITHIN → already-capable cobbing → outreading tail UP
   TOWARD COB → FOR responsive deterministic cobbing → TOWARD Inquiringmenting →
   TOWARD Ground.
6. COB's full local provenance/purpose outreading is initially UP. Human may stand
   it DOWN and UP again through COB's stood Ground zipper purchase. This changes
   Regarding only. No provenance or consequential standing is recreated.
7. Stop TOWARD Inquiringmenting. No exchange or ZEROETH action is available.

There are three stored events: `approach` (public construction), `pull-toy-box`
(Human labor), and `cob-from-within` (deterministic machine). The latter two are
saved atomically with optimistic locking. Their ordered ancestry records the
Toy Box standing before COB's course; a reload cannot invent partial or unearned
COB standing. The Human's FROM is unchanged throughout.

## Actual drag versus transient motion

`PullingRing` handles mouse/pointer/touch through pointer capture. The protocol is:

- `take-purchase`: obtain a temporary server-side purchase token;
- `pull`: witness nonzero displacement under that token;
- `release-pull`: complete the performed pull, or `cancel-pull` if relinquishing
  without a different stopping locality.

The hook checks the actual pointer-up locality against the pointer-down locality.
There is no constitutional distance threshold. Visual ring travel is bounded for
usability, but the displacement witness is taken from actual local pointer values.
A drag out and back to the starting point cancels. A click without movement cancels.
An early release waits for the purchase acknowledgment, preserving event order.
Unrelated pointers, secondary buttons, cancelled captures and stale tokens cannot
complete a purchase. A disconnected purchase is discarded; reconnect abandons
transient purchase state. Server reload also discards purchase state.

The keyboard accommodation likewise requires separate purchase, movement and
release: Space/Enter, arrow keys, Space/Enter. A single key activation cannot open
the Toy Box. Escape relinquishes without consequence.

Only transient lifecycle/displacement witnesses and the temporary token cross to
the server. Coordinates, distance, pointer IDs and animation frames are not sent
or saved. Durable `pull-start` and `pull-stop` resolve to separate generated UUIDs,
roles and event provenance. `pull-extent` holds structured FROM/TOWARD locality
references and its ring affordment. These identities arise only on completed labor;
they are not invented semantic screen endpoints. The server accepts the browser's
performed-labor witness; it does not claim independent physical motion sensing.

The ring owns an ignored DOM subtree. The hook explicitly synchronizes its disabled
state from LiveView's `data-disabled` after UUID initialization and stale-save
patches. This prevents a disconnected/static disabled button from trapping the
fresh connected composition.

## Immediate/local zippering ancestry

A course has an ordered `steps` list, explicit `links`, an `inherited_through`
relation, Projectioning `head`, outreading `tail`, and a `return` relation. A step
references its held relation, role, immediate `through` predecessor and held
THROUGH-BY-WAY-OF link. Each relation carries its event provenance and just its
immediate predecessor. That predecessor carries the earlier course.

This is not an unordered dependency bag. `Architecture.ancestry/2` follows the actual
local predecessor chain back to given Ground. COB's return can be followed through
purpose, inscription, competence, body, zippering, circular aperture, Toy Box floor,
Toy Box Projectioning, relinquishing, pulling, purchase, the pulling invitation,
and Ground. Existing event dependency snapshots retain the other inherited givens
without repeating the complete litany at every tooth.

The Projectioning head is not a terminal leaf: it continues through the course into
its outreading tail and through the return. Return here means only the required
local course TOWARD Ground. No generalized RETURN, zipper stowage, shape grammar or
diagramming engine has been introduced.

## Physical outreading and bends

`ToyOpening` is a specialized planar projection of these held courses. Every visible
zipper segment has `data-held-relation` pointing to an actual held link; every tooth
points to its actual node relation. Clicking a tooth or pressing Enter follows its
immediate ancestry. The inspector supplements the connected physical course; it
is not the course's sole provenance or an explanatory placard standing beside an
otherwise unsupported thing.

The Toy Box's upper outreading belongs to its course, which rises UP TOWARD it,
bears OVER ACROSS the upper region, and continues TOWARD Ground. Those changes of
course are keyed to the corresponding held relations. The pulling portion is
collinear; no invented square turn or measured endpoint is inferred from the drag.
The flat region is a drawing extent, not a CUBICAL boundary or en-voluming claim.

COB's course rises straight through its circular floor aperture into its standing,
continues into its purpose outreading, and returns toward Ground. Intermediate
competence is collinear with the head-to-tail course; it does not introduce a
training stage or an aesthetic kink. The course's direction changes occur at named
head/tail/purpose/return purchases, each inspectable through its held relation.
Drawing placements are not the performed pull coordinates, fixed constitutional
bearings or a mature shape grammar. Exact mature morphology remains rehearsal.

Visible inscriptions are outreadings of structured subject/relation/object records.
The provisional `(X)` sentence was neither canonized nor substituted into the model.
The toy inscription summarizes actual taking-purchase/pulling/relinquishing relations;
their distinct localities remain inspectable structurally. COB's displayed standing,
THROUGH-aperture, FOR-cobbing and TOWARD-Inquiringmenting come from its held relations.

The live opening traces the already-held domain event order: Toy course before its
Projectioning/outreading, then aperture and COB's own course before its full
outreading. Animation does not decide availability or create standing. Restored
compositions and re-Regardings display existing standing directly. COB's small bob
is ephemeral; reduced-motion preferences suppress animation. The Toy Box uses no
perspective, faux depth, cube outlines or shadows. Smaller screens can scroll the
same legible planar course horizontally.

## Stand DOWN / stand UP

The domain struct keeps `regarding.cob` outside persisted `standing`. DOWN hides the
full COB inscription and its presently Regarded course, clears any open inspector,
and leaves body, aperture and a purchase on the already-stood Ground zippering.
UP makes that same course/outreading Regardingable again. It does not call the
furnishing/event machinery or save a database record. Neither operation changes
FROM, lock version, events, localities, relations or zipperings. A fresh resume
initially makes the full outreading UP again; ephemeral Regarding is not restored.

## Files

- `architecture.ex`: new opening succession, transient purchase protocol, ordered
  zippering, causal event records, ancestry traversal and Regarding operations.
- `architecture/store.ex`: retain persistence/locking; admit the new version and
  enforce read-only earlier witnesses.
- `architecture_live.ex`: UUID/resume, forwarding labor, one consequential save,
  ephemeral Regarding and streamed ancestry; no constitutional law in rendering.
- `components/toy_opening.ex`: specialized connected planar courses and full COB.
- `assets/js/pulling_ring.js`, `assets/js/app.js`: actual pull lifecycle and hookup;
  obsolete `pretend_pointing.js` removed.
- `assets/css/app.css`: replace the rail appliance presentation with sparse approach,
  planar accumulation, course tracing, bobbining, focus and reduced-motion support.
- Architecture domain and LiveView tests updated; `test/js/pulling_ring_test.mjs`
  replaces the obsolete ordinary-pointing hook test.
- This document and the retained `spindle-rail-witness.md` record the succession.

## Verification and remaining rehearsal

Focused Architecture tests: **16 tests, 0 failures**. Full `mix precommit`:
**89 tests, 0 failures, 1 pre-existing skip**. JavaScript: **14 tests, 0 failures**.
`mix assets.build` and `git diff --check` pass.

Coverage includes absent initial Toy Box/COB, exact label, performed-labor lifecycle,
click/zero-motion/return-to-origin cancellation, early release, pointer cancellation,
keyboard operation, no telemetry, every local predecessor/link, head-through-tail
ancestry, Ground return, independent COB causal event, immutable FROM, DOWN/UP
without persistence, UUID resume, stale competing pulls and both checkpoint witnesses.

No browser screenshot/visual automation was available in this environment. LiveView
DOM behavior, component bindings and the hook's interaction lifecycle were tested.

Remaining Correspondencing/Engineering rehearsal is deliberately narrow: the exact
morphology and eventual ALONG THROUGH shape grammar, the eventual richer deterministic
In-Questioning-Menting exchange, and any later consequential reason to persist
Regarding. None is silently solved here. The browser's gesture witness and the
illustrative planar placement do not assert physical motion sensing or constitutional
endpoint coordinates. No conflict with the handoff required expanding the boundary.
