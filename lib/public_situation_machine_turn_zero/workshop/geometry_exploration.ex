defmodule PublicSituationMachineTurnZero.Workshop.GeometryExploration do
  # R25/R26: HERE wedging / seated ONE / Snail THROUGH SIX registration is required.
  # Missing physical source correspondence is not optional architecture; see docs/architecture/geometry/here-wedging-snail-six.md.
  @moduledoc """
  Geometry RE-surfacing Table exploration. Candidate material is never acquired extent.
  Authority: docs/architecture/geometry/README.md (geometry-table-2026-11-14.v5).
  """
  alias PublicSituationMachineTurnZero.Workshop.MaterialRibbon, as: M
  @version "geometry-table-2026-11-14.v5"
  @mechanism "constant-radius-underfold-v1"
  @views ~w(elevation plan transverse oblique half)
  @experiments [
    "Fundamental registration",
    "Square & triangle",
    "Outward standing",
    "Aperture & underfold",
    "Two-Footing comparison",
    "Emerging Gallery",
    "Flat / Tunnel correspondence",
    "Conditions & return",
    "Three-Footing shared faces",
    "45° bearing registration"
  ]
  @missing [
    :ground_connection,
    :pittoning,
    :restomping,
    :rezippering,
    :completion_confirmation,
    :physical_two_footing_capacity,
    :material_supply,
    :occupied_clearance
  ]
  def version, do: @version
  def experiments, do: @experiments
  def views, do: @views

  def new do
    %{
      revision: 0,
      experiment: 1,
      view: "oblique",
      wedging_trial: "simple",
      wedging_side: "left",
      continuation_overlay?: false,
      frame_status: :unfurnished,
      selected: "diagonal-A",
      hinge: "crossing",
      axis: "x",
      angle: 0,
      coils: [],
      proposal: nil,
      notice: nil,
      events: [],
      condition_lab: fixture_new(),
      staging: PublicSituationMachineTurnZero.Workshop.AlongsideStaging.new(),
      from: "ZERO",
      index: 0,
      ceiling: nil,
      bugs: 1
    }
  end

  def frame do
    %{
      id: "six-frame",
      minimum: [0, 0, 0],
      maximum: [6, 6, 6],
      measure: 6,
      unit: "trial extent",
      ground: 0,
      ceiling: 6,
      minimum_capacity: 2,
      capacity_status: :mechanism_unproved,
      geometry_version: @version,
      actual_footings: []
    }
  end

  def references do
    [
      ref(
        "HERE",
        "THIS HERE APPROACHING LANDINGING",
        [[0, 0, -6], [6, 0, -6], [6, 0, 0], [0, 0, 0]],
        :closed
      ),
      ref(
        "NEXT",
        "THIS NEXT APPROACHING LANDINGING",
        [[0, 0, 0], [6, 0, 0], [6, 0, 6], [0, 0, 6]],
        :closed
      ),
      ref("pillar", "continuous HERE pillar ZERO TO SIX", [[3, 0, -4], [3, 6, -4]], :line),
      ref(
        "seat",
        "Traversaling Seat at ONE",
        [[2.6, 1, -3.4], [3.4, 1, -3.4], [3.4, 1, -2.6], [2.6, 1, -2.6]],
        :closed
      ),
      ref(
        "table",
        "Standing Up Table at THREE",
        [[1.5, 3, -1.5], [4.5, 3, -1.5], [4.5, 3, 1.5], [1.5, 3, 1.5]],
        :closed
      ),
      ref(
        "diagonal-A",
        "XT TOWARD YT · rise SIX / run SIX / length SIX√2",
        [[0, 0, 0], [6, 6, 0]],
        :line
      ),
      ref(
        "diagonal-B",
        "current-turn XT TOWARD YT measure THROUGH center",
        [[0, 6, 0], [6, 0, 0]],
        :line
      ),
      ref(
        "xt-to-xt-from-here",
        "XT TO XT FROM HERE · invariant ZERO TO ONE · candidate placement",
        [[3, 0, -4], [3, 1, -4]],
        :line
      ),
      ref(
        "crossing",
        "pillar THREE TOWARD Projectioning Crossing",
        [[3, 3, -4], [3, 3, 0]],
        :line
      ),
      ref(
        "craft-reservation",
        "Craft reference at Seat ONE · no occupied hull / working COB",
        [[3, 1, -3], [3, 3, 0]],
        :line
      ),
      ref(
        "monitor",
        "fixed actual flat monitor · candidate mounting",
        [[1.8, 1.5, -1], [4.2, 1.5, -1], [4.2, 3.3, -1], [1.8, 3.3, -1]],
        :closed
      ),
      ref(
        "inner-aperture",
        "inner aperture · distinct from monitor/material boundary",
        circle([3, 3, 0], 0.4, "xz"),
        :closed
      ),
      ref(
        "material-aperture",
        "material aperture boundary · candidate fit",
        circle([3, 3, 0.3], 0.6, "xy"),
        :closed
      ),
      ref(
        "human-circle",
        "THIS ONE STANDINGING LANDINGING",
        circle([3, 0, -3], 1.5, "xz"),
        :closed
      )
    ]
  end

  def current_turn_measure do
    [a, b] = Enum.find(references(), &(&1.id == "diagonal-B")).points
    unit = Enum.find(references(), &(&1.id == "xt-to-xt-from-here"))

    %{
      id: "current-turn:xt-toward-yt-measure",
      turn_id: "current-turn-preview",
      subject: "Diagonal B",
      relation: "FURNISHES THE LENGTH OF XT TOWARD YT FOR THIS ONE CURRENT TURN",
      source_reference: "diagonal-B",
      points: [a, b],
      center: Enum.zip_with(a, b, &((&1 + &2) / 2)),
      actual_length: M.distance(a, b),
      vertical_rise: 6,
      horizontal_run: 6,
      frame: "exploration-six-v1",
      unit: "trial extent",
      geometry_contract: @version,
      status: :current_turn_line_furnished,
      scope: :geometry_preview,
      inherited_from: %{
        id: unit.id,
        points: unit.points,
        length: 1,
        relation: "XT TO XT FROM HERE",
        placement: :candidate_unit_embedding
      },
      related: ["diagonal-A", "pillar", "crossing", "six-frame"],
      prospective_join: %{
        id: "prospective-yt-toward-yt-join",
        basis: "current-turn:xt-toward-yt-measure",
        boundary_reference: b,
        physical_join_point: nil,
        material_points: [],
        next_extent_status: :not_furnished,
        acquired: false,
        status: :unresolved_join_reference
      }
    }
  end

  defp ref(id, label, points, kind),
    do: %{
      id: id,
      label: label,
      points: points,
      kind: kind,
      frame: "exploration-six-v1",
      status: :candidate_placement
    }

  defp circle([x, y, z], r, plane) do
    for i <- 0..31 do
      a = i * 2 * :math.pi() / 32

      if plane == "xz",
        do: [x + r * :math.cos(a), y, z + r * :math.sin(a)],
        else: [x + r * :math.cos(a), y + r * :math.sin(a), z]
    end
  end

  def operate(s, revision, command) when revision == s.revision and s.revision < 200 do
    case command(s, command) do
      {:ok, next, kind, result} ->
        event = %{
          id: "geometry-event-#{s.revision + 1}",
          geometry_contract: @version,
          mechanism: @mechanism,
          scope:
            if(kind == :condition_fixture,
              do: :condition_contract_fixture,
              else: :geometry_preview
            ),
          kind: kind,
          command: command,
          result: result,
          staging_provenance: %{
            mechanism: PublicSituationMachineTurnZero.Workshop.AlongsideStaging.version(),
            materials:
              Enum.map(
                PublicSituationMachineTurnZero.Workshop.AlongsideStaging.materials(next.staging),
                &%{
                  id: &1.id,
                  status: &1.status,
                  relation: &1.relation,
                  acquisition: &1.acquisition,
                  source: &1.source,
                  angle: &1.angle,
                  frame: &1.frame,
                  office: &1.office,
                  ancestry: &1.ancestry,
                  source_scope: &1.source_scope
                }
              ),
            regarding: next.staging.regarding,
            appointment: next.staging.target,
            from_down_under: next.staging.from_down_under,
            work_permitted: false
          },
          inherited_material: Enum.map(s.coils, & &1.id),
          resulting_material: Enum.map(next.coils, & &1.id),
          current_turn: current_turn_measure().turn_id,
          current_turn_measure: current_turn_measure().id,
          inherited_xt_to_xt: current_turn_measure().inherited_from.id,
          current_turn_length: current_turn_measure().actual_length,
          continuation: %{
            overlay: next.continuation_overlay?,
            status: :not_furnished,
            acquired: false
          },
          frame: frame().id,
          from: "ZERO",
          index_delta: 0,
          unit: "trial extent",
          effective_configuration: %{
            hinge: next.hinge,
            axis: next.axis,
            angle: next.angle,
            frame_measure: 6,
            coil_width: 0.16,
            coil_thickness: 0.04
          }
        }

        {:ok, %{next | revision: s.revision + 1, events: s.events ++ [event]}}

      error ->
        error
    end
  end

  def operate(_, _, _), do: {:error, :stale_or_session_limit}

  defp command(s, {:wedge_trial, v}) when v in ~w(simple returns),
    do: {:ok, %{s | wedging_trial: v}, :candidate_comparison, :no_acquisition}

  defp command(s, {:wedge_side, v}) when v in ~w(left right),
    do: {:ok, %{s | wedging_side: v}, :regarding, :no_material_change}

  defp command(s, {:staging, action}) do
    case PublicSituationMachineTurnZero.Workshop.AlongsideStaging.command(s.staging, action) do
      {:ok, staging, kind, result} -> {:ok, %{s | staging: staging}, kind, result}
      error -> error
    end
  end

  defp command(s, {:experiment, n}) when n in 1..length(@experiments)//1,
    do: {:ok, %{s | experiment: n}, :inspection, :selected}

  defp command(s, {:view, v}) when v in @views, do: {:ok, %{s | view: v}, :regarding, :selected}

  defp command(s, :toggle_continuation_overlay),
    do:
      {:ok, %{s | continuation_overlay?: !s.continuation_overlay?}, :prospective_regarding,
       :no_material_change}

  defp command(s, :furnish_continuation),
    do:
      blocked(s, :continuation_furnishing, [
        :physical_join_unproved,
        :no_continuation_material_issued
      ])

  defp command(s, :acquire_continuation),
    do:
      blocked(s, :continuation_acquisition, [
        :continuation_not_furnished,
        :no_lawful_acquisition_witnesses
      ])

  defp command(s, {:select, id}) do
    if id in Enum.map(references(), & &1.id) or id in Enum.map(s.coils, & &1.id),
      do: {:ok, %{s | selected: id}, :map_selection, :inspect_only},
      else: {:error, :unknown_locality}
  end

  defp command(s, :furnish_frame),
    do:
      {:ok,
       %{
         s
         | frame_status: :furnished_unacquired,
           notice:
             "SIX frame registered with minimum TWO-Footing capacity requirement. No Footings pre-created; physical readiness and acquisition remain blocked."
       }, :geometry_furnished, :unacquired}

  defp command(s, :acquire_frame), do: blocked(s, :protected_acquisition, @missing)
  defp command(s, :traverse), do: blocked(s, :traversal, [:unacquired_extent])

  defp command(s, :ceiling_arrival),
    do: blocked(s, :ceiling_arrival, [:no_acquired_locality, :no_occupied_passage])

  defp command(s, :inspect_ceiling),
    do:
      {:ok,
       %{
         s
         | ceiling: %{
             occasion: "ceiling-reference-inspected",
             height: 6,
             actual_arrival: false,
             bearing: "TOWARD SIX",
             return: :unproved
           },
           notice: "SIX reference inspected. No actual COB arrival and no new RE-STEP."
       }, :ceiling_reference_inspected, :index_unchanged}

  defp command(s, {:hinge, h}) when h in ~w(crossing seat),
    do:
      {:ok,
       %{
         s
         | hinge: h,
           angle: 0,
           notice: "Candidate pivot placement changed; angle reset to ZERO."
       }, :candidate_configuration, :changed}

  defp command(s, {:axis, axis}) when axis in ~w(x y),
    do:
      {:ok,
       %{
         s
         | axis: axis,
           angle: 0,
           notice:
             "Candidate pivot axis changed; angle reset to ZERO. Attached-edge incidence for Y remains unproved."
       }, :candidate_configuration, :axis_changed}

  defp command(s, {:angle, a}) when is_number(a) and a >= 0 and a <= 90 do
    specimen = specimen(s.hinge, a, s.axis)
    # Occupied fixture at source full-swing tip; compare finite solids, not SVG overlap.
    stop = stop()

    cond do
      outside_vertical_frame?(specimen.vertices) ->
        {:ok,
         %{
           s
           | notice:
               "BLOCKED: occupied specimen crosses Ground ZERO or ceiling SIX. Retained angle unchanged."
         }, :geometry_rejected, :frame_vertical_boundary}

      M.collision?(specimen, stop) ->
        {:ok,
         %{
           s
           | notice: "BLOCKED: specimen intersects occupied swing-stop. Retained angle unchanged."
         }, :geometry_rejected, :swing_stop}

      true ->
        {:ok,
         %{
           s
           | angle: a,
             notice:
               "Rigid candidate swing retained. It does not create intrinsic curvature or acquired extent."
         }, :geometry_proposed, :retained_candidate}
    end
  end

  defp command(%{frame_status: :unfurnished} = s, :propose_coil),
    do: blocked(s, :geometry_proposal, [:frame_not_furnished])

  defp command(s, :propose_coil) when length(s.coils) < 16 do
    candidate = coil(length(s.coils) + 1)
    collision = Enum.find_value(s.coils, fn prior -> interference(prior, candidate) end)

    if collision do
      {:ok,
       %{
         s
         | proposal: Map.put(candidate, :interference, collision),
           notice:
             "BLOCKED pair: finite Ribbon solids interfere near their common aperture. Accepted material retained; rejected second coil remains a dashed inspection candidate."
       }, :geometry_rejected, collision}
    else
      {:ok,
       %{
         s
         | coils: s.coils ++ [candidate],
           proposal: nil,
           notice:
             "Coiling specimen retained as proposed material, not an acquired Footing. Supply, Table contact and physical clearance remain unproved."
       }, :geometry_proposed, :retained_candidate}
    end
  end

  defp command(s, :propose_coil),
    do: blocked(s, :resource_limit, [:sixteen_candidate_session_bound_not_canon])

  defp command(s, {:lab, action}) do
    case fixture(s.condition_lab, action) do
      {:ok, lab} ->
        {:ok,
         %{
           s
           | condition_lab: lab,
             notice:
               "Condition-contract FIXTURE changed. Real geometry frame remains unacquired and traversal remains blocked."
         }, :condition_fixture, action}

      {:error, reason} ->
        blocked(s, :condition_fixture, [reason])
    end
  end

  defp command(_, _), do: {:error, :unsupported_operation}

  defp blocked(s, kind, reasons),
    do:
      {:ok,
       %{s | notice: "BLOCKED #{kind}: #{Enum.join(Enum.map(reasons, &to_string/1), ", ")}."},
       :blocked, %{operation: kind, missing: reasons}}

  def outside_vertical_frame?(vertices),
    do: Enum.any?(vertices, fn [_, y, _] -> y < 0 or y > 6 end)

  def specimen(hinge, angle, axis \\ "x") do
    origin = if hinge == "seat", do: [3, 1, -3], else: [3, 3, 0]
    a = angle * :math.pi() / 180

    points =
      Enum.map([[0, 0, 0], [1.5, 0, 0], [0, 0, 1.5]], fn [x, y, z] ->
        rotated =
          if axis == "y",
            do: [x * :math.cos(a) + z * :math.sin(a), y, -x * :math.sin(a) + z * :math.cos(a)],
            else: [x, y * :math.cos(a) - z * :math.sin(a), y * :math.sin(a) + z * :math.cos(a)]

        M.add(origin, rotated)
      end)

    M.prism("table-janusite-specimen", points, 0.04)
    |> Map.merge(%{
      placement_hinge: hinge,
      pivot_axis: axis,
      width: 1.5,
      material_id: "geometry-table:janusite-specimen",
      source: "candidate right-triangle stock; 1.5 extent legs; exploration-six-v1",
      hinge: %{
        id: "candidate-#{hinge}-#{axis}-axis",
        endpoints:
          if(axis == "x", do: Enum.take(points, 2), else: [origin, M.add(origin, [0, 1, 0])]),
        ordering: "anchor TOWARD +#{String.upcase(axis)}",
        attached_edge: if(axis == "x", do: :stock_leg, else: :unproved)
      }
    })
  end

  def stop do
    vertices =
      for x <- [-0.15, 0.15], y <- [-0.15, 0.15], z <- [-0.15, 0.15], do: [3 + x, 1.5 + y, z]

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

    %{id: "swing-stop", vertices: vertices, faces: faces}
  end

  # Constant-radius closed coil in a tilted plane, THROUGH the same center at both
  # ends. Vertical excursion approaches THREE from below; newer folds reach lower.
  # This is a placement experiment, not a conserved or physically clear folding law.
  def coil(n) when is_integer(n) and n >= 1 and n <= 16 do
    radius = 0.75
    depth = 3 * (1 - :math.pow(0.5, n))
    across = M.unit([0, 1, depth / (2 * radius)])
    count = 32

    sections =
      for i <- 0..(count - 1) do
        theta = i * 2 * :math.pi() / count

        point = [
          3 + radius * :math.sin(theta),
          3 - depth * (1 - :math.cos(theta)) / 2,
          radius * (1 - :math.cos(theta))
        ]

        tangent =
          M.unit([
            radius * :math.cos(theta),
            -depth * :math.sin(theta) / 2,
            radius * :math.sin(theta)
          ])

        normal = M.unit(M.cross(tangent, across))

        corners =
          for {w, t} <- [{-0.08, -0.02}, {0.08, -0.02}, {0.08, 0.02}, {-0.08, 0.02}],
              do: M.add(point, M.add(M.scale(across, w), M.scale(normal, t)))

        %{address: i / count, point: point, corners: corners}
      end

    segments =
      (sections ++ [hd(sections)])
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.with_index()
      |> Enum.map(fn {[a, b], i} ->
        vertices = a.corners ++ b.corners

        faces =
          for indices <- [
                [0, 3, 2, 1],
                [4, 5, 6, 7],
                [0, 1, 5, 4],
                [1, 2, 6, 5],
                [2, 3, 7, 6],
                [3, 0, 4, 7]
              ],
              do: Enum.map(indices, &Enum.at(vertices, &1))

        %{id: "coil-candidate-#{n}:segment-#{i}", vertices: vertices, faces: faces}
      end)

    %{
      id: "coil-candidate-#{n}",
      source: "janusite-underfold-stock",
      mechanism: @mechanism,
      ordinal: n,
      frame: "exploration-six-v1",
      unit: "trial extent",
      radius: radius,
      depth: depth,
      width: 0.16,
      thickness: 0.04,
      points: Enum.map(sections, & &1.point) ++ [hd(sections).point],
      sections: sections,
      segments: segments,
      entrance: [3, 3, 0],
      minimum_center_height: 3 - depth,
      status: :candidate_unacquired,
      relation: "THROUGH THE CENTER OF THE APERTURE AND FOLDS UNDER FROM WITHIN",
      physical_supply: :unproved,
      material_length: path_length(Enum.map(sections, & &1.point) ++ [hd(sections).point])
    }
  end

  def path_length(points),
    do:
      Enum.chunk_every(points, 2, 1, :discard)
      |> Enum.map(fn [a, b] -> M.distance(a, b) end)
      |> Enum.sum()

  def interference(a, b) do
    Enum.find_value(a.segments, fn sa ->
      Enum.find_value(b.segments, fn sb ->
        if bounds_overlap?(sa.vertices, sb.vertices) and M.collision?(sa, sb),
          do: %{
            material_a: a.id,
            material_b: b.id,
            segment_a: sa.id,
            segment_b: sb.id,
            reason: :occupied_common_aperture_contact
          },
          else: nil
      end)
    end)
  end

  defp bounds_overlap?(a, b) do
    Enum.all?(0..2, fn axis ->
      {amin, amax} = Enum.map(a, &Enum.at(&1, axis)) |> Enum.min_max()
      {bmin, bmax} = Enum.map(b, &Enum.at(&1, axis)) |> Enum.min_max()
      min(amax, bmax) - max(amin, bmin) > 1.0e-9
    end)
  end

  def fixture_new do
    %{
      scope: :condition_contract_fixture,
      provenance: "stipulated acquired context; not actual acquisition",
      encounter: false,
      local_receipt: false,
      conditions: [],
      satisfied: [],
      exit: false,
      restomp: false,
      state_ready: false,
      rezip: false,
      next_furnished: false,
      button_encounter: false,
      from: "ZERO",
      index: 0
    }
  end

  def fixture(lab, :encounter), do: {:ok, %{lab | encounter: true}}
  def fixture(%{encounter: true} = lab, :local_receipt), do: {:ok, %{lab | local_receipt: true}}
  def fixture(lab, :appoint_presence), do: {:ok, %{lab | conditions: ["presence"]}}

  def fixture(%{encounter: true, conditions: [_ | _]} = lab, :presence),
    do: {:ok, %{lab | satisfied: ["presence"]}}

  def fixture(%{local_receipt: true} = lab, :exit), do: {:ok, %{lab | exit: true}}
  def fixture(lab, :restomp), do: {:ok, %{lab | restomp: true}}
  def fixture(lab, :state_ready), do: {:ok, %{lab | state_ready: true}}
  def fixture(lab, :rezip), do: {:ok, %{lab | rezip: true}}
  def fixture(lab, :next_furnished), do: {:ok, %{lab | next_furnished: true}}

  def fixture(lab, :button_encounter),
    do:
      if(eligible?(lab),
        do: {:ok, %{lab | button_encounter: true}},
        else: {:error, :button_not_eligible}
      )

  def fixture(_, _), do: {:error, :fixture_prerequisite}

  def eligible?(lab),
    do:
      lab.local_receipt and lab.conditions != [] and
        Enum.all?(lab.conditions, &(&1 in lab.satisfied)) and lab.exit and lab.restomp and
        lab.state_ready and lab.rezip and lab.next_furnished

  def model(s) do
    shown = s.coils ++ if(s.proposal, do: [s.proposal], else: [])

    %{
      frame: frame(),
      turn_measure: current_turn_measure(),
      staging: PublicSituationMachineTurnZero.Workshop.AlongsideStaging.model(s.staging),
      references: references(),
      specimen: specimen(s.hinge, s.angle, s.axis),
      stop: stop(),
      coils: shown,
      edges: frame_edges(),
      axle: Enum.map(s.coils, & &1.entrance),
      acquired_localities: [],
      actual_working_cob: nil,
      eligibility: eligible?(s.condition_lab),
      missing_witnesses: @missing,
      qualifications: [
        "Candidate material; actual acquisition/traversal blocked",
        "Common-center pair may collide; no asymptotic physical proof",
        "Half-screen is a projection study; optical curvature unproved"
      ]
    }
  end

  def frame_edges do
    corners = for x <- [0, 6], y <- [0, 6], z <- [0, 6], do: [x, y, z]

    for {a, i} <- Enum.with_index(corners),
        {b, j} <- Enum.with_index(corners),
        i < j,
        Enum.count(Enum.zip(a, b), fn {u, v} -> u != v end) == 1,
        do: [a, b]
  end

  def project(points, view, half \\ false) do
    Enum.map_join(points, " ", fn point ->
      {x, y} = position(point, view, half)
      "#{x},#{y}"
    end)
  end

  def position([x, y, z], view, half \\ false) do
    {u, v} =
      case view do
        "plan" -> {x, z}
        "transverse" -> {z, y}
        "oblique" -> {0.8 * x - 0.6 * z, 0.3 * x + y + 0.4 * z}
        _ -> {x, y}
      end

    {if(half, do: 100 + u * 16, else: 100 + u * 32), 330 - v * 30}
  end
end
