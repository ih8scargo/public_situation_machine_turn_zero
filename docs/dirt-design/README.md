# DIRT — TOWARD what came to stand

Current geometry requirements: [Geometry RE-surfacing Table](../architecture/geometry/README.md), with a [proposed geometry provenance extension](../architecture/geometry/dirt-contract.md). Historical fixture versions and hashes remain unchanged.

Inspection and placement proposal, 12 November 2026. No application implementation is authorized or included. DIRT means **Discrete Instrumentationing Recording Tractioning Track**. Its unit of evidence is an accepted consequence in inherited standing. A row does not have to make sense independently of its predecessors.

Recommendation: retain a versioned starting state and an ordered, append-only succession of accepted consequences, with configuration effective at every consequence. Save each consequence and the resulting standing in one optimistic, idempotent database transaction. Offer DIRT as optional Regarding from Situationing Stage. Reconstruction mounts a separate, read-only run after review.

## What can actually be reconstructed

The strongest initial witness is `spindle-rail-pass`. Current `Architecture.versions/0` recognizes it, `restore/1` retains its standing, and `Store.save/2` refuses to alter it. The active `Architecture.new/0` now creates `operable-opening-v2`; its reducer is not the old rail reducer. The old complete reducer is recoverable at Git checkpoint `c6553a0`, `lib/public_situation_machine_turn_zero/architecture.ex`. A byte-preserved copy is [spindle-rail-source.ex.txt](spindle-rail-source.ex.txt). It is a reference artifact, never an uploaded executable.

The [sample CSV](spindle-rail.csv) is a **proposed import fixture**, not an export of a person's actual historical run. Its eight operations and all expected states were evaluated with that historical pure reducer under a temporary module name. [Expected states](spindle-rail-expected.json) contain initial, every before/after, and every event. The fixture has no fabricated measurements or acceptance timestamps. There is no CSV importer or DIRT interface today. Current recognition of the historical version is insufficient to replay it: the first build needs a pinned, isolated adapter.

CH here means Constitutioning Human. There is no unified CH configuration service connecting these experiments. The rail witness inherits its Human/TC/Ground givens; it has no adjustable metric settings. The proposed `ch0` records this explicitly. Configuration from the appliance, Motor and other workshops must remain separate namespaces until a source-backed bridge exists. A full new-run recorder can capture configuration decisions before any labor; a retrospective import cannot manufacture them.

## Acceptance and durability ledger

| Path | Candidate operation and actual acceptance | Survives reload | Missing evidence today |
|---|---|---|---|
| Spindle Rail, historical reducer | `operate/2` accepts only `next/1`'s exact action with all dependency IDs present. Historical `furnish/2` builds event ancestry and standing together. Persistence, rather than a button press, is the durable acceptance. Current Architecture LiveView follows domain success → optimistic save → accepted reply; historical versions are now read-only. | UUID standing; relations, provenance, dependency snapshots, stations, events, passages and full FROM. | No per-event sequence/clock/config version or idempotency key. Current reducer cannot execute the old actions. |
| Motor | `:puff` establishes singular THIS NEXT. `:re_step` consumes a matching NEXT first, otherwise requires selection matching bearing and a registered approach. Domain result becomes durable only after `Store.save/2`. | Extents, WHAT-FOR, NEXT, registered landing curve/markers, FROM and passage receipts. | No complete ordered operation journal. Rate, bearing, point, selection and progress are temporary; receipts do not retain those acceptance inputs. |
| Instrumentation lab | Lift → turn → select → align → OVER leaves seating unchanged. `:seat` (Push DOWN) replaces `standing["seated"]`; LiveView saves only changed standing with optimistic lock. | A/B/C identities, ordered Rail membership, bearings, A→C fixture provenance, current seating. FROM remains fixture A; no passage is acquired. | Prior seating and alignment/selection acceptance history are absent. A same-seat success can leave identical standing and cause no save. |
| Paired Motor | `operate(state, revision, action)` rejects stale revision and phase failures; success appends event, increments revision. Ground is rehearsed, not acquired. | Nothing from this panel: `StringRibbonLive.mount/3` creates `PairedMotor.new/0` on each mount; no Store call. | Events are process-local; no durable commit, clock, configuration or constitutional turn boundary. |

