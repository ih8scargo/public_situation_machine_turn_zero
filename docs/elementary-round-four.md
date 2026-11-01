# Elementary Opening — Round Four

Implemented on `experiment/constitutional-motor` at `/experiments/architecture`.
No commit or push was made.

## Operable result

The ordinary flat presentation still leads through first PULL, first PUFFING THROUGH,
and the Human-furnished Pointing-able appointment. The local Bellowing Thing then
becomes available for a distinct second PUFFING AROUND ABOUT. This furnishes the
visible outer extent and exposed drawer course, without opening or composing it.

Compose yellow CH at a lawful XT-edge mounting and green COB at a lawful bottom
mounting. Pointer dragging explores nearest available mounts; pointer release or
keyboard Enter accomplishes purchase. Arrow keys explore the three mounting choices.
Only after both purchases are accomplished does CH's PUSH BACK operate the coupled
drawer. COB's square travels continuously up its furnished course. The 90-degree
position is marked separately from the 180-degree return. The completed return
seats LOCK, with a local suction-cup analogy and a visible holding link between the
rail, front page and inherited Diorama. Release at the return unlocks travel without
erasing the furnished extent. The four page handles continue to turn Regarding.

A provisional small flick purchase immediately associated with the appointed handle
switches Flat-Page / Diorama Regarding. Tap/click or Enter/Space operates it. Each
mode retains its current vertical-axis bearing while mounted. Drawer extension,
LOCK, appointed bearing and four-point grasp survive both directions of flicking.
The modes project the same inherited material. Reload restores mechanical state,
while the temporary Regarding orientations begin afresh.

The intrusive yellow Floor–Wall sheet and its active geometry are removed, rather
than faded. Ground Floor and curving Wall–Ceiling remain reserved architecture. No
new Room, Human FROM, Landinging or RE-STEP is inferred. The original inscriptions,
material reserve and source-status distinctions remain intact.

## Event and persistence boundary

`Architecture.Diorama.second_puff/1` adds exactly one distinct fourth event,
`second-puffing`, dependent on `pointingable-standing` and `janusite-extent-standing`.
It furnishes `drawer-extent-standing`, stores its geometry snapshot on the event,
and adds `opening_geometry.drawer_extent`. All earlier event snapshots, the appointed
origin/tip/direction, COB's grasp, inherited geometry, Human FROM and localities remain
unchanged. Existing appointed records can continue directly; no schema migration or
version rewrite is needed. Earlier read-only witnesses retain their boundaries.

Recoverable mechanical state lives in the existing UUID record as
`standing.diorama_operation`, separately from constitutional relations and events:

| Field | Meaning |
| --- | --- |
| `ch_slot`, `cob_slot` | Accomplished lawful mounting choices; initially absent |
| `progress` | One shared drawer progress, bounded to 0–1 |
| `detent` | Holding condition derived from completing the return at progress 1 |
| `revision` | Mechanical revision guarding accepted updates |

Purchase accomplishment, completed travel gestures and deliberate release save this
state through the existing optimistic-locking Store. Hover, pointer motion previews,
Regarding turns and flicks do not add saved constitutional events. The server rejects
operation before furnishing, travel before both purchases, mounting outside the lawful
slots, mounting changes during travel, out-of-bounds progress, travel while held, and
stale mechanical revisions. A stale database write adopts the held record. Release
keeps progress at full extension, frees travel, and preserves all furnishing.

## Furnished geometry and mechanics

The first Globe remains untouched. Second PUFFING adds a larger surrounding extent
centered on that Globe, with radii `[6.2, 5.2, 6.4]` in current working units, derived
by adding `[2.5, 2.4, 3.2]` to its inherited radii. Three dashed sections expose that
extent without covering the Globe. Tests verify all lawful rail positions remain
inside it. The same furnishing snapshot supplies the rail dimensions and slot bounds.

For shared progress `p ∈ [0,1]`, let `a = πp`. COB's rail is:

```
x = chosen_bottom_x - inward * (1 - cos(a)) / 2
y = -height * cos(a)
z = depth * sin(a)
```

Current furnished values are `height = 3.25`, `depth = 5.2`, `inward = 1.5`, and
bottom x positions `[3.8, 4.1, 4.4]`. The course begins at the bottom on XT, moves
inward TOWARD YT while curving upward and behind the monitor, then returns at the
top. Endpoint tangents oppose one another: the full course is a 180-degree return,
not a quarter bend. At 90 degrees the course remains unfinished.

