defmodule PublicSituationMachineTurnZero.Workshop.RailRecovery do
  # Geometry reconciliation: Roll and source/Gallery overlay remain candidates; revised acquisition/return requires finite material witnesses.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc """
  Engineering recovery candidates. Source letter samples are retained exactly.
  No acquisition API, durable turn state, or source-to-Gallery metric is supplied.
  Trial occupied profiles are explicit; none appoints a constitutional mounting.
  """
  alias PublicSituationMachineTurnZero.Architecture.InscriptionResolution
  alias PublicSituationMachineTurnZero.Workshop.WedgingGeometry

  @edges [
    {0, 1},
    {0, 2},
    {0, 4},
    {1, 3},
    {1, 5},
    {2, 3},
    {2, 6},
    {3, 7},
    {4, 5},
    {4, 6},
    {5, 7},
    {6, 7}
  ]
  def edges, do: @edges

  def model(hand \\ 1) when hand in [-1, 1] do
    source = InscriptionResolution.model()
    letters = Enum.map(source["letters"], &letter/1)
    ribbon = ribbon(source, hand)
    apparatus = apparatus()

    %{
      version: "rail-recovery-candidate-1",
      authority: :engineering_only,
      source: source,
      letters: letters,
      ribbon: ribbon,
      apparatus: apparatus,
      gallery: Enum.map(WedgingGeometry.outline(), fn {x, z} -> [x, 0, z] end),
      source_to_gallery: nil,
      constitutional_handedness: nil,
      fixed: %{
        ground: %{normal: [0, 1, 0], offset: 0},
        here: [0, 0, 0],
        next: [0, 0, 6],
        table: %{center: [0, 0, 0], diameter: 3, moving: false},
        frame_status: "candidate common frame; old source transforms unappointed",
        discrete_turn: %{source: "Workshop.turn.anchored", advance: :unavailable}
      },
      pointer: %{
        id: "engineering-pointer-N18",
        from: Enum.at(letters, 17).center,
        toward: [0, 0, 0],
        material: ribbon.id,
        support: "wedging-N18-M19",
        turn: "engineering-witness-only; no constitutional turn issued",
        authority: :withheld
      },
      corner: %{
        angle_degrees: 90,
        origin: [0, 0, 0],
        incoming: [-1, 0, 0],
        outgoing: [0, 0, 1],
        status: "indexed bearing fixture only; cannot overwrite existing curved THE/PUBLIC source"
      },
      collisions: collisions(apparatus),
      blockers: [
        "A: 25 identities recovered, but source intervals are not metric one-extent CUBICALs; unit occupied candidates overlap.",
        "A: THE/PUBLIC source remains curved. A 90-degree fixture is independent; placement awaits rail registration.",
        "A: Ground/HERE/NEXT and apparatus use a candidate frame; older Snail/Gallery metric transforms remain unappointed.",
        "A: Six-unit UP and DOWN reservations do not furnish the UN-FOLDING hinge transform.",
        "B: N/M twist follows the existing trial curve exactly, not a verified Gallery passage; neither handedness is appointed.",
        "C: Centered solid COB stand and square axle collide; no bore or offset has been invented.",
        "C: Loading Deck Z=1.45, inbound PITTONING/radial hits and aperture containment remain inherited failures, not cleared by this model.",
        "E: Physical gear placement is a candidate; coupling, RE-STEP gate and material payout remain unfurnished.",
        "FIVE/SIX return and closure remain yellow. No loop closure, new letter, or new turn."
      ]
    }
  end

  defp letter(l) do
    sample = Enum.at(l["samples"], 4)
    t = unit(sample["tangent"])
    across = unit(sub(List.last(sample["edges"]), hd(sample["edges"])))
    normal = unit(cross(t, across))

    %{
      id: l["id"],
      ordinal: l["index"],
      letter: l["letter"],
      word: l["word"],
      center: sample["point"],
      tangent: t,
      across: across,
      normal: normal,
      predecessor: if(l["index"] > 1, do: "inscription-letter-#{l["index"] - 1}"),
      successor: if(l["index"] < 25, do: "inscription-letter-#{l["index"] + 1}"),
      points: box(sample["point"], [t, across, normal], [0.5, 0.5, 0.5]),
      provenance:
        "InscriptionResolution trial source; bounded unit candidate, not acquired extent",
      status: :metric_registration_blocked
    }
  end

  # Interpolate only between the original source samples. Neither curve nor order
  # is refitted to suit the ribbon. The complete original source is also retained.
  def source_sample(source, p) when p >= 0 and p <= 25 do
    samples =
      source["letters"] |> Enum.flat_map(& &1["samples"]) |> Enum.uniq_by(& &1["purchase"])

    a = Enum.find(Enum.reverse(samples), &(&1["purchase"] <= p))
    b = Enum.find(samples, &(&1["purchase"] >= p))
    f = if a == b, do: 0, else: (p - a["purchase"]) / (b["purchase"] - a["purchase"])
    %{point: lerp(a["point"], b["point"], f), tangent: unit(lerp(a["tangent"], b["tangent"], f))}
  end

  def ribbon(source, hand) do
    samples = Enum.map(0..200, &source_sample(source, 25 * &1 / 200))

    {frames, _} =
      Enum.map_reduce(Enum.with_index(samples), nil, fn {s, i}, prev ->
        base = if prev, do: transport(prev.base, prev.tangent, s.tangent), else: [0.0, 1.0, 0.0]
        p = i / 8
        f = max(0, min(1, p - 17.5))
        angle = hand * :math.pi() * f * f * (3 - 2 * f)
        across = rotate(base, s.tangent, angle)
        normal = unit(cross(s.tangent, across))

        frame =
          Map.merge(s, %{
            purchase: p,
            base: base,
            across: across,
            normal: normal,
            roll: angle,
            left: add(s.point, scale(across, -0.18)),
            right: add(s.point, scale(across, 0.18))
          })

        {frame, frame}
      end)

    faces =
      Enum.map(Enum.chunk_every(frames, 2, 1, :discard), fn [a, b] ->
        %{
          points: [a.left, a.right, b.right, b.left],
          back: [
            add(a.left, scale(a.normal, -0.02)),
            add(a.right, scale(a.normal, -0.02)),
            add(b.right, scale(b.normal, -0.02)),
            add(b.left, scale(b.normal, -0.02))
          ],
          from: a.purchase,
          to: b.purchase,
          material: "ribbon-source-25",
          support: "wedging-#{a.purchase}-#{b.purchase}",
          support_points:
            for(
              f <- [a, b],
              side <- [-1, 1],
              depth <- [-0.10, -0.02],
              do: f.point |> add(scale(f.across, side * 0.23)) |> add(scale(f.normal, depth))
            )
        }
      end)

    twist = Enum.filter(frames, &(&1.purchase >= 17.5 and &1.purchase <= 18.5))
    boundary = Enum.map(WedgingGeometry.outline(), fn {x, z} -> [x, 0, z] end)

    margins =
      for f <- Enum.filter(faces, &(&1.from >= 17.5 and &1.to <= 18.5)),
          p <- f.support_points,
          do: gallery_margin(p, boundary)

    %{
      id: "ribbon-source-25",
      head: "inscription-letter-1",
      tail: "inscription-letter-25",
      handedness_candidate: hand,
      appointed_handedness: nil,
      frames: frames,
      faces: faces,
      twist: twist,
      twist_range: [17.5, 18.5],
      magnitude_degrees: 180,
      thickness_candidate: 0.02,
      support_half_width_candidate: 0.23,
      source:
        "InscriptionResolution original samples, piecewise-linear interpolation; no curve refit",
      provenance: "engineering material witness; not PINNING or acquired ribbon",
      clearance: %{
        minimum_identity_overlay_gallery_margin: Enum.min(margins),
        status: :unqualified,
        reason:
          "identity-overlay trial only: source-to-Gallery transform and occupied passage unregistered",
        self_intersection: :not_certified,
        support_contact: :intended,
        twist_strain: :not_certified,
        closed: false
      }
    }
  end

  defp gallery_margin(p, boundary) do
    Enum.chunk_every(boundary ++ [hd(boundary)], 2, 1, :discard)
    |> Enum.map(fn [[x, _, z], [a, _, b]] ->
      [px, _, pz] = p

      ((a - x) * (pz - z) - (b - z) * (px - x)) /
        :math.sqrt((a - x) * (a - x) + (b - z) * (b - z))
    end)
    |> Enum.min()
  end

  # Rotation-minimizing transport, separated from the material's explicit roll.
  def transport(v, a, b) do
    axis = cross(a, b)

    if norm(axis) < 1.0e-10 do
      v
    else
      rotate(v, unit(axis), :math.atan2(norm(axis), dot(a, b))) |> unit()
    end
  end

  def rotate(v, axis, angle),
    do:
      add(
        add(scale(v, :math.cos(angle)), scale(cross(axis, v), :math.sin(angle))),
        scale(axis, dot(axis, v) * (1 - :math.cos(angle)))
      )

  def apparatus do
    specs = [
      {"TC-6", [-8, 3, 0], [3, 3, 3], :reservation},
      {"HERE-6", [0, 3, 0], [3, 3, 3], :reservation},
      {"NEXT-6", [0, 3, 6], [3, 3, 3], :reservation},
      {"DOWN-6", [0, -3, 0], [3, 3, 3], :reservation},
      {"Square-Axle", [0, 0, 0], [0.5, 3, 0.5], :solid_candidate},
      {"COB-stand", [0, 0.5, 0], [0.3, 0.5, 0.3], :solid_candidate},
      {"COB-local-1", [0, 0.5, 0], [0.5, 0.5, 0.5], :reservation},
      {"Spindle", [0.4, 0.3, 0], [0.08, 0.6, 0.08], :solid_candidate},
      {"Steering-passage", [0, 0, 0], [0.2, 0.6, 0.2], :solid_candidate},
      {"Traversal-Seat-TWO", [0, -0.65, -1.5], [0.35, 0.35, 0.35], :solid_candidate},
      {"Monitor-THREE", [0, 0, -0.5], [0.6, 0.45, 0.04], :solid_candidate},
      {"RE-STEP-Wall-FOUR", [0, 0, 0.5], [0.8, 1, 0.05], :solid_candidate},
      {"XT-left-elbow", [-0.75, -0.3, -1.5], [0.3, 0.3, 0.08], :solid_candidate},
      {"YT-below-XT", [-0.75, -1, -1.5], [0.3, 0.3, 0.08], :solid_candidate},
      {"Discrete-index-office", [-0.75, -0.65, -1.5], [0.1, 0.04, 0.08], :reservation},
      {"Slate-Inkwell", [0.6, 0.04, -1], [0.3, 0.08, 0.2], :solid_candidate},
      {"Keyboard", [0, 0.1, -1.2], [0.35, 0.04, 0.12], :solid_candidate},
      {"Needle-return", [0.6, 0.15, -1], [0.02, 0.15, 0.02], :solid_candidate},
      {"TC-Square-Buckle", [-8, 0.5, -2.8], [0.4, 0.4, 0.1], :solid_candidate},
      {"TC-Little-Square-Chair", [-8, 0.3, -3.5], [0.3, 0.3, 0.3], :solid_candidate},
      {"TC-upper-left-door", [-9.5, 4.5, -3], [0.5, 0.6, 0.04], :solid_candidate},
      {"Great-Big-Foot", [0, -0.2, 4], [0.7, 0.2, 1], :solid_candidate}
    ]

    Enum.map(specs, fn {id, c, h, kind} ->
      %{
        id: id,
        center: c,
        half: h,
        kind: kind,
        points: box(c, axes(), h),
        provenance:
          "explicit trial occupied profile in independent recovery frame; mounting unappointed"
      }
    end)
  end

  def collisions(objects) do
    solids = Enum.filter(objects, &(&1.kind == :solid_candidate))

    for {a, i} <- Enum.with_index(solids),
        b <- Enum.drop(solids, i + 1),
        overlap?(a, b),
        do: %{a: a.id, b: b.id, classification: :collision_of_trial_solids}
  end

  defp overlap?(a, b),
    do:
      Enum.zip([a.center, b.center, a.half, b.half])
      |> Enum.all?(fn {x, y, h, k} -> abs(x - y) < h + k - 1.0e-8 end)

  def box(center, axes, half) do
    for x <- [-1, 1], y <- [-1, 1], z <- [-1, 1] do
      Enum.zip([axes, half, [x, y, z]])
      |> Enum.reduce(center, fn {a, h, s}, p -> add(p, scale(a, h * s)) end)
    end
  end

  def axes, do: [[1, 0, 0], [0, 1, 0], [0, 0, 1]]

  def to_world(local, origin, basis),
    do: Enum.zip(basis, local) |> Enum.reduce(origin, fn {b, x}, p -> add(p, scale(b, x)) end)

  def from_world(world, origin, basis), do: Enum.map(basis, &dot(sub(world, origin), &1))
  def add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  def sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  def scale(a, s), do: Enum.map(a, &(&1 * s))
  def dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  def cross([a, b, c], [x, y, z]), do: [b * z - c * y, c * x - a * z, a * y - b * x]
  def norm(a), do: :math.sqrt(dot(a, a))
  def unit(a), do: scale(a, 1 / norm(a))
  def lerp(a, b, f), do: add(scale(a, 1 - f), scale(b, f))
end