A domain `{:ok, state}` and a saved consequence are distinct acceptance levels. A stale rejected write must never be exported as accepted. Inspection or projection changes can succeed without a standing consequence. Record those only in an explicitly separate diagnostic category when needed to explain an acceptance decision.

## One complete succession

The initial standing has seven givens, empty events/stations/passages, and FROM `{human: human, up_on: landinging-here, temporal_purchase: time-here, basis: human-from-here}`. There is no Place, seat, passage or next temporal purchase in standing.

| Event order | Accepted Human labor | Consequence and locality | FROM / configuration |
|---|---|---|---|
| 1 | `approach` | Human TOWARD developing Situationing; no Appointmenting locality | Initial FROM; ch0 |
| 2 | `appoint-cob` | COB ALONGSIDE WITH Situationing; ZEROETH | Unchanged; ch0 |
| 3 | `furnish-pretend` | Pretend Pointing THROUGH-BY TC, TOWARD Pointingable | Unchanged; ch0; FIRST is not yet appended |
| 4 | `appoint-pointing` | Pointingable THROUGH-BY Pretend, FOR Human; FIRST appended | Unchanged; ch0 |
| 5 | `stand-tc` | TC FROM DOWN UNDER machine and FOR Place; SECOND | Unchanged; ch0; actual TC still WITH Human |
| 6 | `stand-place` | Machine THROUGH-BY TC STANDS UP Place; Place FOR/TOWARD Human and UPON next Landinging; staging, second temporal purchase, rugging; THIRD | Still original FROM; ch0 |
| 7 | `seat` | Human SEATED FOR Place, passage AVAILABLE FOR Human, FROM/TOWARD distinct Landingings; Current Local Moment WAY THROUGH passage | Still original FROM; ch0; seating is declared Human labor, not a physical sensor |
| 8 | `step` | Human OVER ACROSS next Landinging, THROUGH-BY moment, UP ON/FROM next Landinging and FROM WITHIN Place | Destination FROM on time-there; ch0 |

This is eight events, four Stationing Localities, and one completed witness passage. These counts must remain separate. FIRST has two labors but only one station appended at appointment; seat/STEP add no new locality. No fifth Appointmenting follows STEP.

STEP depends on exactly `human-seated`, `passage-available`, `moment-way-through`, `place-upon-landinging`, `human-from-here`, `landinging-upon-time`, `next-landinging-upon-time`. It marks `human-up-on`, `human-from-here`, `landinging-staging`, `passage-available` fulfilled by `step`; it does not delete them. The event ancestry contains pre-STEP snapshots. Other relations, including seating and moment-WAY-THROUGH, are not marked fulfilled by this reducer; do not infer extra lifecycle changes from a retired visual passageway.

The [exact relation ledger](relation-ledger.md) enumerates every subject, exact ordered prepositioning, object, inherited dependency basis and establishment/fulfillment provenance. Do not split `FROM DOWN UNDER`, `STAGING FOR STANDING FROM WITHIN` or `FROM WITHIN` into unordered keywords. Relations are identified propositions with an ordered predicate string under a versioned vocabulary, not screen coordinates.

Outreading example: row `e9` declares STEP with before-hash matching seated `e8`, seven dependency IDs and their ancestry snapshots. The reducer yields relation `human-from-within`: subject `human`, predicate `FROM WITHIN`, object `place`, provenance `step`, and the same seven dependencies. Resolve labels using the pinned `name/1`: “This One Constitutioning Human FROM WITHIN This One Place FOR This One Constitutioning Human.” Resolve its basis through the STEP event and passage record: source time-here, destination time-there, BY-WAY-OF current-local-moment with `moment-way-through`, next Landinging, seated basis and resulting FROM. Reading only `human / FROM WITHIN / place` would lose the earned succession.

