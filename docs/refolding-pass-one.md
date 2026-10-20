# RE-FOLD / consequential Standing — Pass One

Branch: experiment/consequential-standing-refold
Starting checkpoint: 22b0321eab8aae4bc6a571dd659de26178e206bb

Open /experiments/refolding. The generated URL carries an opaque BY-WAY-OF
key; reopening that URL reconstructs the consequential record.

## Representation

Refolding.Standing contains FROM, material keyed by Standing, the most recent
consequence (operation and FROM/TO relation), and BY-WAY-OF. ENZO is the
stipulated initial Standing. Only explicit ZIPPERING or RE-ZIPPERING changes
FROM. Furnishing a leaf changes material at HUCKLEBERRY, not its consequence.

Refolding.Apparatus contains disposable TOWARD, Regarding, approached Standing,
and Segmentationing index. Refolding.Proof owns gesture interpretation.
RE-FOLD relinquishes the apparatus. Return loads Standing and constructs a
fresh apparatus Regarding FROM, where the material may again be Regarded.
It does not restore a viewport or replay interactions.

One Caterpillar component renders catalogue data for either Standing. There
are no named Standing components or per-Standing unfolding flags.

## Persistence

Refolding.Store defines a replaceable contract for atomic Standing transactions.
MemoryStore is a supervised GenServer storing only Standing records. Transactions
use the latest record, so stale apparatuses cannot overwrite consequence or
material. It survives LiveView termination/remount but is deliberately volatile:
application/store restart loses records. Keys/records have no expiry in this
bounded spike. This is not a durable identity or authenticated account system.

## Demonstration

1. Start FROM ENZO; furnish HUCKLEBERRY TOWARD.
2. Regard, approach and traverse. FROM remains ENZO.
3. ZIPPER HUCKLEBERRY; furnish its small leaf.
4. Furnish ENZO TOWARD and traverse, visibly changing the apparatus.
5. RE-FOLD; return. HUCKLEBERRY is FROM, its leaf remains, and the
   apparatus freshly Regards HUCKLEBERRY at Segmentationing index zero.
6. Reload the generated URL to demonstrate reconstruction after remount.

## Validation and isolation

Domain tests cover the seven requested propositions, explicit RE-ZIPPERING,
invalid/folded gestures, and stale apparatus activity. LiveView tests exercise
both catalogue entries, all ephemeral gestures, consequence, material, RE-FOLD,
return, remount, and the generated return URL.

mix precommit: 47 tests, zero failures, one skipped existing test.
The original TupleShipFieldLive, its route and ParkingingStandRegistry are untouched.
No migration or additional dependency was introduced.

The shared layout requires active_locality and includes the existing site navigation;
the experiment supplies its own locality value. No existing story state or
registry identity was needed. The only integration changes are supervision
of the isolated store and the new experimental route.
