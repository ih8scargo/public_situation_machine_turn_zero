# COB comes alongside — bounded review, October 30, 2026

The default `/experiments/architecture` now supports a mouse-first handoff to COB,
a four-wheel companion on the retained course, an actual over-the-shoulder camera,
a circular Mouse Treadmill, lateral steering, and a reachable stopping-sheet purchase.
This is an experimental encounter, not completed constitutional machinery.
The [governing print](machine-instructionings/cob-alongside-source.txt) is archived
byte-for-byte. Stop here for Richard and Bill's review; nothing is committed,
merged or pushed.

## Recovery and retained standing

Inspection included the current appliance/cutaway and course, the preceding reports,
and historical `1c41a8e` (dated October 24). Its `assets/js/toy_apparatus.js`
retains the Bobbing body's identity while changing four articulation points among
square, offer and grasp states. That is the recovered visual/interaction reference
for this handoff. `quiet_locality.js` supplies the earlier deterministic-movement
precedent. A separate October 23 checkpoint was not found. No antique screen
coordinates or obsolete apparatus were restored wholesale.

PULL, PUFF and the existing stick-through-aperture appointment remain the domain
operations. There is no groundward stick-feed alternative. The one source stick,
Human FROM, three opening events, retained XT-axle surfaces, paired source geometry,
fixed appliance/cab, resizable Crossing, inward cutaway and JANUSITE issuance
provenance remain in place. Skating, steering, camera changes and holding purchase
regions do not author or evaluate inscriptions and do not create turns.

## Mouse handoff and the advancing notice

The situated notice appears after PUFF:

**STAND THIS ONE STEWARDLY CO-CAPTAIN CO-BOBBINING TOWARD APPOINTMENTING THIS ONE POINTING-ABLE THING.**

Its short instruction offers **Take hold of COB**. Taking hold reveals a labeled
mouse slider: **Hand the stick THROUGH →**. Advancing it stages the existing
aperture-normal feed and visibly moves COB toward the instrument, extends the
receiving arms and contracts the four-point grasp. **Let COB take hold** enables
only at full feed. It completes the existing stage-feed / COB-up-over operation;
rapid repeated completion cannot furnish the appointment again.

The notice then acknowledges **RECEIVED AND RETAINED** and offers the course
appointment once. After that, it introduces the Mouse Treadmill and **TAKE HOLD OF
COB'S REGARDING**. During sheet purchase, it explains inspection and release.
The notice uses a reserved overlay area; it does not replace ordinary paragraphs
with constitutional standing. Keyboard feed alternatives remain available.
No telephone, consoling surface or unsolicited COB speech was introduced.

## Recognizable companion and wheel-to-tack relationship

The same `rounded-cob` body node carries a head, shoulders, face, receiving/grasp
articulation and four named wheels. No camera creates a second COB. Wheel tires
have two side faces, tread bridges and rotating spokes.

For each axle, the renderer samples the shared course at distance ±0.22, bounded
at its ends. Each side's running contact is ±0.22 across the course and 0.30 below
its center along course-local up. The wheel center is 0.10 above that contact;
radius is 0.10. Its axle follows local right and rolling plane follows local tangent
and up. Roll angle is distance / radius. Thus the bank and heading come from the
same samples that furnish the tacks, not from the selected external camera.

The two JANUSITE running strips are represented by paired edges, each half-width
0.20, with cross-ties every 0.50 distance units. Mouse steering displaces COB up to
±0.18 across them; the four contacts stay within the strips. This is bounded lane
steering, not free driving. Newly proposed course v2 uses a 0.65 arch radius;
its lower frame is clipped onto the running deck at local Y −0.30. Existing
appointed course snapshots retain their original geometry and supply history.

There is no collision solver, suspension simulation or differential inner/outer
wheel physics. At route ends axle samples clamp to available material. These are
explicit rehearsal limits, not claims of finished vehicle mechanics.

## Regarding WITH COB