## Ordering, turns, timing and configuration

Use per-run contiguous `seq` as authoritative event order; a run-scoped entry ID and previous-entry hash establish chain continuity. DB revision provides concurrency control, not a Discrete Turn count. A wall timestamp never sorts events or establishes a temporal purchase.

For the fixture, `witness-turn-1` opens at approach and closes at STEP; intermediate records prepare it and have acquired delta zero. STEP completes one **witness passage**, not a claim to mature protected constitutional turn certification. This is a proposed grouping policy absent from the historical schema; export it with its policy version. In the eventual live recorder, retain stable turn ID, open event, closing acceptance event, initial/resulting standing hashes, status (open/completed/abandoned), and explicit acquisition authority. Allow incomplete final turns. Rehearsals can have a rehearsal group ID and no acquired turn at all.

Record server `accepted_at_utc` at durable commit, optional client observation time with clock provenance, measured duration in ms from a monotonic source, and clock epoch/session ID. Monotonic readings cannot be compared across sessions. Distinguish unmeasured null from measured zero. DB record timestamps only bound record creation/update; they cannot recover event times. `time-here`, `time-there` and Current Local Moment remain distinct semantic identities; the latter's WAY THROUGH purchase is neither a station nor a stopwatch.

Each accepted consequence references an immutable effective configuration and stores resolved acceptance context. Configuration changes get their own ordered record with old/new versions, scope, actor/source, and next effective sequence. Never replay using today's defaults.

| Source/context | Values to preserve at the consequence | Unit / derivation / authority |
|---|---|---|
| Historical Rail / ch0 | Human, TC, Ground identity; exact givens; next action; explicit Human decision; station/event version | No adjustable metric values. Seat is declaration; no clock or body measurement. Pointing gesture does not itself make consequence. |
| Pull witness where actually present | raw dx, dy, duration_ms; sanitized values, validity, measurement source and algorithm version | CSS px and ms; displacement sqrt(dx²+dy²), mean speed displacement×1000/duration only when duration>0, bearing atan2(dy,dx)×180/π. `affects_standing=false`. Never retrofit this different witness onto old rail events. |
| Motor | resolved target, NEXT vs RE-SEATING priority, selected/bearing/approach ID as applicable; rate and explicit NAV seconds/progress if recorded; inscription text | Rate 0.05–100 normalized units/s, default 5; NAV quantum >0 and ≤10 s; progress=min(length, previous+rate×seconds). Landing length 100, authored curve and markers are lab units, not 4/6/8 calibration. NAV is optional for RE-STEP. |
| Instrumentation | previous seat, held station, bearing index and resolved bearing, selection, alignment and OVER decisions, explicit downward stroke | Bearing identities and booleans; index in ordered station bearings. No measured dial angle. Reciprocal view does not reverse ancestry. |
| Coming Aboard configuration | bugs, restep, input device/kind; exact source state/version | Defaults 1 and 6; accepted strings bugs 1/2/3, restep 3/6/12. These are separate knobs, not acquired turns or geometric proof. |
| Paired Motor | revision, phase, q, action, footing IDs, index=0, model version, cargo-derived material identities | q dimensionless [0,1], diagnostic angle=q×π/2 radians. Trial extent units, never physical metres. Derived geometry pins algorithm/frame. |

## Rail Line and correspondence register

Maintain separate namespaces. A source-backed analogy or transform is not identity equality.

