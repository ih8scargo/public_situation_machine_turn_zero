# Inscription resolutioning — first code pass

Source: the Constitutioning Human's supplied scheme, November 3, 2026, in the
Engineering Handoff continuation. Scope: begin implementing the projectioning
through THE PUBLIC SITUATION MACHINE in the existing architecture build.

## Relations supplied by the Human

- THE turns toward PUBLIC: the 3 + 6 bend establishes XT toward XT.
- PUBLIC with SITUATION forms the face standing up XT toward YT. PUBLIC belongs
  to both relations; it is not copied into a second inscription.
- N in SITUATION marks the twist purchase (letter 18 of the 25-letter inscription).
- Return traversaling from YT toward YT comes THROUGH ALONG MACHINE, reaching
  XT toward XT by the end of the turn.

## Implementation

`Architecture.InscriptionResolution` supplies one versioned derived model with
25 stable letter IDs, relation memberships, predecessor references, the N purchase,
and the final bearing. `CrossingRehearsal.model/1` includes it without changing the
stored Standing. Existing appointed stick geometry is not adapted or overwritten.
The old THE/PUBLIC straight indexed course remains recoverable in `indexedCourse`;
when the resolution model is present, the new arcs replace those straight course
marks in the scene. The 25 reference tiles remain references to the inscription.

The domain emits sampled arc coordinates and surface edges. The browser interpolates
those supplied samples and draws the PUBLIC/SITUATION ribbon in the same world as
the existing appliance. No camera creates a different surface or changes its points.
On `/experiments/architecture`, **Follow THE PUBLIC SITUATION MACHINE** moves an
inspection purchase across the inscription. It does not move COB or accomplish
constitutional passage. CAB, alongside, slices and roundabout Regarding continue
to inspect that same world geometry.

## Geometry choices still under review

The first numerical embedding uses three tangent-continuous quarter-circle trial
arcs: THE/PUBLIC together in XZ, SITUATION rising in YZ, and MACHINE returning its
tangent in XY. Radius 1.6 and half-width 0.18 are drawing parameters, not supplied
constitutional measurements. Letters divide each trial span; their counts do not
establish equal physical lengths across different words. The PUBLIC/SITUATION face
is a curved ribbon in this embedding, not a claim that those trial arc planes are
the final resolutioning geometry or the fixed RE-Step Wall.

The frame is continuously transported through N. The model explicitly leaves
physical twist angle and handedness unset: marking the supplied purchase does not
pretend to have implemented its mechanical twist. The final tangent agrees with
the initial tangent, while the endpoint remains spatially distinct. The supplied
XT toward XT end bearing therefore does not silently establish spatial closure,
Landinging exchange, a new FROM or another turn.

## Validation

- Domain checks: unique letters, shared PUBLIC membership, N relation/purchase,
  continuous points/tangents/surface edges, final tangent, and retained FROM,
  events and instrument through JSON restore.
- JavaScript checks: interpolation, boundary handling at N and MACHINE, clamping,
  final bearing, and model immutability.
- Browser check: appointed receipt, full inspection course, N and end readings,
  fixed face points across CAB/alongside/external views, reload, narrow screen,
  finite projected geometry and no browser errors.

Run the existing `mix precommit`, `mix assets.build`, and
`node --test test/js/*.mjs`. The browser runner is
`test/browser/inscription_resolution.mjs`, using the existing `PLAYWRIGHT_MODULE`
convention; optional `CHROMIUM_PATH` and `ZEROETH_URL` select browser and server.
