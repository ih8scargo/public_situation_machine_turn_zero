defmodule PublicSituationMachineTurnZero.Workshop.MaterialRibbon do
  # R25/R26: HERE wedging / seated ONE / Snail THROUGH SIX registration is required.
  # Missing physical source correspondence is not optional architecture; see docs/architecture/geometry/here-wedging-snail-six.md.
  # Geometry reconciliation: A04 comparison placement and endpoint clearance are trials, not canonical Seat/Table fit or physical return.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc "Deterministic occupied Ribbon trials. Frame registration is explicit; no acquisition authority."
  alias PublicSituationMachineTurnZero.Architecture.InscriptionResolution

  alias PublicSituationMachineTurnZero.Workshop.{
    Calibration,
    PairedMotor,
    RailRecovery,
    Steeling,
    StringRibbonGeometry
  }

  @version "material-ribbon-trial-v1"
  @views ~w(flat backstage gallery through along side)
  @pieces ~w(outgoing retained reciprocal rail)
  @references ~w(SIX FOUR EIGHT Rail COB return-line)
  def version, do: @version
  def views, do: @views
  def pieces, do: @pieces
  def references, do: @references

  def new do
    %{
      revision: 0,
      q: 0.0,
      hand: 1,
      thickness: 0.04,
      view: "gallery",
      selected: "outgoing",
      gauges?: true,
      inscriptions?: true,
      obstacle?: false,
      appointments: %{},
      events: [],
      last_attempt: nil,
      notice: nil,
      index: 0
    }
  end

  def operate(s, revision, command) when revision == s.revision and s.revision < 200 do
    case change(s, command) do
      {:ok, next, kind, result} ->
        event = %{
          sequence: s.revision + 1,
          kind: kind,
          command: command,
          result: result,
          algorithm: @version,
          frame: "motor-extent-v1",
          unit: "trial extent",
          inherited: %{q: s.q, hand: s.hand, thickness: s.thickness},
          effective_configuration: %{
            obstacle: next.obstacle?,
            thickness: next.thickness,
            hand: next.hand
          },
          proposed: command,
          resulting: %{q: next.q, hand: next.hand},
          material_ids: [
            "archway:outgoing",
            "archway:retained",
            "archway:reciprocal",
            "ribbon-source-25"
          ],
          prepositionings: [
            %{
              subject: "candidate Ribbon",
              relation: "THROUGH-BY",
              object: "inherited-diagonal-A-B",
              status: :trial
            }
          ],
          source_versions: [
            "StringRibbonGeometry.triangles/1",
            "inscription-resolution-v1",
            "A04 calibration-v1"
          ],
          appointments: next.appointments,
          status: :rehearsal,
          acquired_turn_delta: 0
        }

        {:ok, %{next | revision: s.revision + 1, events: s.events ++ [event]}}

      error ->
        error
    end
  end

  def operate(_, _, _), do: {:error, :stale_or_limit}

  defp change(s, {:view, view}) when view in @views,
    do: {:ok, %{s | view: view}, :regarding, :accepted}

  defp change(s, {:select, id}) when id in @pieces,
    do: {:ok, %{s | selected: id}, :selection, :accepted}

  defp change(s, {:toggle, key}) when key in [:gauges?, :inscriptions?, :obstacle?],
    do: {:ok, Map.update!(s, key, &(!&1)), :reference_configuration, :accepted}

  defp change(s, {:hand, hand}) when hand in [-1, 1],
    do: {:ok, %{s | hand: hand}, :material_candidate, :unappointed_handedness}

  defp change(s, {:appoint, reference, text}) when reference in @references and is_binary(text) do
    if String.trim(text) != "" and byte_size(text) <= 160,
      do:
        {:ok, %{s | appointments: Map.put(s.appointments, reference, text)}, :human_inscription,
         :accepted},
      else: {:error, :marking_required}
  end

  defp change(s, {:fold, q}) when is_number(q) and q >= 0 and q <= 1 do
    candidate = prism("outgoing", triangle(q, :outgoing), s.thickness)
    blocked = s.obstacle? and collision?(candidate, obstacle())

    next = %{
      s
      | last_attempt: q,
        notice:
          if(blocked,
            do:
              "BLOCKED: outgoing occupied face intersects clearance-stop solid. Current fold retained.",
            else:
              "Candidate fold retained. Hinge contact, gearing and occupied tunnel clearance remain unproved."
          )
    }

    {:ok, if(blocked, do: next, else: %{next | q: q}), :material_candidate,
     if(blocked, do: :blocked_clearance_stop, else: :accepted_trial)}
  end

  defp change(_, _), do: {:error, :unsupported_operation}

  # Explicit comparison placement: source U13 is origin; -45° about +Y maps source XY
  # to the invariant motor plane x=z. This is reversible registration, not calibrated fit.
  def transform([x, y, z], "steeling-u13-to-motor-v1") do
    c = :math.sqrt(0.5)
    {:ok, [(x - 15 - z) * c, y - 3, (x - 15 + z) * c]}
  end

  def transform([x, y, z], "motor-to-steeling-u13-v1") do
    c = :math.sqrt(0.5)
    {:ok, [15 + (x + z) * c, y + 3, (z - x) * c]}
  end

  def transform(_, _), do: {:error, :unsupported_frame_correspondence}

  def registration do
    %{
      id: "steeling-u13-to-motor-v1",
      source: "Steeling.defaults/0; model/1; U13",
      from: "steeling-xy-v1",
      to: "motor-extent-v1",
      source_origin: [15, 3, 0],
      rotation_y_degrees: -45,
      convention: "counterclockwise looking UP +Y; right-handed axes",
      scale: 1,
      unit: "trial extent",
      status: :comparison_placement,
      physical_fit: :unproved,
      plane: %{normal: [1, 0, -1], offset: 0}
    }
  end

  def triangle(q, kind) do
    [outgoing, retained] = StringRibbonGeometry.triangles(q)
    [a, tip, b, _] = outgoing.points

    case kind do
      :outgoing ->
        [a, tip, b]

      :retained ->
        Enum.take(retained.points, 3)

      :reciprocal ->
        [x, y, z] = tip
        [a, [z, -y, x], b]
    end
  end

  def prism(id, [a, b, c] = points, thickness) do
    normal = unit(cross(sub(b, a), sub(c, a)))
    top = Enum.map(points, &add(&1, scale(normal, thickness / 2)))
    bottom = Enum.map(points, &add(&1, scale(normal, -thickness / 2)))
    vertices = top ++ bottom
    indices = [[0, 1, 2], [5, 4, 3], [0, 3, 4, 1], [1, 4, 5, 2], [2, 5, 3, 0]]
    faces = Enum.map(indices, fn face -> Enum.map(face, &Enum.at(vertices, &1)) end)

    %{
      id: id,
      material_id: "archway:" <> id,
      points: points,
      vertices: vertices,
      faces: faces,
      normal: normal,
      thickness: thickness,
      width: 6,
      area: norm(cross(sub(b, a), sub(c, a))) / 2,
      lengths: [distance(a, b), distance(b, c), distance(c, a)],
      hinge: %{id: "inherited-diagonal-A-B", endpoints: [a, c], ordering: "A TOWARD B"},
      source: "StringRibbonGeometry.triangles/1; normalized archway fold",
      status: if(id == "reciprocal", do: :reflected_trial_gearing_unproved, else: :material_trial)
    }
  end

  def obstacle do
    center = [0, :math.sqrt(2), 0]

    vertices =
      for x <- [-0.22, 0.22], y <- [-0.22, 0.22], z <- [-0.22, 0.22], do: add(center, [x, y, z])

    faces =
      for indices <- [
            [0, 1, 3, 2],
            [4, 6, 7, 5],
            [0, 4, 5, 1],
            [2, 3, 7, 6],
            [0, 2, 6, 4],
            [1, 5, 7, 3]
          ],
          do: Enum.map(indices, &Enum.at(vertices, &1))

    %{id: "clearance-stop", vertices: vertices, faces: faces}
  end

  # Separating-axis test for convex prisms/box, including edge cross-products.
  # Touch is allowed within epsilon; this does not solve shared finite hinge design.
  def collision?(a, b) do
    axes =
      normals(a.faces) ++
        normals(b.faces) ++ for(e <- edges(a.faces), f <- edges(b.faces), do: cross(e, f))

    axes
    |> Enum.filter(&(norm(&1) > 1.0e-9))
    |> Enum.all?(fn axis ->
      {amin, amax} = a.vertices |> Enum.map(&dot(&1, axis)) |> Enum.min_max()
      {bmin, bmax} = b.vertices |> Enum.map(&dot(&1, axis)) |> Enum.min_max()
      min(amax, bmax) - max(amin, bmin) > 1.0e-9
    end)
  end

  defp normals(faces), do: Enum.map(faces, fn [a, b, c | _] -> cross(sub(b, a), sub(c, a)) end)

  defp edges(faces),
    do:
      Enum.flat_map(faces, fn points ->
        Enum.map(Enum.chunk_every(points ++ [hd(points)], 2, 1, :discard), fn [a, b] ->
          sub(b, a)
        end)
      end)

  def rail_register(hand) do
    square = Steeling.model(Steeling.defaults())
    source = InscriptionResolution.model()
    candidate = RailRecovery.ribbon(source, hand)

    links =
      Enum.zip_with(square["stations"], source["letters"], fn station, letter ->
        %{
          id: "ordinal-link-#{station["index"]}",
          square: station,
          curved: letter["id"],
          curved_midpoint: Enum.at(letter["samples"], 4)["point"],
          basis: "shared inscription ordinal/word; not a physical metric transform"
        }
      end)

    %{
      square: square,
      source: source,
      ribbon: candidate,
      links: links,
      n18_boundary: RailRecovery.source_sample(source, 18),
      n18_center: RailRecovery.source_sample(source, 17.5),
      m19_center: RailRecovery.source_sample(source, 18.5),
      source_to_motor: nil,
      correspondence: :ordinal_only
    }
  end

  def gauges do
    # Exact A04 analytic definitions, retaining its translation and both axis alternatives.
    for axis <- ["x", "z"], label <- [4, 6, 8] do
      r = Calibration.defaults()["radius"] * label / 6

      points =
        for i <- 0..24 do
          angle = i / 24 * :math.pi() / 2

          source =
            if axis == "x",
              do: [15, r * :math.sin(angle), r * :math.cos(angle)],
              else: [15 + r * :math.cos(angle), r * :math.sin(angle), 0]

          {:ok, point} = transform(source, "steeling-u13-to-motor-v1")
          point
        end

      %{
        id: "gauge-#{label}-#{axis}",
        label: label,
        axis: axis,
        radius: r,
        points: points,
        source: "Assignment 04 / Calibration.arc; pivot [15,0,0]",
        role: :reference_not_trajectory
      }
    end
  end

  def return_register do
    square = Steeling.model(Steeling.defaults())
    n = square["n_return"]
    source_points = [n["point"], square["u_return"]["point"], [15, 2.5, -1.5], [15, 0, -1.5]]

    points =
      Enum.map(source_points, fn p ->
        {:ok, q} = transform(p, "steeling-u13-to-motor-v1")
        q
      end)

    %{
      id: "cob-return-from-N18",
      subject: "COB",
      relation: "FROM N18 THROUGH Projectioning Crossing TOWARD HERE",
      object: "A04-HERE",
      inherited: ["n-ground-return", "machine-from-n", "u-projection-return"],
      source_points: source_points,
      points: points,
      incoming: n["situation_incoming"],
      n_return: n,
      machine: square["machine"],
      status: :waypoint_trial,
      unresolved:
        "Segment incidence at aperture, PENDING UN-BUTTONING twist coupling, occupied COB clearance and retained doorway passage unproved"
    }
  end

  def aperture do
    # Reuse A04 toe-fixed mechanical boundary; beta=45 stays separate from yaw=-45.
    a = [14.8, 0, 0]
    b = [15.2, 0, 0]
    angle = 45 * :math.pi() / 180
    offset = [0, 0.8 * :math.sin(angle), 0.8 * :math.cos(angle)]
    source = [a, b, add(b, offset), add(a, offset)]

    %{
      id: "a04-toe-aperture",
      source_points: source,
      points:
        Enum.map(source, fn p ->
          {:ok, q} = transform(p, "steeling-u13-to-motor-v1")
          q
        end),
      source: "Calibration.registry/2: toe line 14.8..15.2, opening beta=45 degrees",
      opening_degrees: 45,
      pivot_degrees: -45,
      curvature: :not_created_by_rigid_pivot,
      optical_transfer: :unproved
    }
  end

  def crossing do
    outer =
      for {dx, dy} <- [{-1.2, -1.2}, {1.2, -1.2}, {1.2, 1.2}, {-1.2, 1.2}],
          do: [15 + dx, 3 + dy, 0]

    inner =
      for {dx, dy} <- [{-0.6, -0.6}, {0.6, -0.6}, {0.6, 0.6}, {-0.6, 0.6}],
          do: [15 + dx, 3 + dy, 0]

    ray = [[15, 2.5, -1.5], [15, 3, -2]]

    objects =
      for {id, points} <- [
            {"u-outer", outer},
            {"u-within-u", inner},
            {"pretend-projector-ray", ray}
          ] do
        %{
          id: id,
          source_points: points,
          points:
            Enum.map(points, fn p ->
              {:ok, q} = transform(p, "steeling-u13-to-motor-v1")
              q
            end)
        }
      end

    %{
      objects: objects,
      source: "Calibration.registry/2; U13 locked +Z; beta=45",
      ray_hit: [15, 3, -2],
      aperture_incidence: :coplanar_arrival_at_U13_not_transverse_passage,
      optical_curvature: :unproved,
      pivot_convention: registration().convention
    }
  end

  def model(s, motor, cargo \\ nil) do
    rail = rail_register(s.hand)

    pieces =
      for {id, kind} <- [
            {"outgoing", :outgoing},
            {"retained", :retained},
            {"reciprocal", :reciprocal}
          ],
          do: prism(id, triangle(s.q, kind), s.thickness)

    footings =
      Enum.map(motor.footings, fn f ->
        {:ok,
         Map.merge(f, %{
           door_id: f.id <> ":entrance",
           points: doorway(f.entrance),
           frame: "motor-extent-v1"
         })}
      end)
      |> Enum.map(fn {:ok, f} -> f end)

    %{
      version: @version,
      pieces: pieces,
      rail: rail,
      gauges: gauges(),
      return: return_register(),
      aperture: aperture(),
      crossing: crossing(),
      registration: registration(),
      identities: PairedMotor.identities(cargo || "unprovided-trial"),
      footings: footings,
      bar: [PairedMotor.point(0), PairedMotor.point(1 / :math.sqrt(3))],
      straight_control: PairedMotor.model(motor).course,
      obstacle: obstacle(),
      failures: [
        "Straight control has no width, thickness, enclosing faces, N18 connection or retained material supply.",
        "Finite shared-hinge solids need bevel/knuckle design; no whole-fold clearance certified.",
        "Rail square/curve correspondence is ordinal; a physical source-to-motor transform is not appointed.",
        "Needle surrender and bobbin gathering are inherited operations; RE-ZIPPERING supply/attachment is not mechanically connected.",
        "Reference curvature does not prescribe the COB course; ceiling and occupied return remain separate proofs."
      ],
      acquired_turns: 0
    }
  end

  def doorway(center) do
    across = [3 * :math.sqrt(0.5), 0, -3 * :math.sqrt(0.5)]

    for {side, height} <- [{-1, 0}, {1, 0}, {1, 6}, {-1, 6}],
        do: add(center, add(scale(across, side), [0, height, 0]))
  end

  # Orthographic cameras: all regard unchanged world points. No geometry branch by view.
  def project(points, view, scale \\ 24, origin \\ [250, 235]) do
    {right, up} = camera(view)
    [ox, oy] = origin

    Enum.map_join(points, " ", fn p ->
      "#{ox + dot(p, right) * scale},#{oy - dot(p, up) * scale}"
    end)
  end

  def camera("flat"), do: {[1, 0, 0], [0, 1, 0]}
  def camera("backstage"), do: {[-1, 0, 0], [0, 1, 0]}
  def camera("gallery"), do: {[0.8660254, 0, -0.5], [0.25, 0.8660254, 0.4330127]}
  def camera("through"), do: {[-0.70710678, 0, 0.70710678], [0, 1, 0]}
  def camera("along"), do: {[-0.70710678, 0, 0.70710678], [-0.5, 0.70710678, -0.5]}
  def camera("side"), do: {[0.70710678, 0, 0.70710678], [0, 1, 0]}
  def distance(a, b), do: norm(sub(a, b))
  def add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  def sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  def scale(a, s), do: Enum.map(a, &(&1 * s))
  def dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  def cross([a, b, c], [x, y, z]), do: [b * z - c * y, c * x - a * z, a * y - b * x]
  def norm(a), do: :math.sqrt(dot(a, a))
  def unit(a), do: scale(a, 1 / norm(a))
end