| Registry | Source and identities | Preserve / qualification |
|---|---|---|
| Tuple Crooked RAIL LINE | `canonical_tuple_live.ex`, position 2 ACROSS and position 3 PROJECTIONING CROSSING; `priv/tuple/canonical_tuple_positions.md` | Continuity curving between distinguishable standings, enclosing TRACK set upon it; six segmentations and seventh seam described. This is constitutional source text; no canonical physical curve/metric transform to the Spindle trace is provided. |
| Spindle Stationing Rail | pinned reducer `stations`; zeroeth/first/second/third, with appointment event and WHAT-FOR | Ordered earned localities. No future stations prepopulated. Logical locality order is not measured rail length or a turn counter. |
| Instrumentation Rail | `Instrumentation.new/0`: rail A,B,C; station bearings; relation `place-tension` A→C, toward-place | Flat/curved display shares identities. A→C is explicit fixture provenance; adjacency in rail list is not dependency. Motor A is a different scoped identity. |
| Workshop authored line | `Architecture.InscriptionResolution`, `Workshop.RailRecovery`; letters 1..25, THE/PUBLIC/SITUATION/MACHINE = 3/6/9/7 | Preserve predecessor/successor, HEAD 1/TAIL 25, source curve samples and purchase intervals. Candidate bounded boxes overlap; unit physical embedding unproved. N18→M19 trial roll spans 17.5..18.5; ±180° with handedness unappointed. |
| Material Rail and courses | `PairedMotor.identities/1`, `StringRibbonGeometry`, `ComingAboardMachine` | Cargo, ribbon, road, bobbining string, rail, pinning line and YT course are seven distinct IDs. Preserve authored cargo reference and roles. PINNING endpoint holder ONE COB is registered diagnostic model data, not proof of grip or stitching. |
| Common extent registration | `ComingAboardMachine.registration/0`, `snail_point/1`, `monitor_point/2`, `road/1` | Explicit source correspondence: Snail HERE width 1.4 scaled by 6/1.4; fixed monitor centered/reoriented to [0,3,3]; road reuses CrossingRehearsal.point(t/2). This registered extent transform is not a recovered universal physical transform. |
| RailRecovery candidate frame | `RailRecovery`, recovery report | Ground normal [0,1,0]; HERE/NEXT candidate centers [0,3,0]/[0,3,6]. Distinct from Paired Motor diagonal NEXT. Historical source/Gallery/body/common metric transform and hinge registration remain unresolved. |

For every geometric reference persist `(run namespace, object ID, source version/hash, frame ID, unit, status)`. Edges also need ordered endpoint IDs, predecessor/successor IDs, source interval and orientation. Hinges need ordered endpoints, axis/bearing convention and source registration. Transported frames need tangent/across/normal and transform direction. A correspondence record names both frames, matrix/algorithm and provenance, or explicitly says unresolved. Null transform forbids measurement or identity inference across frames. Side view and FROM-WITHIN view must reference the same world object; cameras cannot establish a relation.

Paired triangle example reconstructable today: hinge A=[−3,0,−3], B=[3,0,3], retained root=[3,0,−3]. At q=0, outgoing tip=[−3,0,3]; at q=1 it is [0,3√2,0]. Retained triangle stays [A,root,B,A], outgoing [A,tip,B,A]. The second moving diagnostic uses trial reflection tip→[z,−y,x], not a recovered gearing law. Persist hinge order, IDs, q, unit/frame, normalized archway source and trial status. Rigid side lengths and shared hinge can be reproduced; physical fold clearance cannot.

HERE/NEXT square example: common registration HERE is X/Z=±3 at Y=0 and remains intact. StringRibbonGeometry's NEXT marker is a ±0.13 source square around SnailBody.arc_point(1/6), transformed with 6/1.4; it is not a SIX cube. Separately PairedMotor's prospective cubes have minima HERE=[−3,0,−3], NEXT=[3,0,3], side SIX. Their Ground squares meet at diagonal corner [3,0,3]; cubes share the vertical edge above that reference. Preserve both objects and source versions, not a single ambiguous NEXT. No acquired adjacency, en-voluming, doorway passage or ceiling curvature follows from the drawing.

Rehearsal example: Ground → pending_un_buttoning → progress(1.0) → furnish_return → next → Ground appends six events, revision=6, two trial Footings, and index=0 throughout. First Ground remains immutable/rehearsed; return is a later extent event. Entrance points are [0,0,0], [1,1,1], orientation [1,0,1], common plane x=z (normal [1,0,−1]). Return centerline can later be recorded without certifying occupied return clearance or AROUND ABOUT turning. DIRT should retain `constitutional=false`, acquired delta=0 on every event, prospective NEXT, trial reciprocal fold and unresolved clearance. No count of events or Footings is allowed to become acquired turn count.

