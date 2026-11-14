defmodule PublicSituationMachineTurnZero.Workshop.PairedMotor do
  # Geometry reconciliation: Straight [t,t,t] is a failing control, not coiling UNDER FROM WITHIN; rehearsal events grant no acquired extent.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  # Diagonal B addendum: the YT prefix is a diagnostic trial, not furnished continuation of the current turn.
  # Authority: docs/architecture/geometry/diagonals-pillar.md (R20).
  @moduledoc "Additive, non-acquiring paired-triangle diagnostic. No protected operations are executed."
  alias PublicSituationMachineTurnZero.Workshop.StringRibbonGeometry

  def new do
    %{revision: 0, phase: :staged, q: 0.0, footings: [], events: [], index: 0, return_path: []}
  end

  def operate(s, revision, action) when revision == s.revision do
    result =
      case {s.phase, action} do
        {_, {:progress, q}} when is_number(q) and q >= 0 and q <= 1 ->
          {:ok, %{s | q: q}}

        {:staged, :ground} ->
          n = length(s.footings)

          f = %{
            id: "trial-footing-#{n + 1}",
            entrance: point(n),
            orientation: [1, 0, 1],
            ground: :rehearsed,
            extent: :pending,
            cob_ground: "trial-footing-#{n + 1}",
            craft_ground: "trial-footing-#{n + 1}",
            constitutional?: false
          }

          {:ok, %{s | phase: :ground, footings: s.footings ++ [f]}}

        {:ground, :pending_un_buttoning} ->
          {:ok, %{s | phase: :returning}}

        {:returning, :furnish_return} when s.q == 1.0 ->
          # Append a consequence; never rewrite the earlier Ground record.
          {:ok, %{s | phase: :extent}}

        {:extent, :next} ->
          {:ok, %{s | phase: :staged, q: 0.0}}

        {:extent, :return_first} ->
          path = Enum.map((length(s.footings) - 1)..0//-1, &point/1)
          {:ok, %{s | return_path: path}}

        _ ->
          {:error, :prerequisite}
      end

    case result do
      {:ok, next} ->
        event = %{
          sequence: s.revision + 1,
          action: action,
          footing: length(next.footings),
          index: 0
        }

        {:ok, %{next | revision: s.revision + 1, events: s.events ++ [event]}}

      error ->
        error
    end
  end

  def operate(_, _, _), do: {:error, :stale}
  def point(t), do: [t, t, t]
  def on_plane?([x, _, z]), do: abs(x - z) < 1.0e-9

  def identities(cargo) do
    %{
      cargo: cargo,
      ribbon: "#{cargo}:ribbon",
      road: "#{cargo}:road",
      string: "#{cargo}:bobbining",
      rail: "#{cargo}:rail",
      pinning: "#{cargo}:pinning",
      yt: "#{cargo}:yt-course"
    }
  end

  def model(s) do
    [outgoing, retained] = StringRibbonGeometry.triangles(s.q)
    # Reflect the moving tip across Ground for the reciprocal diagnostic fold.
    # Both halves share the original diagonal hinge. This is a hypothesis, not a recovered gearing law.
    [a, tip, b, _] = outgoing.points
    [x, y, z] = tip
    reciprocal = [a, [z, -y, x], b, a]
    n = length(s.footings)
    course = Enum.map(0..(max(n, 1) * 16), &point(&1 / 16))
    fashioned = StringRibbonGeometry.prefix(course, s.q)

    members = [
      %{name: "XT TO XT", points: [point(0), point(1 / :math.sqrt(3))], q: s.q},
      %{name: "XT TOWARD YT", points: outgoing.points, q: s.q},
      %{name: "YT TOWARD YT", points: fashioned, q: s.q},
      %{name: "YT TOWARD XT", points: reciprocal, q: s.q}
    ]

    %{
      members: members,
      accounting: %{
        retained: StringRibbonGeometry.length_of(course),
        newly_shown: StringRibbonGeometry.length_of(fashioned),
        supply: "Explicit diagnostic centerline extension; not conserved Road proof"
      },
      hinges: [[a, b], [a, b]],
      retained: retained.points,
      plane: %{normal: [1, 0, -1], offset: 0},
      course: course,
      next_outgoing: [List.last(course), point(max(n, 1) + 1)],
      pinning: %{holder: "ONE COB", endpoint: point(n), line: [point(0), point(n)]},
      here: cube([-3, 0, -3]),
      next: cube([3, 0, 3]),
      failures: [
        "Reciprocal fold is a trial reflection; gearing and twist are unproved.",
        "Straight succession is a continuity control, not the SIX arc or a furnished tunnel.",
        "PITTONING, solid clearance, ceiling passage and real RE-ZIPPERING remain unproved.",
        "Return follows the centerline only; occupied COB clearance and AROUND ABOUT turning are unproved.",
        "RailRecovery axle/Table collisions remain unresolved; no acquired index advances."
      ]
    }
  end

  def arcs do
    for n <- [4, 6, 8] do
      r = 1.5 * n / 6

      %{
        reference: n,
        radius: r,
        points:
          for(
            i <- 0..24,
            do: [
              0,
              r * :math.sin(i / 24 * :math.pi() / 2),
              r * :math.cos(i / 24 * :math.pi() / 2)
            ]
          )
      }
    end
  end

  def cube([x, y, z]) do
    corners = for dx <- [0, 6], dy <- [0, 6], dz <- [0, 6], do: [x + dx, y + dy, z + dz]

    for {a, i} <- Enum.with_index(corners),
        {b, j} <- Enum.with_index(corners),
        i < j,
        Enum.count(Enum.zip(a, b), fn {u, v} -> u != v end) == 1,
        do: [a, b]
  end

  def project(points, :side),
    do: Enum.map_join(points, " ", fn [x, y, z] -> "#{50 + (x + z) * 18},#{260 - y * 27}" end)

  def project(points, :within) do
    # One fixed perspective eye, looking along the common diagonal; never generates new geometry.
    Enum.map_join(points, " ", fn [x, y, z] ->
      depth = max(0.5, 10 + (x + z) / :math.sqrt(2))
      "#{240 + (x - z) * 180 / depth},#{230 - (y - 1) * 180 / depth}"
    end)
  end
end
