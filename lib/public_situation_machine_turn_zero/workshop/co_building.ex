defmodule PublicSituationMachineTurnZero.Workshop.CoBuilding do
  @moduledoc "Material co-building reference and isolated rehearsals. No constitutional operation or persistence adapter."
  alias PublicSituationMachineTurnZero.Workshop.{
    CoBuildingGeometry,
    GeometryExploration,
    MaterialRibbon,
    HereWedging
  }

  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M
  @version "co-building-material-v4"
  @contract "geometry-table-2026-11-16.v10"
  @zero [3, 0, -2]
  @one [3, 1, -3]
  @three [6, 3, -2]
  @groups ~w(references metal aperture wedges pipes sources office-trace office-road office-standing return guides)
  @course_groups ~w(under-curve gallery-through gallery-departure upper-loop around-course next-flat subsequent-up)
  @study_groups ~w(interpolation-material offset-references conditional-appointment)
  @double_groups ~w(double-material double-incidence)
  @views ~w(flat gallery-close side plan transverse oblique half tunneling tunneling-under groundside fieldside)
  def version, do: @version
  def contract, do: @contract
  def groups, do: @groups ++ @course_groups ++ @study_groups ++ @double_groups
  def views, do: @views
  def zero, do: @zero
  def one, do: @one
  def three, do: @three

  def new do
    %{
      revision: 0,
      view: "oblique",
      yaw: 0.0,
      door: 0.0,
      wedge: 0.0,
      parked_door: 0.0,
      parked_view: %{view: "oblique", yaw: 0.0},
      selected: "cb:segmentation",
      layers: Map.new(groups(), &{&1, true}),
      layer: 5,
      isolate: nil,
      r_pose: "flat",
      traced?: false,
      stitch_preview?: false,
      m_projection?: false,
      circuit: 0.0,
      interpolation: 0.0,
      passage_appointment?: false,
      interpolation_projection?: false,
      trace: [],
      notice: nil
    }
  end

  def change(s, revision, command) when revision == s.revision do
    case update(s, command) do
      {:ok, next, kind} ->
        row = %{
          sequence: s.revision + 1,
          kind: kind,
          scope: :rehearsal_only,
          acquired_delta: 0,
          inherited_regarding: Map.take(s, [:view, :yaw]),
          resulting_regarding: Map.take(next, [:view, :yaw]),
          selected_source: next.selected,
          door: next.door,
          wedge_trial: next.wedge,
          r_pose: next.r_pose,
          interpolation: next.interpolation,
          conditional_appointment: next.passage_appointment?,
          interpolation_projection: next.interpolation_projection?
        }

        {:ok,
         %{next | revision: s.revision + 1, trace: Enum.take(s.trace ++ [row], -64), notice: nil}}

      error ->
        error
    end
  end

  def change(_, _, _), do: {:error, :stale}

  defp update(s, {:interpolation, v}) when is_number(v) and v >= 0 and v <= 1,
    do: {:ok, %{s | interpolation: v}, :material_refashioning}

  defp update(s, :passage_appointment),
    do:
      {:ok, %{s | passage_appointment?: !s.passage_appointment?},
       :conditional_appointment_proposal}

  defp update(s, :interpolation_projection),
    do: {:ok, %{s | interpolation_projection?: !s.interpolation_projection?}, :projection_only}

  defp update(s, :double_passage),
    do:
      {:ok,
       %{
         s
         | selected: "cb:double-registration",
           isolate: "double-passage",
           view: "oblique",
           layer: 5,
           layers: Map.new(groups(), &{&1, true})
       }, :prospective_double_passage_inspection}

  defp update(s, :three_four),
    do:
      {:ok,
       %{
         s
         | selected: "cb:interpolation",
           isolate: "three-four",
           layer: 5,
           layers: Map.new(groups(), &{&1, true})
       }, :inspection}

  defp update(s, {:course_stage, stage}) when stage in 1..7 do
    ids = %{
      3 => "cb:under-curve",
      4 => "cb:gallery-departure",
      5 => "cb:upper-loop",
      6 => "cb:tail-return",
      7 => "cb:next-fold"
    }

    next =
      if stage in [1, 2] do
        %{
          s
          | selected: "cb:R",
            isolate: "cb:R",
            view: "flat",
            r_pose: "flat",
            door: if(stage == 1, do: 0.0, else: 90.0),
            layer: 5,
            layers: Map.new(groups(), &{&1, true})
        }
      else
        id = Map.fetch!(ids, stage)
        %{s | selected: id, isolate: id, layer: 5, layers: Map.new(groups(), &{&1, true})}
      end

    {:ok, next, :inspection_stage}
  end

  defp update(s, {:view, v}) when v in @views, do: {:ok, %{s | view: v}, :regarding}

  defp update(s, {:yaw, v}) when is_number(v) and v >= 0 and v <= 360,
    do: {:ok, %{s | yaw: v}, :regarding}

  defp update(s, {:door, v}) when is_number(v) and v >= 0 and v <= 90,
    do: {:ok, %{s | door: v}, :material_rehearsal}

  defp update(s, {:wedge, v}) when is_number(v) and v >= 0 and v <= 90,
    do: {:ok, %{s | wedge: v}, :material_rehearsal}

  defp update(s, {:circuit, v}) when is_number(v) and v >= 0 and v <= 360,
    do: {:ok, %{s | circuit: v}, :inspection_cursor}

  defp update(s, {:layer, v}) when is_integer(v) and v in 0..5,
    do: {:ok, %{s | layer: v}, :overlay}

  defp update(s, {:toggle, g})
       when g in @groups or g in @course_groups or g in @study_groups or g in @double_groups,
       do: {:ok, %{s | layers: Map.update!(s.layers, g, &(!&1))}, :overlay}

  defp update(s, :park_view),
    do: {:ok, %{s | parked_view: Map.take(s, [:view, :yaw])}, :parked_regarding}

  defp update(s, :restore_view), do: {:ok, Map.merge(s, s.parked_view), :regarding}
  defp update(s, :park_door), do: {:ok, %{s | parked_door: s.door}, :parked_rehearsal}
  defp update(s, :restore_door), do: {:ok, %{s | door: s.parked_door}, :material_rehearsal}
  defp update(s, {:trace, "R"}), do: {:ok, %{s | traced?: true}, :inkwell_tracing_rehearsal}

  defp update(s, {:r_pose, v}) when v in ~w(flat road),
    do: {:ok, %{s | r_pose: v}, :letter_appointment_rehearsal}

  defp update(%{traced?: true, r_pose: "road"} = s, :stitch),
    do: {:ok, %{s | stitch_preview?: !s.stitch_preview?}, :doll_stitch_rehearsal}

  defp update(s, :m_projection),
    do: {:ok, %{s | m_projection?: !s.m_projection?}, :projection_only}

  defp update(s, :reveal),
    do: {:ok, %{s | isolate: nil, layers: Map.new(groups(), &{&1, true}), layer: 5}, :overlay}

  defp update(s, :bare), do: {:ok, %{s | isolate: "metal"}, :overlay}
  defp update(s, :isolate), do: {:ok, %{s | isolate: s.selected}, :overlay}

  defp update(s, {:select, id}) when is_binary(id) do
    if Enum.any?(model(s).parts, &(&1.id == id)),
      do: {:ok, %{s | selected: id}, :inspection},
      else: {:error, :unknown_source}
  end

  defp update(_, _), do: {:error, :inspection_only_or_missing_rehearsal_basis}

  def local(p), do: M.add(@zero, p)

  def model(s) do
    study =
      PublicSituationMachineTurnZero.Workshop.ThreeFourStudy.model(
        s.interpolation,
        s.passage_appointment?,
        s.interpolation_projection?,
        s.circuit
      )

    double = PublicSituationMachineTurnZero.Workshop.DoublePassageStudy.model()
    course = PublicSituationMachineTurnZero.Workshop.GalleryCourse.model()
    refs = GeometryExploration.references()
    ref = fn id -> Enum.find(refs, &(&1.id == id)).points end
    empty = %{vertices: [], faces: []}
    axis = [0, 1, 0]
    tube = fn a, b, r, i -> G.pipe([a, b], r, i, 16) end
    root = tube.([3, -0.12, -2], [3, 0.12, -2], 0.58, 0.45)

    base_points =
      for {x, z} <- [{-0.65, -0.65}, {0.65, -0.65}, {0.65, 0.65}, {-0.65, 0.65}],
          do: local([x, 0, z])

    square = G.pipe(base_points ++ [hd(base_points)], 0.035, 0.02, 8)
    floor_unit = [@zero, [3, 0, -3]]

    wa =
      G.prism([@zero, [3, 0, -3], @one], 0.04)
      |> G.clip([1, 1, 0], 3)
      |> G.translate([-0.08, 0.16, 0])

    wb_source =
      G.prism([@zero, [3, 0, -3], [2, 0, -3]], 0.04)
      |> G.clip([-1, -1, 0], -3)
      |> G.translate([-0.08, 0.16, 0])

    wb = G.transform(wb_source, &G.rotate_z(&1, [2.92, 0.16, -2], -s.wedge))

    leverage = G.sweep([@zero, @one], 0.1, 0.08)
    axle = G.box([2.94, 0, -3.06], [3.06, 0.94, -2.94])
    pivot_one = tube.([3, 0.94, -3], [3, 1.04, -3], 0.22, 0.10)
    pivot_three = tube.([6, 2.94, -2], [6, 3.06, -2], 0.32, 0.18)
    table = tube.([6, 2.98, -2], [6, 3.02, -2], 1.5, 0.32)
    globe = G.sphere_belt([6, 2.6, -2], 0.32, 0.28)
    monitor = G.box([1.8, 1.5, -1.01], [4.2, 3.3, -0.99])
    door_base = G.box([1.8, 1.5, -1.025], [4.2, 3.3, -1.005])
    hinge = [1.8, 1.5, -1]
    swing = fn p -> G.rotate_y(p, hinge, s.door) end
    door = G.transform(door_base, swing)
    road = [local([1.2, 1.2, 0.35]), local([3.6, 3.6, 0.35])]
    road_mesh = G.sweep(road, 0.24, 0.02)
    xt_pipe = G.pipe([local([0.15, 0.15, 0.35]), List.last(road)], 0.055, 0.035, 8)

    ring =
      for i <- 0..32,
          do: [
            3 + 1.3 * :math.sin(i * 2 * :math.pi() / 32),
            3.6,
            -3 + 1.3 * :math.cos(i * 2 * :math.pi() / 32)
          ]

    yt_pipe = G.pipe(ring, 0.055, 0.035, 8)

    return_path =
      [List.last(road), [6.6, 3.6, -1.7], hd(ring)] ++
        tl(ring) ++ [[1.5, 3.6, -3], [1.5, 0.6, -6], [1.5, 0.12, -5.52]]

    return_mesh = G.sweep(return_path, 0.18, 0.02, 180)
    standing_path = [[5.6, -0.3, -2], [5.6, 1.8, -2], [6, 2.3, -2], [6, 3.3, -2]]
    standing_mesh = G.sweep(standing_path, 0.18, 0.02)
    source_r = glyph("R", fn [u, v] -> [2.78 + u, 2.05 + v, -1.04] end)

    road_pose = fn [x, y, z] ->
      M.add(
        local([2, 2, 0.35]),
        M.add(
          M.scale([0, 0, 1], x - 3.005),
          M.add(
            M.scale([-:math.sqrt(0.5), :math.sqrt(0.5), 0], y - 2.4),
            M.scale([:math.sqrt(0.5), :math.sqrt(0.5), 0], z + 1.04)
          )
        )
      )
    end

    r_map = if s.r_pose == "flat", do: swing, else: road_pose
    r = G.transform(source_r, r_map)

    r_normal =
      if s.r_pose == "flat",
        do: M.sub(swing.([0, 0, 1]), swing.([0, 0, 0])),
        else: [:math.sqrt(0.5), :math.sqrt(0.5), 0]

    m_source = glyph("M", fn [u, v] -> [1.5 + u, 0.12, -5.52 - v] end)
    m_image = glyph("M", fn [u, v] -> [2.78 + u, 2.05 + v, -1.04] end)

    frame_edges =
      for {a, b} <- [
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
          ] do
        corners = for x <- [0, 6], y <- [0, 6], z <- [0, 6], do: local([x, y, z])
        [Enum.at(corners, a), Enum.at(corners, b)]
      end

    p = fn id, name, group, material, mesh, status, office, extra ->
      default = %{
        id: "cb:" <> id,
        name: name,
        group: group,
        material: material,
        status: status,
        office: office,
        source_id: "cb:" <> id,
        frame: "co-building-placement-v1",
        geometry: mesh,
        source_geometry: mesh,
        from: "cb:zero",
        toward: "cb:three",
        ground_side: "Ground-side Ground",
        field_side: "Field-side Ground",
        acquired: false,
        source: "CoBuilding.model/1; commission 2026-11-15",
        attachment: :registered_candidate_not_secured,
        pivot: nil,
        plane_normal: nil,
        construction_layer: 1,
        children: [],
        yellow: [],
        actual_alteration: false,
        inherited: ["geometry-table-2026-11-15.v6"],
        closed_physical_join: false
      }

      Map.merge(default, extra)
    end

    parts = [
      p.(
        "segmentation",
        "THIS ONE SEGMENTATIONING WEDGING",
        "wedges",
        "JANUSITE",
        empty,
        :yellow,
        "common registration / finite right-angle miter",
        %{
          children: ~w(cb:wedge-A cb:wedge-B cb:local-unit cb:zero),
          interior_sections:
            for(
              i <- 1..6,
              do: %{
                id: "cb:SIX-section-#{i}",
                source_coordinate: [i, i, 0],
                world_point: local([i, i, 0]),
                normal: [:math.sqrt(0.5), :math.sqrt(0.5), 0],
                status: :reference_not_footing,
                physical_incidence: nil
              }
            ),
          construction_layer: 2,
          yellow: [:root_attachment, :surface_A_to_EIGHT, :physical_holding]
        }
      ),
      p.(
        "six",
        "SIX × SIX × SIX · reference only",
        "references",
        "reference",
        empty,
        :reference,
        "invariant extent, not a metal cage",
        %{
          lines: frame_edges,
          source_coordinates: %{minimum: [0, 0, 0], maximum: [6, 6, 6]},
          transform: %{translation: @zero, axes: [[1, 0, 0], [0, 1, 0], [0, 0, 1]]},
          construction_layer: 0
        }
      ),
      p.(
        "global-A",
        "Inherited global Diagonal A",
        "guides",
        "reference",
        empty,
        :reference,
        "fixed source bearing",
        %{
          lines: [[local([0, 0, 0]), local([6, 6, 0])]],
          source_coordinates: [[0, 0, 0], [6, 6, 0]],
          source_frame: "exploration-six-v1",
          transform: %{translation: @zero},
          construction_layer: 0
        }
      ),
      p.(
        "global-B",
        "Inherited global Diagonal B",
        "guides",
        "reference",
        empty,
        :reference,
        "current-turn measure, not Wedge B",
        %{
          lines: [[local([0, 6, 0]), local([6, 0, 0])]],
          source_coordinates: [[0, 6, 0], [6, 0, 0]],
          source_frame: "exploration-six-v1",
          transform: %{translation: @zero},
          construction_layer: 0
        }
      ),
      p.(
        "HERE",
        "THIS HERE APPROACHING LANDINGING",
        "references",
        "reference",
        empty,
        :reference,
        "persistent HERE square",
        %{
          lines: [ref.("HERE") ++ [hd(ref.("HERE"))]],
          source: "GeometryExploration.references/0; unchanged world points",
          construction_layer: 0
        }
      ),
      p.(
        "standing-circle",
        "THIS ONE STANDINGING LANDINGING",
        "references",
        "reference",
        empty,
        :reference,
        "Human circular locality",
        %{lines: [ref.("human-circle")], construction_layer: 0}
      ),
      p.(
        "ground-side",
        "Ground-side Ground",
        "references",
        "reference",
        empty,
        :reference,
        "GROUNDSIDE REGARDING",
        %{
          lines: [ref.("HERE") ++ [hd(ref.("HERE"))]],
          plane_normal: [0, 1, 0],
          construction_layer: 0
        }
      ),
      p.(
        "field-side",
        "Field-side Ground",
        "references",
        "reference",
        empty,
        :reference,
        "FIELDSIDE REGARDING OVER ACROSS GROUNDSIDE REGARDING",
        %{
          lines: [
            [
              local([0, 0, 0]),
              local([6, 0, 0]),
              local([6, 0, 6]),
              local([0, 0, 6]),
              local([0, 0, 0])
            ]
          ],
          plane_normal: [0, -1, 0],
          shared_plane: "Y=0",
          construction_layer: 0
        }
      ),
      p.(
        "zero",
        "ZERO · stable square / cylinder aperture",
        "aperture",
        "structural metal",
        root,
        :ready,
        "invariant bore; not Table THREE",
        %{
          from: "Ground ZERO",
          toward: "ONE",
          pivot: %{origin: @zero, axis: axis},
          bore_radius: 0.45,
          outer_radius: 0.58,
          construction_layer: 0,
          yellow: [:actual_ground_securing]
        }
      ),
      p.(
        "zero-square",
        "ZERO square · four-point registration",
        "aperture",
        "structural metal",
        square,
        :ready,
        "square-and-circle relation",
        %{points: base_points, construction_layer: 0}
      ),
      p.(
        "leverage",
        "ZERO TOWARD ONE · 45° leverage",
        "metal",
        "structural metal",
        leverage,
        :ready,
        "one bar, rise ONE / run ONE",
        %{
          points: [@zero, @one],
          length: :math.sqrt(2),
          pivot: %{origin: @one, axis: axis},
          plane_normal: [1, 0, 0],
          yellow: [:bearing_fastening]
        }
      ),
      p.(
        "local-unit",
        "XT TO XT · invariant local ONE",
        "guides",
        "reference",
        empty,
        :reference,
        "PITTONING reference; no consequential PITTONING",
        %{
          lines: [floor_unit],
          points: floor_unit,
          length: 1,
          from: "Wedge A endpoint reference",
          toward: "Wedge B endpoint reference",
          yellow: [:actual_pittoning_witness],
          construction_layer: 0
        }
      ),
      p.(
        "square-axle",
        "Traversaling Seat square axle",
        "metal",
        "structural metal",
        axle,
        :ready,
        "Seat support, not geographical axis",
        %{pivot: %{origin: @one, axis: axis}, section: [0.12, 0.12]}
      ),
      p.(
        "pivot-one",
        "ONE · Seat pivot bearing",
        "metal",
        "structural metal",
        pivot_one,
        :ready,
        "pivot at inherited seated locality",
        %{
          pivot: %{origin: @one, axis: axis},
          inner_radius: 0.10,
          outer_radius: 0.22,
          yellow: [:keyed_coupling]
        }
      ),
      p.(
        "seat",
        "Traversaling Seat · FROM HERE at ONE",
        "metal",
        "structural metal",
        G.box([2.65, 1.04, -3.35], [3.35, 1.10, -2.65]),
        :ready,
        "recognizable seat pan",
        %{
          points: [@one],
          source: "HereWedging.seat_point retained [3,1,-3]",
          yellow: [:actual_human_mount_calibration]
        }
      ),
      p.(
        "seat-back",
        "Traversaling Seat · back reference",
        "metal",
        "structural metal",
        G.box([2.65, 1.1, -3.40], [3.35, 1.75, -3.34]),
        :ready,
        "BEHIND seated Human",
        %{}
      ),
      p.(
        "over-across",
        "Heavy bearing OVER ACROSS",
        "metal",
        "structural metal",
        G.sweep([M.add(@one, [0.23, 0.12, 0]), M.add(@three, [-0.34, -0.12, 0])], 0.12, 0.10),
        :ready,
        "supports ONE / THREE reference; open intervening volume",
        %{yellow: [:end_sleeves, :load_strength]}
      ),
      p.(
        "pivot-three",
        "THREE · second pivot bearing",
        "metal",
        "structural metal",
        pivot_three,
        :ready,
        "Table / globe mounting",
        %{
          pivot: %{origin: @three, axis: axis},
          inner_radius: 0.18,
          outer_radius: 0.32,
          yellow: [:fasteners]
        }
      ),
      p.(
        "globe",
        "Co-Bobbining Stringing Thing · globe housing",
        "metal",
        "structural metal",
        globe,
        :ready,
        "FROM OUT OF globe TOWARD Table",
        %{bore_minimum: 0.14, yellow: [:spool_coupling, :string_feed]}
      ),
      p.(
        "globe-adapter",
        "Globe-to-THREE annular adapter",
        "metal",
        "structural metal",
        G.globe_adapter([6, 2.6, -2], 2.94),
        :ready,
        "finite matched-profile neck; open interpolationing volume",
        %{
          pivot: %{origin: @three, axis: axis},
          bore_minimum: 0.14,
          yellow: [:fastening, :load_strength]
        }
      ),
      p.(
        "table",
        "RE-surfacing Table · plane at THREE",
        "metal",
        "structural metal",
        table,
        :ready,
        "OVER ACROSS / material working",
        %{
          plane_normal: [0, 1, 0],
          pivot: %{origin: @three, axis: axis},
          inner_radius: 0.32,
          outer_radius: 1.5,
          thickness: 0.04,
          yellow: [:physical_return_feed, :secure_interface]
        }
      ),
      p.(
        "working-extent",
        "THREE TO FOUR · reserved working extent",
        "guides",
        "reference",
        G.box([6, 3.08, -2.22], [7, 3.09, -1.78]),
        :reference,
        "Human fashioning/refashioning and conditional passage reservation; not an acquired height FOUR",
        %{
          points: [@three, M.add(@three, [1, 0, 0])],
          plane_normal: [0, 1, 0],
          construction_layer: 0
        }
      ),
      p.(
        "wedge-A",
        "Wedge A · upright reference-plane stock",
        "wedges",
        "JANUSITE ribbon",
        wa,
        :ready,
        "first XT material-plane office",
        %{
          plane_normal: [1, 0, 0],
          points: [@zero, [3, 0, -3], @one],
          thickness: 0.04,
          actual_mount_offset: [-0.08, 0.16, 0],
          pivot: %{origin: [2.92, 0.16, -2], axis: [0, 0, -1]},
          construction_layer: 2,
          yellow: [:zero_mount, :surface_A_correspondence]
        }
      ),
      p.(
        "wedge-B",
        "Wedge B · Ground-reference plane stock",
        "wedges",
        "JANUSITE ribbon",
        wb,
        if(s.wedge == 0, do: :ready, else: :rehearsal),
        "second XT material-plane office",
        %{
          source_geometry: wb_source,
          actual_alteration: s.wedge != 0,
          pivot: %{
            origin: [2.92, 0.16, -2],
            axis: [0, 0, -1],
            status: :trial_axis_not_a_fabricated_hinge
          },
          plane_normal: [
            :math.sin(s.wedge * :math.pi() / 180),
            :math.cos(s.wedge * :math.pi() / 180),
            0
          ],
          points: [@zero, [3, 0, -3], [2, 0, -3]],
          thickness: 0.04,
          actual_mount_offset: [-0.08, 0.16, 0],
          construction_layer: 2,
          yellow: [:pittoning_hold, :root_mount]
        }
      ),
      p.(
        "monitor",
        "Real monitor · stays fixed",
        "references",
        "reference",
        monitor,
        :reference,
        "Flat Presentationing; no physical monitor swing",
        %{
          plane_normal: [0, 0, 1],
          source: "GeometryExploration.monitor reference; retained world plane Z=-1",
          construction_layer: 0
        }
      ),
      p.(
        "glass",
        "Looking THROUGHING THROUGHING Glass",
        "office-trace",
        "Glass reference",
        G.box([2.2, 1.75, -1.034], [3.8, 3.05, -1.025]),
        :reference,
        "Passaging Way FROM HERE OVER ACROSS TOWARD THERE",
        %{
          plane_normal: [0, 0, 1],
          construction_layer: 4,
          yellow: [:optical_transfer, :physical_ink_interface]
        }
      ),
      p.(
        "slate",
        "Gallery Door · staging-for-staging / opening Slate",
        "sources",
        "structural frame",
        G.pipe(
          double.door.frame_points,
          0.025,
          0.012,
          8
        ),
        :reference,
        "Gallery staging-for-staging surface; Pretend keyboard through Slate",
        %{
          gallery_door_identity: "gallery-door:1",
          plane_normal: [0, 0, 1],
          construction_layer: 4,
          yellow: [:inkwell_feed, :device_mount, :gallery_membrane]
        }
      ),
      p.(
        "stage-door",
        "Situationing Stage Door · opens FROM Gallery",
        "office-trace",
        "JANUSITE plane",
        door,
        :rehearsal,
        "opens FROM Gallery staging-for-staging surface; not the real monitor",
        %{
          source_geometry: door_base,
          opens_from: "cb:slate",
          gallery_door_identity: "gallery-door:1",
          actual_alteration: s.door != 0,
          pivot: %{origin: hinge, axis: axis},
          plane_normal: M.sub(swing.([0, 0, 1]), swing.([0, 0, 0])),
          construction_layer: 4,
          yellow: [:physical_hinge, :optical_mount]
        }
      ),
      p.(
        "inkwell",
        "HERE-side Inkwelling / opening Slate source",
        "sources",
        "source housing",
        G.box([2, 1.15, -1.55], [2.25, 1.4, -1.3]),
        :yellow,
        "staging-for-staging source",
        %{construction_layer: 4, yellow: [:slate_feed, :needle_interface]}
      ),
      p.(
        "quilling-needle",
        "Quilling Stitching Needle · separate tool",
        "sources",
        "metal tool",
        tube.([2.3, 1.2, -1.4], [2.3, 1.55, -1.4], 0.015, 0),
        :reference,
        "canonical tool; not Inkwelling or endless string",
        %{construction_layer: 4, yellow: [:material_feed]}
      ),
      p.(
        "doll-source",
        "Doll stitching material source",
        "sources",
        "source housing",
        G.box([5.3, 2.65, -1.15], [5.55, 2.9, -0.9]),
        :yellow,
        "Doll non-agentive stitching office",
        %{construction_layer: 4, yellow: [:doll_mount, :two_toe_attachment]}
      ),
      p.(
        "endless-source",
        "Never-Ending Stringing Thing",
        "sources",
        "source housing",
        tube.([5.5, 2.6, -2], [5.5, 2.9, -2], 0.17, 0.08),
        :yellow,
        "PINNING / PITTONING / Tail return source",
        %{construction_layer: 4, yellow: [:return_feed, :winding, :actual_holds]}
      ),
      p.(
        "xt-pipe",
        "JANUSITE metal pipe ALONG THROUGH XT",
        "pipes",
        "JANUSITE metal piping",
        xt_pipe,
        :ready,
        "inscription carrier, distinct from heavy bearing",
        %{
          points: [local([0.15, 0.15, 0.35]), List.last(road)],
          outer_radius: 0.055,
          inner_radius: 0.035,
          construction_layer: 3,
          yellow: [:aperture_receiving_joint, :source_material_feed]
        }
      ),
      p.(
        "yt-pipe",
        "JANUSITE pipe AROUND ABOUT seated locality",
        "pipes",
        "JANUSITE metal piping",
        yt_pipe,
        :prospective,
        "YT Gallery circuit around the same Seat",
        %{
          points: ring,
          outer_radius: 0.055,
          inner_radius: 0.035,
          construction_layer: 3,
          yellow: [:xt_to_gallery_join, :outer_EIGHT_mount, :manufacture]
        }
      ),
      p.(
        "road",
        "45° Gallery Door road appointment",
        "office-road",
        "JANUSITE ribbon",
        road_mesh,
        :prospective,
        "STAGING FOR STANDING",
        %{
          points: road,
          thickness: 0.02,
          width: 0.24,
          construction_layer: 4,
          yellow: [:actual_letter_stitching, :material_supply]
        }
      ),
      p.(
        "standing-material",
        "Previously fashioned standing reference",
        "office-standing",
        "JANUSITE ribbon",
        standing_mesh,
        :reference,
        "STANDING FOR STAGING · fixture not attested",
        %{
          points: standing_path,
          construction_layer: 4,
          relation: "intended UP FROM DOWN UNDER OVER ACROSS",
          yellow: [:prior_landing_receipt, :physical_return_feed]
        }
      ),
      p.(
        "R",
        "R · one source identity",
        if(s.r_pose == "road", do: "office-road", else: "office-trace"),
        "tracing material",
        r,
        :rehearsal,
        "tracing / road appointment; no acquired stitching",
        %{
          source_geometry: source_r,
          source_letter: "specimen:R:1",
          actual_alteration: s.door != 0 or s.r_pose != "flat",
          plane_normal: r_normal,
          construction_layer: 4,
          traced: s.traced?,
          actual_stitching: false,
          material_source: "cb:inkwell",
          tracing_surface: "cb:glass",
          attachment_slots: %{
            leading_Toe: :rehearsal_only,
            trailing_Toe: :rehearsal_only,
            upper_loop: :distinct_not_third_stitch
          },
          yellow: [:ink_feed, :doll_stitching]
        }
      ),
      p.(
        "tail-return",
        "Full AROUND ABOUT Tail return reservation",
        "return",
        "prospective JANUSITE ribbon",
        empty,
        :prospective,
        "behind Human, twist, reciprocal descent; not acquired return",
        %{
          points: course.points,
          course_id: course.id,
          historical_v7_points: return_path,
          continuous_reference_not_physical_join: true,
          roll_degrees: 0,
          reciprocal_roll_law: :yellow_not_applied_to_new_course,
          construction_layer: 5,
          yellow: [:finite_twist_law, :supply, :xt_return_join, :clearance]
        }
      ),
      p.(
        "terminal-M",
        "M · prospective Tail identity",
        "return",
        "prospective letter",
        m_source,
        :prospective,
        "DOWN on XT / optional projected UP FROM DOWN UNDER",
        %{
          source_letter: "return-template:M:1",
          display_geometry: if(s.m_projection?, do: m_image, else: m_source),
          projection_only: s.m_projection?,
          projection_basis: %{
            source_relation: "DOWN UNDER relative to Table Y=3; acquisition not attested",
            target: "fixed monitor / Glass reference",
            matrix: [[1, 0, 0, 1.28], [0, 0, -1, -3.47], [0, 0, 0, -1.04], [0, 0, 0, 1]],
            target_normal: [0, 0, 1],
            physical_geometry_mutated: false
          },
          plane_normal: [0, 1, 0],
          construction_layer: 5,
          yellow: [:actual_tail_material, :optical_transfer]
        }
      ),
      p.(
        "next-fold",
        "Next PINNING · lies FLAT · one extent UP OVER",
        "next-flat",
        "prospective JANUSITE",
        G.strap(hd(course.pin), List.last(course.pin), 0.04, 0.012, [0, 1, 0]),
        :prospective,
        "newly furnished flat PINNING; not PITTONING or acquired Footing",
        %{
          points: course.pin,
          plane_normal: [0, 1, 0],
          flat: true,
          inherited_origin: @three,
          appointment_offset: [1, 1, 0],
          lifecycle: :new_flat_reference,
          construction_layer: 5,
          yellow: [:actual_ground_connection, :next_landing_receipt]
        }
      ),
      p.(
        "pinning-reference",
        "Prospective PINNING · three local extents",
        "guides",
        "reference",
        empty,
        :reference,
        "hypothesis not actual PITTONING",
        %{
          lines: [[@three, M.add(@three, [0, 3, 0])]],
          length: 3,
          construction_layer: 5,
          yellow: [:pinning_appointment]
        }
      ),
      p.(
        "EIGHT",
        "EIGHT · outer AROUND ABOUT registration",
        "guides",
        "reference",
        empty,
        :prospective,
        "outer relation, not an eight-wide reference cube",
        %{
          lines: [ring],
          construction_layer: 5,
          yellow: [:surface_A_to_outer_sector],
          regions:
            for(
              i <- 0..7,
              do: %{
                id: "cb:EIGHT-region-#{i + 1}",
                source_course: "cb:yt-pipe",
                points: Enum.slice(ring, i * 4, 5),
                parameter_interval: [i / 8, (i + 1) / 8],
                status: :prospective_partition_not_final_shell,
                physical_join: nil
              }
            )
        }
      ),
      p.(
        "circuit-cursor",
        "Gallery circuit inspection cursor",
        "guides",
        "reference",
        G.box(
          M.sub(circuit_point(s.circuit), [0.035, 0.035, 0.035]),
          M.add(circuit_point(s.circuit), [0.035, 0.035, 0.035])
        ),
        :reference,
        "source inspection only; not COB Traversaling",
        %{construction_layer: 5, yellow: [:actual_cob_locality]}
      )
    ]

    feet =
      for {point, i} <- Enum.with_index(base_points) do
        p.(
          "quadranglement-#{i + 1}",
          "Quadranglementing material point #{i + 1}",
          "aperture",
          "structural metal",
          G.box(M.add(point, [-0.065, -0.18, -0.065]), M.add(point, [0.065, 0.02, 0.065])),
          :ready,
          "four registered material clamp envelopes",
          %{points: [point], construction_layer: 0, yellow: [:actual_ground_securing]}
        )
      end

    toes =
      if s.stitch_preview? and s.r_pose == "road" do
        for {uv, i} <- Enum.with_index([[0, 0], [0.45, 0]]) do
          [u, v] = uv
          pnt = r_map.([2.78 + u, 2.05 + v, -1.04])

          p.(
            "R-toe-#{i}",
            "R Toe stitching rehearsal #{i + 1}",
            "office-road",
            "clip fixture",
            G.box(M.sub(pnt, [0.025, 0.025, 0.025]), M.add(pnt, [0.025, 0.025, 0.025])),
            :rehearsal,
            "two Toe appointment previews, not actual stitching",
            %{construction_layer: 4, actual_stitching: false}
          )
        end
      else
        []
      end

    course_parts =
      Enum.map(course.segments, fn seg ->
        p.(
          seg.id,
          seg.label,
          seg.id,
          "prospective JANUSITE ribbon",
          seg.geometry,
          :prospective,
          "same source course; no acquired turn",
          %{
            course_id: course.id,
            section_range: [seg.first, seg.first + seg.count],
            points: seg.points,
            construction_layer: 5,
            yellow: seg.yellow,
            material_provenance: course.provenance,
            dimensions: %{width: 0.18, thickness: 0.02},
            registration:
              case seg.id do
                "upper-loop" -> course.upper_loop
                "under-curve" -> course.undercurve
                _ -> %{basis: "GalleryCourse shared source sections"}
              end
          }
        )
      end)

    subsequent =
      p.(
        "subsequent-up",
        "Subsequent material UP OVER toward PITTONING",
        "subsequent-up",
        "prospective furnishing",
        G.sweep([course.pin_center, [7.5, 4.5, -2]], 0.18, 0.02),
        :prospective,
        "future material, distinct from flat PINNING and acquired Footing",
        %{
          points: [course.pin_center, [7.5, 4.5, -2]],
          lifecycle: :subsequent_material,
          construction_layer: 5,
          yellow: [:material_to_pinning_join, :actual_pittoning]
        }
      )

    interpolation_parts =
      [
        p.(
          "interpolation",
          "THREE TO FOUR · prospective JANUSITE wedging",
          "interpolation-material",
          "prospective JANUSITE",
          study.material,
          :prospective,
          "Human fashioning/refashioning; no acquired Footing",
          %{
            points: study.points,
            source_study: study.id,
            construction_layer: 5,
            display_geometry:
              if(s.interpolation_projection?,
                do: study.projection.display_mesh,
                else: study.material
              ),
            projection_only: s.interpolation_projection?,
            material_geometry: :candidate,
            working_band_y: study.working_band_y,
            yellow: study.yellow
          }
        ),
        p.(
          "offset-arc",
          "Reference arc · ceiling BEFORE current Tunnel return",
          "offset-references",
          "reference",
          empty,
          :reference,
          "COB circuit comparison; actual Traversaling unproved",
          %{
            lines: [study.reference_arc] ++ Enum.map(study.references, &[&1.arc_point, &1.point]),
            circuit: study.circuit,
            offset: study.offset,
            construction_layer: 5,
            yellow: [:reference_arc_mount, :physical_incidence]
          }
        ),
        p.(
          "conditional-passage",
          "Conditional appointmenting · proposal only",
          "conditional-appointment",
          "reference",
          empty,
          :yellow,
          "separate from material and Projectioning",
          %{
            appointment: study.appointment,
            lines:
              if(s.passage_appointment?,
                do: [[hd(study.references).point, List.last(study.references).point]],
                else: []
              ),
            construction_layer: 5,
            yellow: [:opening_condition, :closing_condition, :lawful_passage]
          }
        )
      ] ++
        Enum.map(study.references, fn ref ->
          p.(
            ref.id,
            ref.label,
            "offset-references",
            "reference plate",
            G.box(M.add(ref.point, [-0.12, -0.01, -0.12]), M.add(ref.point, [0.12, 0.01, 0.12])),
            :prospective,
            "candidate incidence; not an acquired ceiling or appointed Tunnel",
            %{
              reference: ref,
              construction_layer: 5,
              yellow: [:physical_incidence, :source_to_arc_registration]
            }
          )
        end)

    double_parts =
      Enum.map(double.segments, fn seg ->
        p.(
          seg.id,
          String.replace(seg.id, "double-", "") <> " · same Gallery Door",
          "double-material",
          "prospective YT String",
          seg.geometry,
          :prospective,
          seg.office,
          %{
            course_id: double.id,
            source_segment: seg.id,
            door_identity: seg.door_id,
            points: seg.points,
            section_range: [seg.first, seg.first + seg.count],
            construction_layer: 5,
            yellow: double.yellow,
            actual_semantical_appointment: nil
          }
        )
      end) ++
        [
          p.(
            "double-registration",
            "Prospective four-point furnishing · incidence UNPROVED",
            "double-incidence",
            "reference",
            empty,
            :yellow,
            "two passages; no four points inferred from projection",
            %{
              quadranglementing: double.quadranglementing,
              incidence: double.incidence,
              door_identity: double.door.id,
              lifecycle: double.lifecycle,
              construction_layer: 5,
              yellow: double.yellow,
              lines: [double.door.frame_points]
            }
          )
        ] ++
        Enum.with_index(double.quadranglementing.measured_boundary_points, fn point, i ->
          p.(
            "double-incidence-#{i + 1}",
            "Measured boundary incidence #{i + 1} · not appointed contact",
            "double-incidence",
            "reference marker",
            G.box(M.sub(point, [0.006, 0.006, 0.006]), M.add(point, [0.006, 0.006, 0.006])),
            :reference,
            "computed finite stock / Gallery plane intersection",
            %{
              points: [point],
              construction_layer: 5,
              yellow: [:four_point_incidence],
              measured_not_appointed: true
            }
          )
        end)

    parts =
      Enum.map(
        parts ++
          feet ++ toes ++ course_parts ++ [subsequent] ++ interpolation_parts ++ double_parts,
        &enrich/1
      )

    %{
      digest_profile: "co-building-canonical-json-v1",
      double_passage:
        double
        |> Map.drop([:geometry, :segments, :sightline])
        |> Map.put(:sightline, Map.drop(double.sightline, [:corridor])),
      double_clearance: %{
        gallery_frame_interference:
          G.collision?(double.geometry, G.pipe(double.door.frame_points, 0.025, 0.012, 8)),
        stable_aperture_interference: G.collision?(double.geometry, root),
        scope: :named_pairs_only
      },
      three_four: Map.drop(study, [:material, :projection]),
      interpolation_projection: Map.drop(study.projection, [:display_mesh]),
      interpolation_clearance: %{
        aperture_interference: G.collision?(study.material, root),
        previous_wedge_interference:
          G.collision?(study.material, wa) or G.collision?(study.material, wb_source),
        inherited_material_interference: G.collision?(study.material, standing_mesh),
        scope: :named_pairs_only_not_passage_certification
      },
      gallery_course: Map.drop(course, [:geometry, :segments]),
      material_lifecycle: %{
        inherited_standing: "cb:standing-material",
        inherited_receipt: nil,
        flat_pinning: "cb:next-fold",
        subsequent_material: "cb:subsequent-up",
        acquired_next_footing: nil
      },
      algorithm: @version,
      contract: @contract,
      turn_id: "co-building-preview-turn-ZERO",
      scope: :material_rehearsal,
      parts: parts,
      zero: @zero,
      one: @one,
      three: @three,
      unit: floor_unit,
      frame: %{
        source_minimum: [0, 0, 0],
        source_maximum: [6, 6, 6],
        translation: @zero,
        measure: [6, 6, 6]
      },
      inherited: %{
        diagonal_A: [[0, 0, 0], [6, 6, 0]],
        diagonal_B: [[0, 6, 0], [6, 0, 0]],
        old_zero_to_one: HereWedging.model().unit,
        old_table: HereWedging.model().table,
        failed_snail_height: HereWedging.model().snail.height_range
      },
      clearance: %{
        wedge_miter_interference: G.collision?(wa, wb_source),
        wedge_trial_interference: G.collision?(wa, wb),
        wedge_miter_contact_area:
          min(G.cap_area(wa, [1, 1, 0], 3.08), G.cap_area(wb_source, [1, 1, 0], 3.08)),
        wedge_to_cylinder: G.collision?(wa, root) or G.collision?(wb_source, root),
        zero_leverage_to_bore: G.collision?(leverage, root),
        axle_radial_margin: 0.10 * :math.cos(:math.pi() / 16) - :math.sqrt(2) * 0.06,
        table_bearing_radial_gap: 0.0,
        table_bearing_overlap_y: 0.04,
        door_to_prospective_road: G.collision?(door, road_mesh),
        m_xt_distance_to_zero: :math.sqrt(:math.pow(1.5, 2) + :math.pow(3.52, 2)),
        return_join_gap: course.endpoint_gap,
        return_join_certified: false,
        course_to_aperture_interference: G.collision?(course.geometry, root),
        loop_to_departure_interference:
          G.collision?(Enum.at(course.segments, 3).geometry, Enum.at(course.segments, 2).geometry),
        return_to_zero_interference: G.collision?(return_mesh, root),
        status: :measured_candidates_not_manufacturing_certification
      },
      material_sources: ~w(cb:inkwell cb:doll-source cb:endless-source),
      tools: ~w(cb:quilling-needle),
      acquisition: %{
        delta: 0,
        actual_next_footing: nil,
        actual_pittoning: nil,
        actual_stitching: false,
        completed_re_step: false,
        actual_cob_traversaling: nil
      },
      readiness: :reference_ready_for_enfurnishing_inspection,
      physical_certification: :not_claimed,
      pending: %{
        return_twist: :yellow,
        opening_condition: :not_appointed,
        closing_condition: :not_appointed,
        next_origin: nil,
        circuit_ceiling_encounters:
          "candidate ceiling incidence at 90 degrees before current Tunnel reference at 270 degrees; physical incidence unproved"
      }
    }
  end

  def circuit_point(phi),
    do: [
      3 + 1.3 * :math.sin(phi * :math.pi() / 180),
      3.6,
      -3 + 1.3 * :math.cos(phi * :math.pi() / 180)
    ]

  defp enrich(p) do
    Map.merge(p, %{
      vertices: p.geometry.vertices,
      face_normals: Enum.map(p.geometry.faces, &G.normal/1),
      source_hash: digest(p.source_geometry)
    })
  end

  def digest_profile, do: "co-building-canonical-json-v1"

  def digest(x),
    do: :crypto.hash(:sha256, Jason.encode!(canonical(x))) |> Base.encode16(case: :lower)

  # Encode maps as sorted, typed pairs: JSON map iteration order is not a source identity.
  defp canonical(x) when is_map(x) do
    entries = x |> Map.to_list() |> Enum.map(fn {k, v} -> [canonical(k), canonical(v)] end)
    ["map", Enum.sort_by(entries, fn [k, _] -> Jason.encode!(k) end)]
  end

  defp canonical(x) when is_list(x), do: ["list", Enum.map(x, &canonical/1)]

  defp canonical(x) when is_tuple(x),
    do: ["tuple", x |> Tuple.to_list() |> Enum.map(&canonical/1)]

  defp canonical(x) when is_atom(x), do: ["atom", Atom.to_string(x)]
  defp canonical(x), do: x

  def source_digest(m),
    do: digest(Enum.map(m.parts, &{&1.id, &1.source_hash}) |> Enum.map(&Tuple.to_list/1))

  def selected(m, id), do: Enum.find(m.parts, &(&1.id == id))

  def visible?(p, s) do
    isolated =
      is_nil(s.isolate) or s.isolate == p.group or s.isolate == p.id or
        (s.isolate == "cb:segmentation" and p.group == "wedges") or
        (s.isolate == "cb:tail-return" and p.group in @course_groups) or
        (s.isolate == "cb:under-curve" and p.id == "cb:seat") or
        (s.isolate in ["double-passage", "cb:double-registration"] and
           (p.group in @double_groups or p.group == "aperture" or p.id in ~w(cb:slate cb:seat))) or
        (s.isolate == "three-four" and
           (p.group in ~w(interpolation-material offset-references conditional-appointment wedges aperture office-standing) or
              p.id == "cb:circuit-cursor"))

    Map.fetch!(s.layers, p.group) and p.construction_layer <= s.layer and isolated
  end

  def camera(s) do
    {eye, target, orthographic} =
      case s.view do
        "flat" -> {[3, 2, -12], [3, 2, 0], true}
        "gallery-close" -> {[3, 2.4, -12], [3, 2.4, -1.035], true}
        "side" -> {[15, 3, -2], [3, 3, -2], true}
        "plan" -> {[4, 15, -1], [4, 0, -1], true}
        "transverse" -> {[12, 9, -2], @three, true}
        "tunneling" -> {M.add(@one, [0, 0.63, 0]), [3, 3.6, -1.7], false}
        "tunneling-under" -> {M.add(@one, [0, 0.63, 0]), [3, 0.15, -3.6], false}
        "groundside" -> {[5, -5, -7], @three, true}
        "fieldside" -> {[5, 5, 9], @three, true}
        _ -> {[12, 9, -13], [4, 2, -1], true}
      end

    {eye, target} =
      if s.view in ["tunneling", "tunneling-under"],
        do: {eye, G.rotate_y(target, eye, s.yaw)},
        else: {G.rotate_y(eye, target, s.yaw), target}

    forward = M.unit(M.sub(target, eye))
    up_reference = if abs(M.dot(forward, [0, 1, 0])) > 0.95, do: [0, 0, 1], else: [0, 1, 0]
    right = M.unit(M.cross(up_reference, forward))
    up = M.cross(forward, right)

    %{
      eye: eye,
      target: target,
      forward: forward,
      right: right,
      up: up,
      orthographic: orthographic,
      scale: if(orthographic, do: if(s.view == "gallery-close", do: 300, else: 50), else: 150),
      half: s.view == "half",
      meaning:
        if(s.view in ["tunneling", "tunneling-under"],
          do: "Pretend seated eye offset .63; not physical optical calibration",
          else: "source-coordinate inspection chart; Human not transported"
        )
    }
  end

  def project(p, s), do: project_camera(p, camera(s))

  def project_camera(p, c) do
    origin = if c.orthographic, do: c.target, else: c.eye
    q = M.sub(p, origin)
    depth = M.dot(M.sub(p, c.eye), c.forward)
    factor = if c.orthographic, do: c.scale, else: c.scale / max(0.3, depth)
    [420 + M.dot(q, c.right) * factor, 310 - M.dot(q, c.up) * factor, depth]
  end

  def points(ps, s),
    do:
      Enum.map_join(ps, " ", fn p ->
        [x, y, _] = project(p, s)
        "#{x},#{y}"
      end)

  def visibility(p, s, m) do
    cond do
      not visible?(p, s) ->
        :hidden_by_overlay

      p.geometry.vertices == [] ->
        :reference_only

      p.id == "cb:R" and abs(M.dot(p.plane_normal, camera(s).forward)) < 0.025 ->
        :edge_on

      true ->
        center = G.centroid(p.geometry.vertices)
        [x, y, depth] = project(center, s)

        cond do
          depth <= 0 -> :behind_inspection_eye
          x < 0 or x > 840 or y < 0 or y > 620 or (s.view == "half" and x < 420) -> :outside_view
          occluded?(center, p, s, m) -> :occluded
          true -> :visible
        end
    end
  end

  defp occluded?(center, p, s, m) do
    c = camera(s)
    origin = if c.orthographic, do: M.sub(center, M.scale(c.forward, 30)), else: c.eye
    dir = M.unit(M.sub(center, origin))
    dist = M.distance(center, origin)

    Enum.any?(m.parts, fn other ->
      if other.id != p.id and other.group in ~w(metal aperture) and visible?(other, s) and
           other.geometry.faces != [] do
        hit = G.ray(origin, dir, other.geometry.faces)
        not is_nil(hit) and hit < dist - 0.04
      else
        false
      end
    end)
  end

  def render_faces(m, s) do
    m.parts
    |> Enum.filter(&(visible?(&1, s) and &1.geometry.faces != []))
    |> Enum.flat_map(fn p ->
      g = Map.get(p, :display_geometry, p.geometry)

      if p.id == "cb:R" and
           visibility(p, s, m) in [:edge_on, :behind_inspection_eye, :outside_view, :occluded] do
        []
      else
        Enum.with_index(g.faces)
        |> Enum.map(fn {face, i} ->
          %{
            part: p,
            index: i,
            points: points(face, s),
            depth: Enum.at(project(G.centroid(face), s), 2)
          }
        end)
        |> Enum.filter(&(&1.depth > 0))
      end
    end)
    |> Enum.sort_by(&(-&1.depth))
  end

  defp glyph(letter, f) do
    strokes =
      case letter do
        "R" ->
          [
            [[0, 0], [0, 0.7]],
            [[0, 0.7], [0.45, 0.7], [0.45, 0.38], [0, 0.38]],
            [[0.17, 0.38], [0.48, 0]]
          ]

        "M" ->
          [[[0, 0], [0, 0.7], [0.25, 0.3], [0.5, 0.7], [0.5, 0]]]
      end

    normal = M.unit(M.cross(M.sub(f.([1, 0]), f.([0, 0])), M.sub(f.([0, 1]), f.([0, 0]))))

    cells =
      for line <- strokes, [a, b] <- Enum.chunk_every(line, 2, 1, :discard) do
        G.strap(f.(a), f.(b), 0.035, 0.012, normal)
      end

    %{
      vertices: Enum.flat_map(cells, & &1.vertices),
      faces: Enum.flat_map(cells, & &1.faces),
      cells: cells
    }
  end
end