## CSV contract and importer

Choose versioned starting state plus ordered consequences. This makes ancestry, intermediate configuration and acceptance reviewable. Checkpoints alone lose how a standing was earned. Add optional verified checkpoints later for seek performance: each binds sequence, state/config/registry hashes, adapter and prefix digest. Verify against replay from start; a checkpoint must never bypass an invalid prefix. No compaction that deletes ancestry is needed for the first build.

The sample has ten data rows: manifest e0, starting state/config e1, eight consequences e2..e9. JSON cells follow normal CSV quoting (double embedded quotes); JSON carries structured dependencies, relations and nested FROM. One row is one atomic accepted event, not one relation. This avoids a partly imported multi-relation consequence. Empty timestamp/duration cells mean unmeasured. `seq` is zero-based and contiguous; ordered by file position. CSV is UTF-8 with a header and standard quoted fields. Production export should bound file/field sizes and safely display formula-like text without altering recorded values.

The manifest pins format, adapter, source SHA-256, vocabulary, Rail identity, canonicalization and acquisition policy. For this integer-only fixture, canonical hashes use UTF-8 JSON with sorted keys, no spaces, no ASCII escaping; entry hash excludes its own `entry_sha256` cell and treats CSV scalars as strings. State hashes cover standing only; `ch0` and registry are bound by the hashed start row and immutable references. Production profiles with floating measurements need an explicitly specified number encoding/tolerance policy before approval; never silently round during validation. Hash chaining detects alteration, not authorship or truth.

Importer prerequisites:

1. Supported `dirt-design/1` schema, CSV/JSON grammar, canonical/hash rules, record kinds and boundary policy. This design profile must be explicitly enabled; it is not a current supported upload format.
2. Locally installed, reviewed `spindle-rail-pass@c6553a0` adapter implementing the pinned new/next/operate/name semantics and exact source hash. Never execute source supplied by an import. Historical source text alone is insufficient permission to execute it.
3. Starting givens/state and effective config `ch0` embedded in e1; identity namespace and logical rail registration from manifest/start; exact consequence relation definitions from the adapter. Reducer validates initial state against its constructor.
4. Versioned event, lifecycle and turn policies; relation dependency interpretation, name vocabulary and outreading renderer. Historical standalone source has all witness relation/station/passage semantics; Tuple and workshop geometry are not dependencies of this bounded witness.
5. For broader profiles: pinned geometry algorithms, source samples, frame/unit/transform registries, material IDs, numeric encoding and measurement algorithms. Every external artifact must have a manifest hash, available locally or bundled as inert data. No opportunistic remote fetch or substitution with current defaults.

Validation is staged and all-or-nothing:

| Gate | Required behavior |
|---|---|
| Parse/profile | Reject malformed/oversize CSV, missing columns, duplicate keys in JSON, unsupported format/adapter/vocabulary/policy. Report row and field; no mounting or writes. |
| Chain/order | Reject sequence gaps, duplicate entry IDs, noncontiguous/out-of-order rows, incorrect previous hash or entry hash. Do not sort, drop duplicates or guess missing entries. |
| Dependencies | Require referenced config, entity, frame, relation and predecessor to exist at the relevant point; only a reducer-authorized same-event consequence may refer forward within its atomic result. Reject cycles where the profile disallows them. |
| Semantics | Validate exact predicate and allowed endpoints, station/bearing membership, relation lifecycle, units/frame status, next legal action and inherited snapshot. Retired/fulfilled is not current availability. Never promote provisional to acquired. |
| Replay | Recompute operation with recorded acceptance inputs. Compare full event, dependencies, ancestry, consequences, FROM, relation fulfillment and resulting state digest. A syntactically valid declared consequence the machine cannot reproduce is a hard error. |
| Turns/final | Validate declared boundaries and acquisition policy; no phantom acquired turn. Match final state and configuration/identity registry. An open final turn remains open. |