**Take hold of COB's Regarding** selects a perspective frame 1.35 behind and 0.65
UP OVER COB in its current local tangent/up frame. It looks ahead with a modest
0.14 downward component. COB's upper body and shoulders remain in the foreground,
with a provisional coupling ring. The world rolls with the course bank; the
camera advances with COB. Actual near-plane clipping removes behind-eye lines
and faces instead of stretching them into view.

**Release Regarding · observe externally** returns to the independently retained
external bearing and zoom. Release and re-entry change only the selected camera:
COB's position, course distance, velocity, held tool and course snapshot remain
unchanged. External dispatch remains possible. The old THROUGH COB target view
also remains available as a distinct inspection tool. **Reset course position**
is now labeled for its actual effect and explicitly stops/reset the rehearsal;
it does not mean bringing COB into the Human's Regarding.

The four-square Regarding purchases remain in the Diorama. A distinct fixed cab
locality is reserved for the future Regarding wheel. The treadmill controls COB's
traversal and does not operate that future wheel.

## Mouse Treadmill rules

The cab carries one circular purchase surface. Press and hold a region with the
mouse, or hold Space/Enter on its focused button. A visible depressed detent and
120 ms engagement delay distinguish command from response. The readout reports
commanded purchase separately from actual velocity.

| Region | Provisional rule |
| --- | --- |
| REST / release | no accelerating purchase; coast toward rest at 0.28 units/s² |
| GENTLE | 0.45 units/s² in the selected drive direction |
| WORKING | 0.90 units/s² |
| STRONG | 1.50 units/s² |
| SLOW | 1.80 units/s² opposing current velocity, stopping at zero |

Maximum speed is 2.40 units/s. Forward/reverse selects the direction of accelerating
purchase; changing it opposes and then reverses existing motion. The compact
inspection/settings disclosure supplies a 0.5–1.5 acceleration multiplier.
`treadmillSettings` holds the local strengths, dwell and release rule. The five
`#treadmill-*` CSS positions define the modest starting arrangement and can be
edited independently. These are experimental settings, not canonical values.

Simulation uses fixed 1/120-second ticks, accumulating rendered frame time with
a 0.1-second frame cap. Constant acceleration uses trapezoidal displacement;
coasting/braking clamps a zero crossing rather than reversing accidentally.
Route boundaries and held station distances stop playback. Browser background
time is not fast-forwarded. The old Skate/Pause buttons remain secondary aids;
they now supplement the treadmill rather than define its primary grammar.

Mouse-up, pointer cancellation, leaving the engaged region or document, keyboard
focus leaving a region, browser blur, hidden-document state, disconnection and
teardown end active purchase. Release ends **command**, not velocity: coasting
continues deterministically. **STOP NOW** is a separate immediate stop.

Operational velocity, lateral offset, purchase/dwell, camera selection and sheet
attachment are browser-local. Reload returns this rehearsal to its retained
start, while the appointed stick, course and supplied JANUSITE remain persisted.
No repeated appointment is required to use the instruments again.

## Stopping purchase and inspection

The BANK notice is the one bounded stopping sheet. The cab reports whether it is
approaching, behind or within reach (±1.30 course-distance units). **Take stopping
purchase** is enabled only in reach. It shows COB's arm/tether taking hold of the
anchored sheet, opens that sheet's flat reader, and applies deterministic damping:
`v(t+h) = v(t) exp(−4h)` and displacement `v(t)(1−exp(−4h))/4`, resting below
speed 0.035. Accelerating regions are disabled while attached. The body can settle
near the sheet; it does not teleport exactly to its anchor.

The Human can inspect the front or reverse without moving COB. **Release sheet
purchase** detaches it; a new treadmill hold resumes traversal. This is a modest
purchase rehearsal, not the full PITTON/pinning system or a new inscription.

## Seat correction and contract boundary