CH's separate course holds the chosen XT-edge height and pushes into positive depth
by `depth * p`. The inherited drawer material receives a presentation displacement
`[0,0,1.4p]`; stored points and provenance remain unchanged. COB, Globe, wireframe,
aperture, cylinder and Pointing-able geometry share that displacement. Equal progress
therefore does not imply equal screen displacement. Every projection is deterministic.

A narrow 0.2-percent endpoint capture resolves pointer rounding to exact progress 0
or 1; LOCK is requested only at the exact completed endpoint. There is no independent
lock button. The server derives the detent from completed travel, and only a deliberate
local release frees it. Keyboard arrows and Home/End provide accessible equivalents.

The hanging square tab retains its attached fixed-length pendulum and damping, with
stronger forcing from actual page angular velocity/acceleration. No unrelated idle
oscillation was introduced. Reduced motion remains supported.

## Experimental choices and reserved capabilities

The three-slot mounts, rail dimensions, gesture mapping, presentation displacement,
local flick purchase, endpoint capture and suction-cup drawing remain mechanical
rehearsal choices. Screen-facing purchase squares maintain usable targets while their
centers remain attached to the furnished world-space courses. Mobile notices shorten
according to available space. The current flick is a provisional local tap/keyboard
purchase, not a mature finger-physics mechanism.

`round-four-reserve.json` preserves exact authored excerpts for Steering Wheel,
BUTTONINGS, exterior/interior Roundabout Regarding, wedges, tabs and preservation of
Human FROM. Steering mounting and its relation to CH/COB remain constitutionally
unsettled. No arbitrary wheel, mature selectioning, RE-SEATING, POOFING Pockets,
RE-ZIPPERING or RE-STEP was introduced. STAGING FOR STANDING remains distinguished
from STANDING FOR STAGING.

## Files

Changed: `architecture.ex`, `architecture/diorama.ex`, `architecture_live.ex`,
`assets/js/elementary_opening.js`, `assets/css/app.css`, browser and JavaScript diorama
tests, archive README/checksums, and the report index.

Created: `architecture/drawer_test.exs`, `live/drawer_live_test.exs`,
`test/browser/witnesses/diorama_round_three.mjs`, this report,
`docs/machine-instructionings/round-four-source.txt`, `round-four-reserve.json`,
`round-four-narration.md`, and Round Four visual witnesses. The supplied attachment is
byte-preserved. The two original Round Three image files remain unavailable; no
reconstructions replace them.

## Verification

- `mix precommit`: **107 tests, zero failures, one existing skip**.
- JavaScript: **36 tests pass**, including deterministic rail travel, the 90/180-degree
  distinction, bounded equal progress and responsive damped tab motion.
- `mix assets.build`: passes.
- Phoenix/JavaScript persistence boundary: LiveView hook tests verify the fourth event,
  composed purchases, partial/full travel, LOCK restoration, blocked travel while held,
  deliberate release and return. All earlier event records, Human FROM and localities
  are preserved. Concurrent mechanical writes adopt held state without overwriting it.
- Chromium Round Four: actual first three operations, second PUFFING, local purchase
  composition by keyboard/pointer, continuous partial/full pointer travel, LOCK,
  flick with retained per-mode bearings, exact persisted reload, release and return,
  mobile/reduced motion, no forbidden later apparatus, and no page errors.
- Original Round Two Chromium regression suite: passes.
- `git diff --check` and archive checksums: pass.

Reproduce Chromium with `PLAYWRIGHT_MODULE=/tmp/opening-browser/node_modules/playwright/index.mjs`
and `PLAYWRIGHT_BROWSERS_PATH=/tmp/opening-browsers node test/browser/diorama.mjs`.
Temporary browser tooling adds no application dependency.

## Visual witnesses

- [Second PUFFING extent and available purchases](visual-witnesses/operable-diorama-v4/07-second-puffing-extent.png)
- [Composed purchases](visual-witnesses/operable-diorama-v4/08-composed-purchases.png)
- [90-degree course still traveling](visual-witnesses/operable-diorama-v4/09-quarter-course-90.png)
- [180-degree return and LOCK](visual-witnesses/operable-diorama-v4/10-return-180-lock.png)
- [Locked Diorama Regarding](visual-witnesses/operable-diorama-v4/11-locked-diorama-regarding.png)
- [Released and returned, furnishing retained](visual-witnesses/operable-diorama-v4/12-released-returned.png)
- [Mobile LOCK](visual-witnesses/operable-diorama-v4/13-mobile-lock.png)
