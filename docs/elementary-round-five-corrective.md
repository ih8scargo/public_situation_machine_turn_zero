# Round Five corrective addendum — reserved extent and retained XT inscriptions

Implemented at `/experiments/architecture` on `experiment/constitutional-motor`.
No commit or push. The [instruction](machine-instructionings/round-five-corrective-addendum.md)
is archived separately from this implementation report.

## Corrections

The apparatus now has one expressly reserved layout extent, independent of event
stage and Regarding angle. `reservedEnvelope()` accounts for the currently furnished
outer extent, Ground-side approach, apparatus and all lawful return courses through
complete vertical-axis pivoting. The same SVG viewBox is used at every angle and
stage. A fixed responsive host reserves its height; the status row has its own fixed
space. The ordinary guide has reserved space beneath it. The introductory heading
is static. Browser scroll anchoring is disabled for this composition.

The preceding implementation dynamically fit the SVG width to each bearing while
leaving its height to its aspect ratio. Event-dependent headings could also wrap to
different heights. Those assumptions caused surrounding content to move and have
been removed. The pivot center also remains the same before and after first PULL,
so new furnishing does not change the projection basis of the already-standing page.

Human-directed scrolling is available before appointment. The Human may explicitly
approach the projection using + / − or return to Whole extent. Those controls change
projection scale within the reserved host; they do not move standing or create an
event. They do not run automatically. Turning a page handle changes Regarding;
Home regards flat and End regards edge-on. The existing flick preserves its separate
Human-selected bearings. Coupled drawer operation retains its separate material
presentation displacement. Consequential events furnish material without selecting
a bearing, changing the Human's zoom, focusing an inscription, or scrolling the page.

The current opening's server restoration no longer inherits the legacy quarry's
automatic `situated` bearing assignment. Retained historical quarry behavior remains
separate from the current operable opening.

## Convertible surfaces and retained locality

Each of the four existing consequential events now snapshots an
`inscription_locality` when it is furnished. No new constitutional event is added.
The snapshot contains a named XT-axle locality, world-space anchor and quadrilateral,
inscription/title, source relation, ancestry and the `xt-axle-v1` layout version.
The unchanged event ID supplies provenance. Existing event geometry snapshots, Human
FROM and the constitutional sequence remain intact.

`Architecture.Inscriptioning.retained/1` reads those snapshots. Older accomplished
records lacking this new field use a frozen v1 compatibility derivation, without
rewriting their historical events. The helper for new locality generation is separate
from that compatibility recipe so future layouts need not relocate older material.

The earliest inscriptions stand ALONG THROUGH the furnished XT axle. A grounded
ancestry member rises from the inherited Floor toward the aperture-level axle. A
short inner spindle shares this reference and opening toward the Gallery. The full
great out-spooling spindle is not implemented. Exact surface mounting is explicitly
experimental: four fixed localities along the grounded axle with an inherited
Human-standing/source-relation ancestry.

Each locality appears as its retained projected surface in both Regardings. A Human
may select it directly by pointer or keyboard. In Flat-Page Regarding, its readable
flat counterpart unfolds inside the reserved apparatus extent with the same locality
ID, provenance and inscription. In Diorama Regarding its projected surface remains
available at the same world-space anchor. Returning restores the same readable
inscription. Reload preserves the locality through the existing UUID record.
Selection never automatically changes mode, bearing, zoom or scroll.

The flat counterpart is a presentation of the furnished machine surface, not a new
paragraph declaring standing beneath the Toy Box. Below-apparatus content is now
explicitly an ordinary operation guide. Its inspection area exposes relation IDs
and provenance metadata rather than substituting constitutional declarations.
The transient Regarding condition line does not furnish or locate inscriptions.
Accomplished material comes from retained event data, independently of selection,
status messages, current drawer extension, carpet seating or LOCK.

## Verification of the five requested invariants

