defmodule PublicSituationMachineTurnZero.Workshop.CubicalConstruction do
  @moduledoc "Inscribed SIX frame and reciprocal inspection. No acquisition or physical interpolation API."
  alias PublicSituationMachineTurnZero.Workshop.{
    GeometryExploration,
    HereWedging,
    JanusiteInheritance,
    MaterialRibbon
  }

  alias MaterialRibbon, as: M
  @version "geometry-table-2026-11-15.v6"
  @facets %{"flat" => 0, "tunneling" => 45, "reciprocal" => 135, "return" => 225}
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
  @faces [
    {"near", [0, 2, 6, 4]},
    {"far", [1, 5, 7, 3]},
    {"ground", [0, 4, 5, 1]},
    {"ceiling", [2, 3, 7, 6]},
    {"left", [0, 1, 3, 2]},
    {"right", [4, 6, 7, 5]}
  ]

  def version, do: @version

  def new,
    do: %{
      revision: 0,
      facet: "flat",
      yaw: 0,
      selected: "six-frame",
      materials?: true,
      comparison: "SIX",
      notice: nil
    }

  def change(s, revision, command) do
    if revision == s.revision do
      case update(s, command) do
        {:ok, next} -> {:ok, %{next | revision: s.revision + 1, notice: nil}}
        error -> error
      end
    else
      {:error, :stale_inspection}
    end
  end

  defp update(s, {:facet, facet}) when is_map_key(@facets, facet),
    do: {:ok, %{s | facet: facet, yaw: @facets[facet]}}

  defp update(s, {:orbit, delta}) when delta in [-15, 15],
    do: {:ok, %{s | yaw: Integer.mod(s.yaw + delta, 360)}}

  defp update(s, :materials), do: {:ok, %{s | materials?: !s.materials?}}

  defp update(s, {:comparison, ref}) when ref in ~w(FOUR SIX EIGHT),
    do: {:ok, %{s | comparison: ref}}

  defp update(s, {:select, id}) when is_binary(id) do
    if Enum.any?(model().components, &(&1.id == id)),
      do: {:ok, %{s | selected: id}},
      else: {:error, :unknown_inscription}
  end

  defp update(_, _), do: {:error, :inspection_only}

  def model(janusite \\ JanusiteInheritance.new()) do
    f = GeometryExploration.frame()
    here = HereWedging.model()
    stock = JanusiteInheritance.model(janusite)
    refs = GeometryExploration.references()
    reference = fn id -> Enum.find(refs, &(&1.id == id)).points end
    [a, b] = reference.("diagonal-A")
    half = M.scale(M.add(a, b), 0.5)
    vertices = corners(f.minimum, f.maximum)

    frame =
      item(
        "six-frame",
        "RE-STEPPING CUBICAL · SIX × SIX × SIX",
        vertices,
        "WITHIN SIX",
        "whole frame",
        "SOURCE-BACKED",
        "GeometryExploration.frame/0",
        :reference,
        "Mathematical frame; lawful Human acquisition not attested"
      )

    frame_faces =
      for {name, ids} <- @faces do
        item(
          "face-#{name}",
          "Whole-frame #{name} face",
          Enum.map(ids, &Enum.at(vertices, &1)),
          "OF THE WHOLE SIX FRAME",
          "boundary",
          "SOURCE-BACKED",
          "GeometryExploration.frame/0; ordered corner indices",
          :reference,
          "Face registration is not an occupied wall or door"
        )
        |> Map.put(:kind, :face)
        |> Map.put(:vertex_ids, Enum.map(ids, &"vertex-#{&1}"))
      end

    edges =
      for {{i, j}, n} <- Enum.with_index(@edges) do
        item(
          "edge-#{n}",
          "Structural bearing #{i} TOWARD #{j}",
          [Enum.at(vertices, i), Enum.at(vertices, j)],
          "FROM vertex-#{i} TOWARD vertex-#{j}",
          "pipe-framework bearing reference",
          "SOURCE-BACKED",
          "GeometryExploration.frame/0",
          :reference,
          "Straight reference; pipe diameter, joint and elbow unappointed"
        )
        |> Map.put(:connections, ["vertex-#{i}", "vertex-#{j}"])
      end

    vertex_items =
      for {p, i} <- Enum.with_index(vertices),
          do:
            item(
              "vertex-#{i}",
              "Frame vertex #{i}",
              [p],
              "AT SIX FRAME",
              "endpoint",
              "SOURCE-BACKED",
              "GeometryExploration.frame/0",
              :reference,
              "No physical fastening inferred"
            )

    footings = [
      %{
        id: "footing-one",
        minimum: [0, 0, 0],
        maximum: [6, 3, 6],
        floor: 0,
        ceiling: 3,
        entrance_reference: half,
        actual_entrance: nil,
        cursor: nil,
        acquired: false,
        basis:
          "initial horizontal bisection; architectural entry at halfway; physical floor/entry incidence unresolved"
      },
      %{
        id: "footing-two",
        minimum: [0, 3, 0],
        maximum: [6, 6, 6],
        floor: 3,
        ceiling: 6,
        entrance_reference: nil,
        actual_entrance: nil,
        cursor: nil,
        acquired: false,
        basis: "prospective upper half UP FROM OUT OF first; no Landinging receipt"
      }
    ]

    footing_items =
      Enum.flat_map(footings, fn local ->
        status = if local.id == "footing-one", do: :candidate, else: :prospective
        bounds = corners(local.minimum, local.maximum)

        [
          item(
            local.id,
            "#{local.id} · bisection envelope",
            bounds,
            if(local.id == "footing-one",
              do: "FROM Ground TOWARD halfway",
              else: "UP FROM OUT OF footing-one"
            ),
            "local framing; not acquired Tunnel",
            "CANDIDATE",
            "Commission 2026-11-15 + horizontal bisection trial",
            status,
            local.basis
          )
          |> Map.put(:kind, :box)
        ] ++
          for {office, y} <- [{"floor", local.floor}, {"ceiling", local.ceiling}] do
            item(
              "#{local.id}-#{office}",
              "#{local.id} local #{office}",
              [[0, y, 0], [6, y, 0], [6, y, 6], [0, y, 6]],
              "OF #{local.id}",
              "local #{office} reference",
              "CANDIDATE",
              "Horizontal bisection trial",
              status,
              "Distinct identity from whole-frame ceiling; conditional opening/closing and physical passage unproved"
            )
            |> Map.put(:kind, :face)
          end
      end)

    materials = material_pair()

    material_items =
      Enum.map(materials, fn m ->
        item(
          m.id,
          m.name,
          m.points,
          m.relation,
          m.office,
          "CANDIDATE",
          "CubicalConstruction.material_pair/0; XT unit comparison",
          m.status,
          "Distinct finite stock, not a status recoloring; joining and acquisition unproved"
        )
        |> Map.merge(%{
          kind: :solid,
          faces: m.faces,
          vertices: m.vertices,
          material_id: m.material_id,
          thickness: m.thickness,
          width: m.width,
          area: m.area,
          side_lengths: m.lengths,
          hinge: nil,
          side: m.side,
          acquisition: m.acquisition,
          source_registration: m.source_registration
        })
      end)

    divider =
      item(
        "crossing-divider",
        "Projectioning Crossing central divider",
        [[2, 2, 3], [4, 4, 3]],
        "BETWEEN standing LEFT AND staging RIGHT",
        "registered alongside separator",
        "CANDIDATE",
        "Parallel A bearing at frame mid-depth Z=3",
        :candidate,
        "Interior parallel registration; not relocation of global diagonal A"
      )

    stage =
      item(
        "stage-door",
        "Situationing Stage Door / whole-frame entrance",
        [a],
        "STRAIGHT AHEAD FROM HERE THROUGH Flat Presentationing",
        "whole-frame entrance aperture registration",
        "REQUIREMENT / BLOCKED BOUNDARY",
        "Commission 2026-11-15; near XT corner of six-frame",
        :blocked,
        "Center at near lower-left XT; finite aperture boundary, normal and seated optical calibration unappointed"
      )

    seat =
      item(
        "seated-xt",
        "Constitutioning Human · seated XT FROM HERE",
        [here.seat_point],
        "SEATED FROM HERE AT XT",
        "persistent Seat reference",
        "SOURCE-BACKED",
        "HereWedging.model/0",
        :reference,
        "Seat point is not a measured eye position; physical Human never moves with Regarding"
      )

    forward =
      item(
        "stage-toward",
        "Seated locality TOWARD near XT entrance",
        [here.seat_point, a],
        "FROM seated-xt TOWARD stage-door",
        "required straight-ahead sight-bearing candidate",
        "CANDIDATE",
        "Unchanged Seat and new near-XT corner",
        :blocked,
        "Source endpoint bearing only; monitor normal and Human eye calibration remain unproved"
      )

    cursor =
      item(
        "current-pittoning",
        "Current cursor / PITTONING reference",
        here.unit.points,
        "THROUGH XT TO XT TOWARD XT TOWARD YT",
        "current-turn cursor basis; distinct from PINNING",
        "SOURCE-BACKED / CANDIDATE INCIDENCE",
        "HereWedging.unit",
        :reference,
        "Endpoint ONE supplies a current inspection cursor only; material length and physical incidence are not furnished"
      )

    window =
      item(
        "staging-window",
        "Right-hand reciprocating window",
        Enum.at(materials, 1).points,
        "THROUGH staging RIGHT REGARD ALONGSIDE WITH standing LEFT",
        "reciprocating-window boundary reservation",
        "BLOCKED",
        "Right-hand candidate wedge boundary",
        :blocked,
        "No hole, physical hinge, flap axis or coupling is appointed; distinct from central aperture and ceiling buttoning"
      )

    central =
      item(
        "central-aperture",
        "Inherited UN-VANISHING aperture",
        PublicSituationMachineTurnZero.Workshop.AlongsideStaging.aperture().points,
        "THROUGH Projectioning Crossing AT THREE",
        "inherited central aperture",
        "SOURCE-BACKED CANDIDATE",
        "AlongsideStaging.aperture/0",
        :candidate,
        "Physical gathering unproved; not whole-frame entrance or local ceiling door"
      )
      |> Map.put(:kind, :closed)

    three =
      item(
        "reference-three",
        "THREE · fixed SIX reference arc registration",
        [here.table],
        "AT THREE PRESERVE THE REFERENCE",
        "reference arc office",
        "REQUIREMENT / BLOCKED TRANSFORM",
        "Table THREE + retained A04 gauge source",
        :blocked,
        "A04 SIX radius is a provisional comparison, not six frame extents; native arc-to-THREE transform unappointed"
      )

    four =
      item(
        "gauge-four",
        "FOUR · Oscillationing Airiness Gauge",
        [],
        "REGARD BACK ALONG the fashioned return FROM seated XT",
        "measured variation from retained reference",
        "SOURCE-BACKED COMPARISON / BLOCKED MECHANISM",
        "MaterialRibbon.gauges/0; A04 source",
        :blocked,
        "Paired sample separations only; no operational interpolation law or mounted returning material"
      )

    six =
      item(
        "office-six",
        "SIX · projectioning / prospective membrane",
        [],
        "TOWARD THIS ONE CONSTITUTIONING HUMAN",
        "projectioning office; reciprocal Correspondencing prospective",
        "REQUIREMENT / UNMOUNTED",
        "Commission 2026-11-15",
        :prospective,
        "No membrane or external Tuple Ship exchange built"
      )

    eight =
      item(
        "office-eight",
        "EIGHT · Caterpillar outer wall",
        [],
        "WITHIN / OUT AMONG WITH",
        "outer segmentation office, not cube dimension",
        "REQUIREMENT / UNMOUNTED",
        "Commission 2026-11-15",
        :prospective,
        "No eight-wide frame or enclosing Public Field invented"
      )

    inherited =
      for id <- ~w(HERE seat table diagonal-B pillar) do
        item(
          "inherited-#{id}",
          "Inherited #{id}",
          reference.(id),
          "FROM inherited exploration-six-v1",
          "retained source reference",
          "SOURCE-BACKED",
          "GeometryExploration.references/0",
          :reference,
          "Preserved coordinates; physical coupling to new construction unproved"
        )
        |> Map.put(:kind, if(id in ~w(HERE seat table), do: :closed, else: :line))
      end

    pinning_items =
      for {office, letter} <- [{"head", hd(stock.letters)}, {"tail", List.last(stock.letters)}] do
        item(
          "#{office}-pinning",
          "#{String.upcase(office)} of String · #{letter.letter}",
          [],
          "PINNING an appointed #{office} hold; distinct from PITTONING",
          "authored material endpoint office",
          "SOURCE-BACKED ADDRESS / UNAPPOINTED HOLD",
          "JanusiteInheritance.model/1",
          :blocked,
          "Letter identity/address retained; actual PINNING hold and transfer onto new wedge not appointed"
        )
        |> Map.merge(%{
          source_stock_id: stock.id,
          source_letter_id: letter.id,
          curve_address: letter.address,
          source_to_new_wedge: nil
        })
      end

    components =
      [
        frame,
        stage,
        seat,
        forward,
        cursor,
        divider,
        window,
        central,
        three,
        four,
        six,
        eight,
        item(
          "transverse-A",
          "Whole-frame 45° transverse bearing A",
          [a, b],
          "FROM near XT TOWARD fixed far endpoint",
          "whole bounded bearing",
          "SOURCE-BACKED",
          "GeometryExploration.references/0 diagonal-A",
          :reference,
          "Fixed SIX√2 length; never extended by Footings"
        ),
        item(
          "ground-approach",
          "COB initial straight-UP approach",
          [[3, 0, 0], half],
          "STRAIGHT UP FROM Ground TOWARD halfway",
          "inaugural approach reference",
          "REQUIREMENT / CANDIDATE EMBEDDING",
          "Halfway of retained A; drop at fixed X/Z to Y=0",
          :candidate,
          "No 45° initial travel; occupied Craft and actual passage unproved"
        ),
        item(
          "first-bisection",
          "First Footing halfway registration",
          [half],
          "AT HALF OF whole-frame transverse-A",
          "initial local entrance reference",
          "SOURCE-BACKED BISECTION",
          "Midpoint of diagonal-A",
          :candidate,
          "Midpoint is on candidate first ceiling; physical entrance/floor orientation unresolved"
        )
      ] ++
        frame_faces ++
        edges ++ vertex_items ++ footing_items ++ material_items ++ inherited ++ pinning_items

    %{
      version: @version,
      frame: f,
      vertices: vertices,
      edges: Enum.map(@edges, &Tuple.to_list/1),
      components: components,
      footings: footings,
      fixed_endpoint: b,
      halfway: half,
      current_cursor: %{
        point: List.last(here.unit.points),
        basis: here.unit.id,
        scope: :inherited_unit_inspection,
        supplied_new_length: 0
      },
      material_ids: Enum.map(materials, & &1.material_id),
      candidate_stock_measurements: %{
        intersects: M.collision?(hd(materials), List.last(materials)),
        z_gap:
          Enum.min(Enum.map(List.last(materials).vertices, &Enum.at(&1, 2))) -
            Enum.max(Enum.map(hd(materials).vertices, &Enum.at(&1, 2))),
        scope: "Two diagnostic solids only; not Craft or tunnel clearance"
      },
      looking: %{
        toward: M.unit(M.sub(b, a)),
        right: [0, 0, 1],
        left: [0, 0, -1],
        divider_depth: 3
      },
      inherited_janusite: %{
        id: stock.id,
        head: stock.head,
        tail: stock.tail,
        head_pinning: :not_appointed,
        tail_pinning: :not_appointed,
        source_line: "snail-radial-arc-v1",
        transfer_to_new_wedges: nil,
        letters:
          Enum.map(
            stock.letters,
            &Map.take(&1, [:id, :letter, :address, :toes, :loop])
          )
      },
      preserved_fit: here.snail.height_range,
      circuit: %{
        source: "SnailBody.reference_arc/0; JanusiteInheritance.model/1",
        approach: "ground-approach",
        around_about: :inherited_curve_unmounted,
        return_to_here: :unproved,
        opening_condition: :pending,
        closing_condition: :pending,
        pending_policy: :continue_current_around_about_without_new_origin,
        securing: :not_attested,
        ceiling_passage: :unproved,
        landinging: nil,
        next_xt_origin: nil,
        next_cursor: nil,
        acquired_index: 0
      },
      mechanisms: %{
        xt_motor: :axes_coupling_unproved,
        yt_gear: :steering_not_upward_passage,
        reciprocating: :hinge_window_coupling_unproved
      },
      joins: %{table_exchange: :blocked, craft_clearance: :unproved, flat_to_curved: :unproved},
      turn_scope: :geometry_preview,
      acquired_index: 0,
      actual_footings: []
    }
  end

  def material_pair do
    c = :math.sqrt(0.5)

    for {side, z, status, name} <- [
          {:left, 2.4, :standing_fixture, "LEFT · material already standing (fixture)"},
          {:right, 3.6, :staging, "RIGHT · material staging for standing"}
        ] do
      points = [[3 - c / 2, 3 - c / 2, z], [3 + c / 2, 3 + c / 2, z], [3 - c / 2, 3 + c / 2, z]]

      M.prism("cubical-#{side}", points, 0.04)
      |> Map.merge(%{
        material_id: "cubical-janusite:#{side}",
        name: name,
        side: side,
        status: status,
        width: 1,
        source: "CubicalConstruction.material_pair/0; candidate ONE stock at frame center",
        source_registration: "parallel-A-mid-depth-v1",
        hinge: nil,
        acquisition: if(side == :left, do: :fixture_not_attested, else: :unacquired),
        relation: "#{side} ALONGSIDE WITH #{if(side == :left, do: "right", else: "left")}",
        office: if(side == :left, do: "inherited standing fixture", else: "staging for standing")
      })
    end
  end

  def gauge(comparison) when comparison in ~w(FOUR SIX EIGHT) do
    n = %{"FOUR" => 4, "SIX" => 6, "EIGHT" => 8}[comparison]
    sources = M.gauges()
    ref = Enum.find(sources, &(&1.axis == "x" and &1.label == 6))
    trial = Enum.find(sources, &(&1.axis == "x" and &1.label == n))

    native = fn points ->
      Enum.map(points, fn p ->
        {:ok, q} = M.transform(p, "motor-to-steeling-u13-v1")
        q
      end)
    end

    rp = native.(ref.points)
    tp = native.(trial.points)
    deltas = Enum.zip_with(rp, tp, &M.distance/2)

    %{
      reference: %{id: ref.id, points: rp, radius: ref.radius},
      candidate: %{id: trial.id, points: tp, radius: trial.radius},
      separations: deltas,
      maximum_separation: Enum.max(deltas),
      signed_radius_difference: trial.radius - ref.radius,
      frame: "steeling-xy-v1",
      source: "MaterialRibbon.gauges/0 + inverse registered transform",
      parameter: "same A04 quarter-sector samples i/24; no time or acquisition interpretation",
      source_to_cubical: nil,
      interpolation_formula: nil,
      status: :comparison_not_operational_interpolation
    }
  end

  def inscription(model, id), do: Enum.find(model.components, &(&1.id == id))
  def corners([x, y, z], [u, v, w]), do: for(a <- [x, u], b <- [y, v], c <- [z, w], do: [a, b, c])

  def box_lines(points),
    do: Enum.map(@edges, fn {i, j} -> [Enum.at(points, i), Enum.at(points, j)] end)

  def project(points, s) do
    a = s.yaw * :math.pi() / 180
    tilt = if s.facet == "flat", do: 0.0, else: 0.32

    Enum.map_join(points, " ", fn [x, y, z] ->
      x = x - 3
      z = z - 3
      u = x * :math.cos(a) - z * :math.sin(a)
      depth = x * :math.sin(a) + z * :math.cos(a)
      "#{420 + u * 56},#{395 - (y - tilt * depth) * 48}"
    end)
  end

  def gauge_project(points),
    do: Enum.map_join(points, " ", fn [_x, y, z] -> "#{40 + z * 105},#{245 - y * 105}" end)

  defp item(id, name, points, relation, office, classification, source, status, authority) do
    %{
      id: id,
      name: name,
      points: points,
      endpoints: if(length(points) > 1, do: [hd(points), List.last(points)], else: points),
      bearing: if(length(points) > 1, do: M.sub(List.last(points), hd(points)), else: nil),
      frame: "exploration-six-v1",
      unit: "trial extent; physical conversion unproved",
      relation: relation,
      office: office,
      classification: classification,
      source: source,
      status: status,
      authority: authority,
      kind: if(length(points) == 1, do: :point, else: :line),
      physical_join: :unproved,
      acquired: false
    }
  end
end