[Damaged sample](spindle-rail-damaged.csv) changes STEP's `moment-way-through` reference to `missing-moment` without changing its hash. It stops at e9/seq9, entry-hash validation; no reconstructed session mounts. If someone recomputes that hash, dependency validation stops at STEP's missing inherited relation (or exact event comparison rejects its ancestry). If they also invent the missing relation, replay against pinned semantics still rejects the altered standing/event. Hashes alone are never sufficient validation.

Other review cases: duplicate e8 → duplicate ID/sequence gate; swap seat/STEP → order gate, then STEP prerequisites if rehashed/renumbered; omit stand-place → gap/chain gate, or missing dependencies on resealed input; unsupported version → profile gate; change FROM destination while preserving valid CSV → replay/event or after-hash mismatch. A declared seat-free STEP must fail even when every hash is recomputed.

Dry-run review shows supported version, source and fixture/synthetic status, completed/open turns, configuration changes, all provisional/unresolved qualifications, and exact first failure. Only a fully valid preview offers **Mount reconstructed Regarding**. Mount creates an isolated reconstruction ID linked to source digest, never overwrites or resumes the live source record. Closing preview before mount saves no run.

## Placement proposal

```text
Situationing Stage                                [Regard DIRT…]
  ordinary stage and labor remain available

DIRT Regarding — source run / reconstructed run / version / status
[Start] [Previous]   Turn 1 of 1 · event 7 of 8   [Next] [End]
 inherited standing      accepted labor          resulting standing
 FROM HERE/time-here     SEAT · Human            SEATED FOR Place
 actual dependencies     effective CH ch0        FROM unchanged
 [relation ancestry]     [timing: unmeasured]    [Rail / lifecycle]

[Download CSV] [Import CSV] [Close Regarding]
Import → Validate → Review succession and qualifications → Mount separately
```

Cursor supports initial state, acquired turn boundaries and events within a turn. A rehearsal view reads “6 events · 0 acquired turns,” with event cursor enabled and acquired-turn cursor empty. Selecting a station Regards its historical ancestry; it does not replay labor or change FROM. At a selected consequence show inherited and resulting standing alongside effective configuration, dependency provenance and actual temporal purchases. Distinguish pending dashed prospects from recorded standing.

Closing Regarding leaves the source's accepted standing, available labor, Rail locality identities and durable record intact. Cursor, camera, selection, illumination and temporary inspection may reset. Reconstruction stays isolated; never copy its posture into live machine standing. Download uses a consistent committed prefix; later source changes cannot mix revisions within one CSV.

## Atomic recording boundary

Add a domain/service command boundary around load expected revision → resolve immutable config → validate operation → compute standing/event → transactionally save standing and insert DIRT entry. Use a transaction with optimistic update plus unique `(run_id, seq)` and `(run_id, command_id)` constraints. The entry binds before revision/hash, resulting revision/hash, config hash, actor, resolved target, acceptance evidence and turn effect. Publish accepted reply or broadcast only after commit.

A stale revision rolls back both writes. A retried command with the same command ID and same payload returns the already committed receipt; the same ID with different payload is a conflict. A newly generated command ID for a consumed operation fails domain guards. Concurrent acceptance must serialize on the run revision; calculate sequence from committed revision under lock/CAS, never from a browser counter. If a separate event insert fails, standing update rolls back. For JSON-embedded historical events, retain that compatibility snapshot but make the transaction journal authoritative and cross-check them. Config revision changes participate in the same check so an operation cannot be accepted under one configuration and recorded under another.

Instrumentation needs this explicit command/receipt model because its snapshot cannot prove a same-seat stroke or intermediate decisions. Motor needs resolved transient guard evidence captured at acceptance. Paired Motor needs persistence before any durability promise, while retaining zero acquisition authority. Do not retrofit journal entries claiming missing historical actions were observed.