The future Traversaling Craft Seat is reserved **beneath the aperture, facing
inward**, with source `aperture-available`. Its projection point is
[0, Floor+0.35, 0.35], facing +Z. It is not a completed Seat or a seated precondition.
The course's far endpoint is instead labeled **NEXT APPROACHINGING LANDINGING**.
Both appear in the shared Outreading. The earlier far-seat interpretation is
superseded for this pass; older appointed records are preserved verbatim rather
than silently re-stood.

New proposals use `flick-to-approach-v2`. Persisted v1 snapshots, their earlier
witness notices and issued prefixes remain readable unchanged. New geometry is
derived at the Phoenix-to-JS boundary; the new browser-produced
`course-contract.json` exercises the actual course/stick JSON in the JS tests.
No Python API or Python implementation changed, so no Python contract migration
or new Python-side operation was required.

## Files changed in this pass

- `assets/js/elementary_opening.js`: handoff, companion, wheels/tacks, local camera
  and near clipping, treadmill integration, steering, sheet purchase and lifecycle cleanup.
- `assets/css/app.css`: situated notice, circular detents, companion styling and
  fixed future wheel reserve.
- `lib/..._web/live/architecture_live.ex`: native contextual handoff, treadmill,
  steering, stop/release instruments, settings and clear reset label.
- `lib/.../architecture/traversal_course.ex`: versioned new-endpoint interpretation
  and wider running arch; old snapshots untouched.
- `lib/.../architecture/appliance_cutaway.ex`: explicit aperture-side Seat reserve.
- `test/js/cob_alongside_test.mjs`, `test/browser/cob_alongside.mjs`: new mechanics,
  boundary and full mouse-first encounter rehearsals.
- Existing traversal, appliance LiveView and appliance browser tests: corrected
  reservation, old-snapshot preservation, native instrument selectors and handoff entry.
- This report, source archive/checksum/index, architecture index and new witnesses.

## Verification and witnesses

- `mix precommit`: **119 tests, zero failures, one existing skip**; formatting,
  warning and unused-dependency checks pass.
- `mix assets.build`: passes.
- All **12 JavaScript test files** pass, including five new companion mechanics/
  near-clipping tests against Phoenix-produced data.
- Chromium companion rehearsal: mouse PULL/PUFF, take hold, slider handoff,
  retained reception, four wheels, shoulder view, treadmill engagement, steering,
  release/leave/blur, coasting, immediate stop, situated stopping sheet, reader
  reverse, release/resume, reverse drive and narrow-screen/reduced-motion handling.
- In-motion camera release and re-entry preserve distance, velocity and position
  exactly within the same event turn; source stick and XT surfaces remain identical.
- Appliance regression covers fixed shell/cab, resizable opening, external bearings,
  finite arrival, appended JANUSITE, shared Outreading and persistence. Earlier
  early-projection and retained reserved-layout/scroll/provenance rehearsals also run.

[Witness directory](visual-witnesses/cob-alongside/):
[available notice](visual-witnesses/cob-alongside/01-cob-available-notice.png),
[handoff](visual-witnesses/cob-alongside/02-handoff-reaching-through.png),
[received companion](visual-witnesses/cob-alongside/03-four-wheel-received-companion.png),
[shoulder view](visual-witnesses/cob-alongside/04-over-shoulder-at-departure.png),
[stopping purchase](visual-witnesses/cob-alongside/05-stopping-sheet-held-and-inspected.png),
[external view](visual-witnesses/cob-alongside/06-external-four-wheels-tacks-treadmill.png),
[wheel/tack detail](visual-witnesses/cob-alongside/06a-wheel-and-tack-detail.png), and
[narrow-screen cab](visual-witnesses/cob-alongside/07-mobile-companion-instruments.png).

Review should settle the companion proportions, feeling of the detents/coast,
limited lateral travel, shoulder-camera offset and sheet reach. Wheel roll is a
shared-distance rehearsal, not a friction/contact simulation. The course remains
finite and provisional. All deferred telephone, General Offices, full wheel,
Doll, Seat, RE-STEP, RE-ZIPPERING and production machinery remain deferred.
