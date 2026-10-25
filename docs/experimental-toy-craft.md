# Toy craft / Co-Bobbing / roundabout / FROM-WITHIN Tunneling

Current public review: [One room / navigable sheets](experimental-one-room.md).
The earlier broad craft drive remains on `/experiments/architecture/engineering`.

Route: `/experiments/architecture` (the existing saved URLs still work).
This pass replaces the visible architectural grammar, preserving the domain,
material ledger, Toy Box identities and first STEP contracts. Motor and
Instrumentation Lab One remain independent at their existing routes.

## First bodily drive

1. Arrive at ZEROETH. THIS ONE CO-BOBBING THING is already present, before
   drawing the Pointing-able Thing. The soft football-like extent has no face,
   hands or assistant persona. Its four articulation points remain available.
2. Drag the rim of THIS ONE FREE WHEELING FREE TURNING THING FOR REGARDING
   THROUGHING ALONG THROUGH. The rotor really turns. Material comes around an
   orderly curved course; there are no four public view buttons. The native
   range beneath it and arrow keys on the wheel offer equivalent operation.
   SHIFT+arrow on the wheel makes a larger turn. The wheel never advances NAV.
3. NAV-STEP TOWARD a particular inscription. It swings head-on within the scene;
   it does not open a modal. A second TOWARD approaches further. Directional NAV
   pans its Readingmenting; Backing NAV returns to broad curved Regard.
4. Bring Composementing locality TOWARD. Surrounding inscriptions recede and
   become inert: their text and controls cannot occupy the craft workspace.
   The return affordance remains beneath the aperture.
5. Draw the Pointing-able Thing from the central opening (activate the opening
   or the equivalent button). Bobbing was attending before this action.
6. Point toward the calibration mark and explicitly exercise the Pointing-able
   relation. This is the small calibration rehearsal, not the mature ceremony.
7. Open the physical Toy Box. One offered piece appears: the little laptop,
   THIS ONE TERRESTRIAL COMPUTER, a **projected furnishing**. Actual TC remains
   alongside WITH the Human. Point at the laptop, then Grasp.
8. Drag the held extent to carry it. Drag its dotted surrounding ring to turn it
   AROUND ABOUT; the four-point articulation follows while Bobbing's basal
   extent continues Human-facing. Keyboard arrows on the carry area move it;
   arrows on the turn ring turn it. Lift and Turn buttons offer another path.
9. Bring TOWARD the Little Square Chair. This explicitly takes a receiver
   identity toward the held piece. Align square into square, then Seat DOWN.
   Merely overlapping the Chair does not seat. Merely pointing never drags.
10. The next offered piece is the Square Buckle. Point, Grasp, turn and bring it
    TOWARD the TC/Chair extent. Align, Wrap extent, then Buckle / Appoint.
    Wrapping is a temporary rehearsal; the explicit Buckle request furnishes
    the existing TC Appointmenting relation. This is not a universal JANUSITE
    or Zippering law. The first STEP becomes available.
11. Return toward backed-up Roundabout Regard, then STEP.
12. Regard now stands FROM WITHIN a gently curving tube. The near enclosure
    exceeds the viewport; longitudinal seams, the far receiving arc and the two
    floor Rails furnish the interior course. No external nested ellipses remain.
13. NAV-STEP forward/backward. Bobbing moves through the projection and side
    material changes exposure. Saved consequential FROM remains ONE-APPROACH.
14. Approach an available side inscription; it swings head-on. Back away, turn
    Regard groundward (around 180 degrees on the wheel), and inspect the actual
    inherited relations along the floor. Provenance is its own course: neither
    of the two Rails nor Semantical Stringing.
15. Projectioning-er OFF removes Regard; ON rederives it from saved Standing.
    Reload retains consequences and material, resetting handling and Regard.

The Toy Box's Another piece affordance allows discovery of the Buckle first.
It may be Pretended with, but cannot wrap/appoint an unseated TC. Likewise,
seating a TC without calibration fails without modifying Standing. Release
abandons the held preview without undoing a relation already furnished.

## Architecture

