# Elementary opening, round one — implementation return

October 28, 2026. Route: `/experiments/architecture`.
Branch: `experiment/constitutional-motor`. Existing uncommitted experimental work
was preserved. No commit, push, migration, or Python contract change was made.

## Inspection and reuse

The previous pass started with a solid-looking reserved Toy Box, square appliance
COB, a one-button pointing appointment, Projectioning-er correspondence, and Road/
Seat reservations. Those assumptions contradict this round. They remain historical
quarry in `Architecture.puffing_witness/0` and the archived
`first-puffing-witness.md`; their original persisted records are not rewritten.

Compatible machinery reused: the existing consequential event/course/link builder,
local provenance ancestry, PostgreSQL UUID records, version guards, optimistic locks,
separate Regarding state, and `PullingRing`'s purchase → movement → release/cancel
lifecycle, including its keyboard accommodation. Earlier geometry/Spindle/semantic
and compression hooks and tests remain in the repository, outside the new surface.

History at `1c41a8e` includes `quiet_locality.js`'s cursor-responsive exponential
settling and `toy_apparatus.js`'s separate body/articulation responsibilities. The
bounded response and frame-time settling mechanism were adapted to the new rounded
ellipsoid. Its later tunnel motion, automatic lean, four-point apparatus, projected
TC, seating and navigation were not restored. No historical character asset or
permanent suspension mechanism was imported.

## One underlying geometry

Fresh records use `elementary-opening-v1`. Initially `opening_geometry` contains
only a planar sheet at z=0 and one available circle. The Human already stands FROM
HERE; the circle is a planar furnishing TOWARD Place. There is no Landinging,
reserved Road, hidden volume, completed apparatus catalogue or later machine behind
this sheet. Historical versions—including `first-puffing-v1`—remain read-only UUID
witnesses with their own original ancestry.

One small wheel controls a range input over its circumference, with native arrow-key
operation. Its value rotates the same world coordinates around the sheet's central
transverse x axis. A single perspective projector draws front, edge and backside;
there is no second backside diagram or separate scene. Before PULL every available
point is planar. The wheel and body response never send a furnishing operation or
save a record. Wheel position is temporary Regarding, not a persisted appointed
bearing. It stays consistent across ordinary LiveView patches.

The sheet's boundary locates the monitor plane. The original circle is the opening
purchase; its ID and coordinates survive all subsequent operations. The wireframe's
12 edges hold earned bounds. JANUSITE's three orthogonal elliptical sections make
its earned volumetric extent inspectionable. COB's closed section and meridians
furnish its rounded volume. The stick is a true 3D segment; a small cross locates its
intersection with the monitor plane. The UP OVER marker is the temporary receiving
purchase on the locked geometry. There are no ornamental lines or scene backgrounds.

## Three completed furnishing events

| Event | Operation and earned result |
| --- | --- |
| `first-pull` | A purchased tab actually moves and is released. This stands UP Toy Box **wireframe TOWARD Place**, initial square COB, and the available inaugural bellows operation. It adds no circle, material, Landinging or Situation Stage. |
| `first-puffing` | Squeezing THIS ONE BIG BELLOWING THING furnishes **JANUSITE extent FOR possibility TOWARD OVER ACROSS** and carries COB outward from its initial square ancestry into rounded, responsive standing. COB's initial rounded center is outside the earlier wireframe. |
| `appoint-pointingable` | After the Human chooses and locks a full THROUGH segment, bringing COB **UP OVER** it furnishes THIS ONE POINTING-ABLE THING **THROUGH BY WAY OF COB**, retaining the Pretending Stick ancestry and exact furnished bearing. This is the endpoint. |

All use the existing event builder: actor, labor, FOR, inherited FROM before/after,
dependencies, ancestry, consequences, course and immediate THROUGH-BY-WAY-OF links.
PULL and PUFF additionally retain their resulting geometry snapshots in their events.
Appointment retains its exact furnished segment in its event. The current geometry
and these snapshots survive reload. They support deterministic examination of the
results; no new general replay engine was introduced. Human FROM never changes.

Square ancestry remains addressable through `cob-square-standing`. The puffer's
predecessor passes through that standing, so local ancestry from rounded COB returns
through its own inaugural PUFF and original square. COB's ALONGSIDE WITH Human and
THROUGH current local moment are separate held relations.

## Staging, bearing and accomplishment

The Human supplies direction (yaw), angle THROUGH (pitch), furnished extent (length),
and amount fed THROUGH. Feeding at partial extension draws a temporary segment;
LOCK is available only at full extension. These are actual depth coordinates, not
a cursor constrained to the monitor surface. Pivoting makes the distinction visible.

The domain validates finite bounded numeric values: yaw ±60°, pitch ±45°, length
1–3 rehearsal units, and full extension 1. It computes the direction unit vector
`[sin(yaw) cos(pitch), sin(pitch), cos(yaw) cos(pitch)]` and the tip from that vector
and the Human's chosen length. No fixed target bearing replaces those values.