## Source-to-field ledger

| Source | Proposed DIRT fields / artifact | Evidence limit |
|---|---|---|
| Historical Architecture at c6553a0: new/next/operate/furnish/pass/name | start.standing; operation; event actor/labor/for; dependencies; ancestry; exact relations; from/from_after; stations; passages; names | Full witness evaluated in expected JSON; no measured timing or CH settings. |
| Current Architecture versions/restore; Architecture.Store; ArchitectureLive.consequence | adapter/version; run UUID; expected revision; durable acceptance boundary | Historical profile read-only now. Current code is not a replay implementation. |
| Motor new/restore/operate/projection; Motor.Store; MotorLive.apply_operation | extents, next, landing, receipts; resolved target and acceptance context; config/rate/NAV quantum | Current snapshots omit complete chronology and transient guards. |
| Instrumentation new/restore/available?/operate; Instrumentation.Store; InstrumentationLive.operate | station/rail/bearing registry; selected/previous/result seat; acceptance evidence | Saved state has no historical event stream. |
| Architecture.PullWitness.build | raw measurements, derived values, units, affects_standing=false, algorithm ID | Different witness, attendant measurement only. |
| TupleShipFieldLive CH surface; ComingAboardAppliance new/configure | Human identity/naming context where used; separate appliance config namespace bugs/restep/input | No source-backed config bridge to rail or Motor. |
| CanonicalTupleLive positions 2/3; canonical_tuple_positions.md | Tuple Rail source registry and proposition provenance | Text does not appoint a common metric transform. |
| InscriptionResolution; RailRecovery; workshop rail recovery report | letter endpoint/predecessor/order; source purchases; frame/roll candidate/status | Metric embedding/handedness/common registration unresolved. |
| PairedMotor new/operate/model/identities/arcs; StringRibbonLive mount | revision/action/q/phase/events; trial footing identity; zero index; separate material roles | In-memory rehearsal, no protected operation or saved run. |
| StringRibbonGeometry triangles/objects; ComingAboardMachine registration/transforms | hinge endpoints; oriented triangle IDs; HERE/NEXT; coordinate frames; source transform; projection reference | Registered diagnostic geometry; physical fit/clearance still unproved. |

## Smallest authorized-later build and proof

Implement only the Spindle witness adapter, transactional recorder for a new explicitly labeled witness run, CSV export/import validator, and isolated DIRT Regarding panel with optional Stage entry. Configuration `ch0` is immutable and explicit. Do not integrate physical acquisition, workshop gearing, cross-machine identities, arbitrary source execution or missing historical event recovery. Keep Motor/Instrumentation/Paired comparisons as design requirements for later profiles.

Acceptance demonstration: create fresh witness → capture initial givens → run all eight actions with save/reload at Third, seat and STEP → export ten-row CSV → validate in dry run → review → mount separate Regarding → visit initial, every event, Third, seated and STEP. Compare entire standing at each frame with expected JSON, configuration ch0 at every event, four identical locality IDs, all relation IDs/provenance, source/destination temporal identities and final FROM. Verify source run is unchanged by cursor and closure. Export imported run's canonical data and compare with original canonical succession (session presentation metadata excluded).

Required later tests: stale concurrent STEP and duplicate command each yield exactly one passage/entry; injected entry-insert failure leaves prior standing; unsupported adapter/missing config/bearing/relation reject; damaged and resealed semantic tampering reject; no mount on partial validity; provisional rehearsal records reconstruct with zero acquired turns. The first build must pass these before claiming the full round trip is implemented.

Design verification performed now: historical pure reducer evaluated for all eight actions; CSV parse, chain/state/event comparisons and damaged hash rejection checked using temporary inspection scripts. These are fixture checks, not an importer. `mix precommit` passed: compilation with warnings as errors, formatting, and 254 tests with zero failures and one skipped. No application feature was added. Existing workspace changes were present before this inspection; this commission adds only `docs/dirt-design/`.
