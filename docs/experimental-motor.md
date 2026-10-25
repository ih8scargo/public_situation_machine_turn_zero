# Experimental constitutional motor — driving correction

Branch: `experiment/constitutional-motor` (preserved).
Route: `/experiments/motor`. Existing public experiences and refolding quarry are untouched.

Run `mix ecto.migrate`, then `mix phx.server`. Open the route without an `id` for a
fresh A. The URL acquires a laboratory record UUID; save the URL to resume Standing.
Regarding, pointing, selection, progress and pace reset on reload.

## Richard's next drive: primitive next

1. Start a fresh record at `/experiments/motor`. CURRENT FROM is A.
2. PUFF. THIS NEXT reads B; FROM remains A. RE-STEP is available. There is no
   PIVOT B handle; POINT, SELECT, RE-SEAT and NAV-STEP are unavailable.
3. RE-STEP directly. FROM becomes B; the passage receipt says A to B by-way-of
   PUFF and RE-STEP. No inscription or simulated-distance traversal was required.
4. FROM WITHIN B, enter one non-whitespace character and use IN-STRINGING-MENT.
   B gains WHAT-FOR/Occupancying and becomes available FOR Projectioning.
5. PUFF, RE-STEP for C, then D. Occupancy before passage is never required.
6. PIVOT toward occupied earlier B. FROM remains D.

A second PUFF is unavailable while THIS NEXT exists: it cannot silently replace
that singular relation. RE-STEP consumes it exactly once. If both THIS NEXT and a
selected re-seated differentiated landing exist, THIS NEXT has priority. The
RE-STEP TARGET / BY-WAY-OF diagnostic exposes the actual domain-resolved target.
This coexistence priority is an explicit laboratory policy for review.

## Richard's next drive: differentiated Landinging

Use a second fresh record to inspect this rhythm independently:

1. REGISTER LAB-Y FIXTURE adds plainly labeled occupied standing FROM THERE.
   It does not furnish THIS NEXT or change FROM A.
2. PIVOT toward LAB-Y, POINT, SELECT, then RE-SEAT.
3. NAV-STEP repeatedly: progress and markers change, FROM remains A.
4. Change NAV rate (0.05–100 normalized units/sec; ordinary reference 5).
5. Optionally PIVOT toward A. Selection ceases; the A:LAB-Y approach remains
   registered. PIVOT back to LAB-Y, POINT and SELECT to take it under active
   selection again. Another RE-SEAT is unnecessary.
6. Optionally RE-STEP. Only now does FROM become LAB-Y; the receipt identifies
   the RE-SEATING relation and landing. NAV traversal and reading are optional.

Disabled controls and omitted PIVOT handles reflect domain availability. There
is no CANCEL/DESELECT operation. The registry is an engineering outreading, not
an assertion that every registered possibility is locally Regardable.

## Contracts and representation

`Motor` owns Standing, operation contracts, availability and projection data.
`standing["next"]` is either nil or the singular durable PUFF relation with FROM,
TOWARD and by-way-of. Extents explicitly distinguish `possibility`, inhabited
`standing`, and the laboratory `fixture`. PUFF registers possibility without
occupancy or passage. Primitive RE-STEP consumes next, establishes inhabited
standing and records ancestry. Only then may Human text furnish WHAT-FOR from
within the current extent. Text is retained without machine semantic inference.

Ordinary projectability requires inhabited/fixture standing plus WHAT-FOR.
Pointing further requires a differentiated target through the current bearing.
Selection and RE-SEATING remain separate. RE-SEATING registers an approach;
Pivoting away clears temporary pointing, selection and progress without erasing
that approach. RE-STEP is the only operation that changes FROM.

The separate PostgreSQL `experimental_motor_records` table still stores only
Standing, with optimistic locking. No database schema migration is needed for
this correction: snapshots now carry version 2, extent kind, and next. Pending
PUFF survives reload. Legacy snapshots are upgraded in memory and on their next
Standing write: current and passage-connected extents are recognized as standing;
no pending next is invented from an old uninhabited registry entry. Such old
entries and their text remain preserved but unavailable for ordinary Regarding.
Use a fresh record for the corrected acceptance circuit. Older already-committed
passage receipts remain historical records and are not rewritten.

## Provisional laboratory geometry and input

The differentiated approach remains a fixed quadratic curve with a normalized
100-unit progress coordinate and five markers. NAV integrates rate times an
explicit elapsed-time quantum. This is parameter progress, not physical arc
length. 4/6/8 are not speed settings. No curve, distance or NAV is fabricated for
primitive PUFF-next. Buttons/forms adapt inputs; no keyboard-specific dependency,
physics, mature apparatus or new public entrance was added.

`MotorLive` only submits operations, persists changed Standing, and renders the
domain's availability and projection. Domain tests prove both rhythms, occupancy
after passage, ancestry, constrained Pointing, optional passage, pace and retained
RE-SEATING. LiveView tests exercise both driving circuits, pending-next reload,
continued Standing reload, and stale-write rejection. Run `mix precommit`.