LOCK holds those coordinates in `opening_stage`, an ephemeral server-side staging
purchase. Locking does not write a constitutional event or database record, and the
sliders are withdrawn so the locked bearing cannot drift. Reload before completion
abandons staging. The Human then either drags rounded COB to the projected UP OVER
purchase or explicitly activates “Bring COB UP OVER the furnished stick” by keyboard.
Both request the same named operation against the server's locked geometry. Pointer
coordinates alone cannot appoint anything.

Only that completed operation persists `origin`, `tip`, `direction`, `yaw`, `pitch`,
`length`, full `extension`, and the consequent COB center. COB's orientation is the
same supplied direction vector. No predefined swing is applied. Temporary cursor
response is bounded and changes only the outreading. Lock/appointment clears prior
motion offset so the acquired position takes up the actual held geometry. Responsive
motion never changes orientation, supplies another event, or creates new standing.
Reduced-motion users get direct response without settling animation.

The public interface rejects later operations and the obsolete button-only
appointment. Repeated operations cannot duplicate accomplished events. Optimistic
locking handles simultaneous views; stale views adopt the actual saved geometry.
Local readings follow actual held predecessors without writing to persistence.

## Deliberate stopping boundary and uncertainties

Implemented only through the completed Pointing-able appointment. No Projectioning-er,
Pretending Square, computer scootering/Weddinging, Chair, Landinging, Situation Stage,
Doll, stitching, Road/Gallery/Seat, STEP/RE-STEP, POOFING Pocket or later PUFF is built,
reserved, previewed or rendered in a fresh composition. The earlier passes remain
unchanged historical witnesses, not hidden future structures in this opening.

World dimensions, aspect ratios, finite operating aperture, projection scale and
responsive settling rate are rehearsal drawing purchases, not newly declared
constitutional constants. JANUSITE's full material behavior, suspension mechanics,
square Consoling Surfacing/Correspondencing, later material STAGING, and the larger
Theatre remain unresolved and unimplemented. The bounded loop and explicit keyboard
UP OVER operation demonstrate the authorized relation without deciding those later
mechanics. No question requiring further constitutional invention was used as a
reason to fabricate a next apparatus.

## Changed files and verification

- `architecture/opening.ex`: fresh minimal givens and the bounded domain operations,
  validated Human-furnished segment and consequential geometry snapshots.
- `architecture.ex`: versioned entrypoint, retained preceding construction, temporary
  opening staging, shared furnishing builder and dispatch into this slice.
- `architecture_live.ex`: thin persistence/event interface, wheel, pull, squeeze,
  staged controls, COB UP OVER and local ancestry. No later apparatus.
- `assets/js/elementary_opening.js`: one 3D projector, keyed elementary geometry,
  temporary gestures, locked line outreading and bounded responsive COB.
- `assets/js/app.js`, `assets/css/app.css`: current hook registration and scoped
  plain white geometric presentation; historical styles/hooks remain quarry.
- New `opening_test.exs` and `elementary_opening_test.mjs`; updated public LiveView
  tests; preceding PUFF domain tests explicitly use the retained witness fixture.
- New `test/browser/elementary_opening.mjs`; preceding browser program archived under
  `test/browser/witnesses/first_puffing.mjs`; this report and visual witnesses.

Verification:

- `mix precommit`: **101 tests, zero failures, one existing skip**.
- JavaScript: **30 tests, zero failures**, including bounds across every wheel
  bearing, immutable projection, true depth, chosen bearing, and bounded response.
- Asset build and `git diff --check` pass.
- Chromium exercises the planar backside before PULL, unchanged initial circle,
  twelve earned wireframe edges, no early JANUSITE, outward rounded responsive COB,
  partial-extension lock rejection, chosen direction/angle/length, full lock,
  pivoting locked geometry, actual pointer drag UP OVER, exact UUID reload,
  predecessor inspection, mobile overflow, and keyboard/reduced-motion completion.
  It also checks that later apparatus is absent and no browser errors occur.

Visual witnesses:

1. [Initial planar backside](visual-witnesses/elementary-opening/01-planar-backside.png)
2. [PULL-earned wireframe and square](visual-witnesses/elementary-opening/02-pull-earned-wireframe.png)
3. [PUFF-earned outward rounded COB](visual-witnesses/elementary-opening/03-puff-rounded-outward.png)
4. [Human-furnished THROUGH bearing locked](visual-witnesses/elementary-opening/04-through-bearing-locked.png)
5. [Completed Pointing-able appointment](visual-witnesses/elementary-opening/05-appointed-bearing.png)
6. [Same accomplished geometry, mobile Regarding](visual-witnesses/elementary-opening/06-mobile-appointed.png)

Browser runner accepts `PLAYWRIGHT_MODULE`, `PLAYWRIGHT_BROWSERS_PATH`, optional
`ZEROETH_URL` and `OPENING_WITNESSES`. Browser tooling is temporary under `/tmp`;
no application dependency was added. The Phoenix/Python boundary was not touched.