- `Architecture.Craft` owns explicit fixture capabilities and validates the
  requests. Its struct contains **ephemeral** workspace, offered/held identity,
  pointing, receiver preview, pose, alignment and wrap state. None are saved.
- Explicit craft Seat uses the existing `tc-positioned` operation; explicit
  Buckle uses `tc-appointed`. Their dependencies and first STEP remain intact.
  Pointer coordinates cannot furnish either relation.
- The canonical Toy Box is extended with two fixture identities, projected TC
  and Square Buckle, for seventeen total items. Existing identities and edits
  survive. Graspability checks identity, ZEROETH labor locality and the shared
  inventory's Pretendingable/Usingable furnishing, rather than text or DOM.
- Co-Bobbing and Co-Situationing Doll are differentiated entity records.
  Older records acquire the added fixture entities/inventory additively when
  restored. Existing materials, relations and passage ancestry are not rewritten;
  added fixtures are included on the next saved Standing write.
- `Architecture.Projection` resolves material in stable course slots. The number
  of roundabout segmentationings follows the actual fixture material, with no
  canonical six and no association to ZEROETH–SIX. Tunnel side assignment remains
  stable as other material enters/leaves Regard.
- `ArchitectureScene` furnishes the toy apparatus; existing authoring forms are
  engineering instrumentation below the cabinet, not public craft UI. Earlier
  development constitutional controls remain folded in a separate details region.
- JS hooks own their SVG subtrees through `phx-update="ignore"`. Elixir sends
  derived data; hook mutations are projection only. Carrying/turning sends a pose,
  never an implicit Seat, Buckle or STEP. Wheel events send only Regard angle.
- The body and four articulation points are separate geometric parts. Opening,
  grasping and square preview respond deterministically to available relations.
  Nearness can preview a square bodily; only an explicit receiver/alignment and
  domain-accepted request can furnish Standing. Bobbing does not interpret Signs.
- Tunnel inscriptions never become graspable just by being pointed at. Craft
  requests are rejected outside ZEROETH's open labor locality, including forged
  requests from within the Tunnel or while Projectioning-er is OFF.
- Local material retains explicit locality/origin. There is no Road/publication
  mirror or implied publication of local revisions. Wheel turn is not Diorama
  flip; Road mechanics, publishing, Buttoning, mature PITTONING and RE-STEP laws
  remain unimplemented.

## Still provisional / for Richard's hands

- Align is a deliberate discrete stroke; it is never automatic shape sorting.
  There is a genuinely free carry/turn rehearsal before it, but no collision or
  general 3-D engine. The Chair is a receiver rather than a draggable fourth toy.
- The fixed fixture's Bind/Buckle ceremony uses the existing Appointmenting
  consequence. Mature TC craft and JANUSITE relations remain under rehearsal.
- The four points articulate, rotate and return independently of the blob; this
  is a small deterministic vocabulary, not mature grasp mechanics.
- Broad inscriptions are partial/oblique. TOWARD or Flat Regard gives the reading
  surface. Spacing, overlap and perspective need bodily judgment on the target
  display. Responsive CSS and reduced motion are provided.
- The future Diorama flip has not been simulated as another wheel operation.
- No graphical browser was available in this environment. LiveView and hook
  tests exercise outcomes and pointer/keyboard event behavior; they do not certify
  browser animation feel, perceived depth or the feel of the turn ring.

## Verification

`mix precommit` runs the full Phoenix suite. Focused craft domain tests cover
preview invariance, early dependency failures, read-only material, turn
invalidation, full TC/Chair/Buckle consequences, reload, additive fixture
registration, and no automatic publication. LiveView tests drive the full bodily
sequence into the Tunnel and verify durable snapshots between gestures.

Run `node test/js/toy_apparatus_test.mjs` for six dependency-free hook tests:
pointing without movement, actual carry/turn input, overlap remaining pose-only,
keyboard operation, four-point/Bobbing progression, and the rotating wheel.
These run hooks against a small SVG event fixture, not a graphical browser.

Prepare another checkout with `mix ecto.migrate` and `mix assets.build`. This pass
adds no SQL migration or external dependency.