| Requested demonstration | Verified result |
| --- | --- |
| Flat / edge-on without vertical reflow | Host top/height, guide position and scroll differ by less than one pixel; viewBox is identical at 0° and 90°, desktop and mobile |
| Stable scroll at appointment | First PULL, first PUFFING, Pointing-able appointment and second PUFFING retain scroll, bearing, zoom, host and guide positions |
| Human approach before appointment | Ordinary mouse-wheel scrolling changes scroll position while no Pointing-able appointment or inscription has been accomplished |
| Inscription at XT-axle locality | The first-PUFFING surface has retained `xt-axle-first-puffing` identity, source event and grounded axle frame |
| Return through another Regarding | Flick to Diorama and back preserves locality and inscription; UUID reload recovers the same surface records |

The browser additionally verifies LOCK and deliberate release without transporting
Regarding or resetting the Human's explicitly chosen 1.5× approach scale. The
inherited Round Four and Rugging browser rehearsals continue to pass. Surface layers
remain behind the inherited figures/aperture rather than covering their geometry.

Checks:

- `mix precommit`: **111 tests, zero failures, one existing skip**.
- JavaScript: **41 tests pass**, including full pivot/return envelope containment.
- `mix assets.build`: passes.
- Round Five corrective Chromium sequence: passes, with no page errors.
- Round Four and Rugging Chromium regressions: pass.
- `git diff --check`: passes.

## Current assumptions and limits

The reserved numerical envelope is for the currently furnished extent and lawful
courses. Enlarging those bounds later requires updating the reservation and its
containment test. Explicit Human zoom may crop the whole envelope within the fixed
host; Whole extent restores it. Neither choice changes page layout or is driven by
a constitutional event. Browser resizing and Human expansion of ordinary guide
details remain ordinary computering actions.

The v1 axle/surface mounting and short inner spindle are bounded architectural
rehearsals. Earlier records reconstruct their new surface presentation through the
frozen compatibility recipe; their original events are not retroactively rewritten.
Temporary view choices are not saved as a new FROM. A Human-directed page reload
begins the temporary camera choice afresh while recovering accomplished localities
and Round Four's saved mechanical condition.

No current known assumption prevents the five demonstrated invariants within these
furnished bounds. There is no automatic scroll/focus/zoom operation on furnishing,
no RE-STEP, no new Landinging and no mature great spindle.

## Files and witnesses

Created: `architecture/inscriptioning.ex`, its domain tests,
`test/js/reserved_regarding_test.mjs`, `test/browser/reserved_regarding.mjs`, this report,
archived corrective addendum, and `docs/visual-witnesses/round-five-corrective/`.
Changed in this correction: `architecture.ex` (surface snapshots and restoration
boundary), `architecture_live.ex` (stable reserved layout and machine-surface reading),
`assets/js/elementary_opening.js`, `assets/css/app.css`, report/archive indexes.
Pre-existing Round Four and Rugging work is retained.

- [Human-directed approach before appointment](visual-witnesses/round-five-corrective/01-human-directed-approach-before-appointment.png)
- [Appointment without scroll or extent change](visual-witnesses/round-five-corrective/02-appointment-stable-scroll-and-extent.png)
- [LOCK without Regarding transport](visual-witnesses/round-five-corrective/02b-lock-without-regarding-transport.png)
- [Flat reserved envelope](visual-witnesses/round-five-corrective/03-flat-reserved-envelope.png)
- [Edge-on, same reserved layout](visual-witnesses/round-five-corrective/04-edge-on-same-layout.png)
- [Retained XT-axle inscription, flat presentation](visual-witnesses/round-five-corrective/05-flat-retained-xt-axle-inscription.png)
- [Same locality in Diorama Regarding](visual-witnesses/round-five-corrective/06-same-locality-diorama-regarding.png)
- [Mobile edge-on reservation](visual-witnesses/round-five-corrective/07-mobile-edge-on-reserved-extent.png)

Run `test/browser/reserved_regarding.mjs` using the existing temporary Playwright
module and Chromium paths documented in the earlier reports.
