defmodule PublicSituationMachineTurnZero.Workshop.RoomToyBox do
  @moduledoc "Source-preserving prospective ROOM Toy Box. No PITTONING, PUFFING or acquisition adapter."
  alias PublicSituationMachineTurnZero.Workshop.{
    CoBuilding,
    CoBuildingGeometry,
    MaterialRibbon,
    RoomRibbon,
    HereWedging
  }

  alias CoBuilding, as: C
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M
  @minimum [1.5, 0, -5.5]
  @maximum [7.5, 6, 0.5]
  @views ~w(flat left right oblique two five ground field)
  @movements ~w(room wedging pinning stands)
  def contract, do: "geometry-table-2026-11-16.v11"
  def views, do: @views
  def movements, do: @movements

  def new,
    do: %{
      revision: 0,
      view: "oblique",
      movement: "room",
      pins: [],
      travel: 0.0,
      door: 0.0,
      projection?: false,
      selected: "room:volume",
      events: [],
      notice: nil
    }

  def change(s, r, command) when r == s.revision do
    case update(s, command) do
      {:ok, n, kind} ->
        event = %{
          sequence: r + 1,
          kind: kind,
          command: inspect(command),
          scope: :prospective_rehearsal,
          acquired_delta: 0
        }

        {:ok, %{n | revision: r + 1, events: Enum.take(s.events ++ [event], -64), notice: nil}}

      e ->
        e
    end
  end

  def change(_, _, _), do: {:error, :stale}
  defp update(s, {:view, v}) when v in @views, do: {:ok, %{s | view: v}, :regarding}
  defp update(s, {:movement, v}) when v in @movements, do: {:ok, %{s | movement: v}, :inspection}

  defp update(s, {:select, id}) when is_binary(id) do
    if Enum.any?(model(s).pieces, &(&1.id == id)),
      do: {:ok, %{s | selected: id}, :inspection},
      else: {:error, :unknown_source}
  end

  defp update(s, {:pin, n}) when n in 1..3 do
    cond do
      n in s.pins ->
        {:ok, s, :already_rehearsed}

      n == length(s.pins) + 1 ->
        {:ok,
         %{
           s
           | pins: s.pins ++ [n],
             movement: "pinning",
             travel: if(n == 3, do: 1.0, else: s.travel)
         }, :pinning_rehearsal}

      true ->
        {:error, :preceding_hold_required}
    end
  end

  defp update(s, {:door, v}) when is_number(v) and v >= 0 and v <= 90,
    do: {:ok, %{s | door: v}, :material_pivot_rehearsal}

  defp update(s, {:travel, v}) when is_number(v) and v >= 0 and v <= 1,
    do: {:ok, %{s | travel: v, movement: "pinning"}, :material_pose_rehearsal}

  defp update(s, :projection), do: {:ok, %{s | projection?: !s.projection?}, :projection_only}
  defp update(_, _), do: {:error, :constitutional_means_not_furnished}

  def bounds(%{vertices: []}), do: nil

  def bounds(mesh),
    do:
      for(
        i <- 0..2,
        do: Enum.map(mesh.vertices, &Enum.at(&1, i)) |> Enum.min_max() |> Tuple.to_list()
      )

  def inside?(point),
    do:
      Enum.all?(0..2, fn i ->
        Enum.at(point, i) >= Enum.at(@minimum, i) - 1.0e-8 and
          Enum.at(point, i) <= Enum.at(@maximum, i) + 1.0e-8
      end)

  def model(s) do
    old = C.model(%{C.new() | door: s.door})

    inherited =
      Enum.filter(old.parts, fn p ->
        p.group in ~w(metal aperture sources) or
          p.id in ~w(cb:monitor cb:glass cb:stage-door cb:wedge-A cb:wedge-B cb:standing-material cb:yt-pipe cb:ground-side cb:field-side cb:HERE cb:standing-circle)
      end)

    get = fn id -> C.selected(old, id) end
    table = old.three
    seat = old.one
    eye = M.add(seat, [0, 0.63, 0])
    forward = M.unit(M.sub(table, eye))
    across = M.unit(M.cross([0, 1, 0], forward))
    plane = M.unit(M.cross(across, forward))
    four = M.add(table, forward)
    gauge6 = Enum.find(M.gauges(), &(&1.axis == "x" and &1.label == 6))
    five = M.add(table, M.scale(forward, gauge6.radius))

    native = fn gauge ->
      Enum.map(gauge.points, fn p ->
        {:ok, q} = M.transform(p, "motor-to-steeling-u13-v1")
        q
      end)
    end

    gauge4 = Enum.find(M.gauges(), &(&1.axis == "x" and &1.label == 4))
    quarter = native.(gauge4)

    on_u = fn [_, y, z], hand ->
      M.add(table, M.add(M.scale(across, hand * z), M.scale(forward, y)))
    end

    inner =
      Enum.map(quarter, &on_u.(&1, 1)) ++ tl(Enum.reverse(Enum.map(quarter, &on_u.(&1, -1))))

    outer_source = Enum.find(M.crossing().objects, &(&1.id == "u-outer"))

    outer_points =
      Enum.map([3, 0, 1, 2], fn i ->
        [x, y, _] = Enum.at(outer_source.source_points, i)
        M.add(table, M.add(M.scale(across, x - 15), M.scale(forward, y - 3)))
      end)

    within_dir = M.unit(M.add(M.scale(across, -1), plane))
    within_len = 1.2 * :math.sqrt(2)

    within_points = [
      M.sub(four, M.scale(within_dir, within_len / 2)),
      M.add(four, M.scale(within_dir, within_len / 2))
    ]

    ribbon = RoomRibbon.model(table, four)
    bar = G.sweep([@minimum, @maximum], 0.08, 0.04) |> Map.fetch!(:cells) |> hd()

    bar =
      Enum.reduce(0..2, bar, fn i, mesh ->
        axis = for j <- 0..2, do: if(i == j, do: 1, else: 0)

        mesh
        |> G.clip(axis, Enum.at(@minimum, i))
        |> G.clip(M.scale(axis, -1), -Enum.at(@maximum, i))
      end)

    corners = for x <- [1.5, 7.5], y <- [0, 6], z <- [-5.5, 0.5], do: [x, y, z]

    edges =
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
          ],
          do: [Enum.at(corners, a), Enum.at(corners, b)]

    empty = %{vertices: [], faces: []}

    piece = fn id, name, mesh, office, extra ->
      Map.merge(
        %{
          id: id,
          name: name,
          geometry: mesh,
          source_geometry: mesh,
          source_identity: id,
          material_office: office,
          standing_locality: "inherited world frame; Groundward ZERO and fixed Seat ONE",
          bearing: "registered finite/reference relations",
          attachment: :yellow_not_manufactured,
          inheritance: ~w(cb:slate cb:square-axle cb:zero),
          affordment: :inspection_only,
          regarding: @views,
          status: :prospective,
          evidence: %{constructor: "RoomToyBox.model/1", unit: "trial extent"},
          yellow: [],
          movement: "room",
          lines: []
        },
        extra
      )
    end

    core =
      Enum.map(inherited, fn p ->
        piece.(p.id, p.name, p.geometry, p.office, %{
          source_geometry: p.source_geometry,
          lines: Map.get(p, :lines, []),
          movement: if(p.id in ~w(cb:ground-side cb:field-side), do: "stands", else: "room"),
          source_identity: p.source_id,
          source_hash: p.source_hash,
          inheritance: [p.source_id],
          status:
            if(p.geometry.vertices == [],
              do: :inherited_reference,
              else: :inherited_material_fixture
            ),
          attachment: p.attachment,
          bearing: %{
            inherited_v10_from: p.from,
            inherited_v10_toward: p.toward,
            material_direction:
              if(p.id == "cb:square-axle",
                do:
                  "FROM DOWN UNDER TOWARD fixed ONE; Groundward target appointment remains distinct",
                else: p.office
              ),
            pivot: p.pivot,
            plane_normal: p.plane_normal,
            source_frame: p.frame
          },
          yellow: p.yellow,
          material_office:
            if(p.id == "cb:square-axle",
              do: "FROM DOWN UNDER Seat; Gallery ZERO TO ONE material registration",
              else: p.office
            ),
          evidence: %{
            constructor: "CoBuilding.model/1 preserved source mesh",
            original_office: p.office,
            source_plane_normal: p.plane_normal,
            measured_bounds: bounds(p.geometry)
          }
        })
      end)

    r = get.("cb:R").source_geometry
    rposed = if 1 in s.pins, do: G.translate(r, [0, -1.7, -0.96]), else: get.("cb:R").geometry
    msource_anchor = [3.55, 2.4, -1.04]
    msource = G.translate(m_glyph(), msource_anchor)
    f = RoomRibbon.frame_at(ribbon, s.travel)

    posed =
      G.transform(msource, fn point ->
        [x, y, z] = M.sub(point, msource_anchor)
        M.add(f.point, M.add(M.scale(f.tangent, x), M.add(M.scale(f.u, y), M.scale(f.v, z))))
      end)

    projected =
      G.transform(posed, fn point ->
        q = M.sub(point, f.point)
        [3.25 + M.dot(q, f.tangent), 2.4 + M.dot(q, f.u), -1.04]
      end)

    gauge6 = Enum.find(M.gauges(), &(&1.axis == "x" and &1.label == 6))
    center = M.scale(M.add(@minimum, @maximum), 0.5)

    central_arc =
      Enum.map(native.(gauge6), fn [_, y, z] ->
        M.add(center, M.add(M.scale(across, z), M.scale(forward, y)))
      end)

    six = HereWedging.model().snail.sixth_purchase
    eighth = Enum.find(old.parts, &(&1.id == "cb:EIGHT")).regions |> List.last()

    additions = [
      piece.(
        "room:volume",
        "ROOM · invariant SIX CUBICAL",
        empty,
        "correspondencing volume containing fixed Seat and Table",
        %{
          lines: edges,
          attachment: :reference_not_enclosure,
          evidence: %{
            bounds: [@minimum, @maximum],
            measure: [6, 6, 6],
            registration: "room-from-axle-v1"
          },
          yellow: [:subfloor_foundation_interface, :corner_to_ZERO_purchase]
        }
      ),
      piece.(
        "room:body-bearing",
        "XT TOWARD YT · THROUGH ROOM",
        bar,
        "finite opposite-corner geometric reference",
        %{
          lines: [[@minimum, @maximum]],
          bearing: "SIX X / SIX UP / SIX depth",
          evidence: %{
            length: M.distance(@minimum, @maximum),
            elevation: :math.asin(1 / :math.sqrt(3)) * 180 / :math.pi(),
            flat_angle: 45,
            clipped_ends: true
          },
          yellow: [:corner_purchase, :load]
        }
      ),
      piece.(
        "room:zero-one",
        "ZERO TO ONE · THROUGH the fixed square axle",
        empty,
        "material standing FROM DOWN UNDER",
        %{
          lines: [[old.zero, [3, 0, -3], seat]],
          source_identity: "room:zero-one",
          bearing: "ZERO register BY WAY OF inherited leverage / axle axis TOWARD ONE",
          attachment: "existing axle, ONE bearing, ZERO-to-ONE leverage; no moved support",
          evidence: %{
            axle_unit: [[3, 0, -3], seat],
            unit_height: 1,
            root_to_axle_offset: [0, 0, -1],
            axle_source_identity: "cb:square-axle",
            axle_source_hash: get.("cb:square-axle").source_hash,
            gallery: "gallery-door:1"
          },
          yellow: [:material_coupling_proof]
        }
      ),
      piece.(
        "room:r-wall",
        "First PINNING · R-held SIX standing bearing",
        G.box([2.94, 0, -2.01], [3.06, 6, -1.99]),
        "TOWARD ZERO; prospective full UP reference; lawful inheritance for later two-PINNING work remains YELLOW",
        %{
          movement: "pinning",
          bearing: "SIX UP FROM ZERO",
          source_identity: "room-ribbon:1/first-wall",
          affordment: :pinning_rehearsal,
          attachment: :prospective_R_hold_not_PITTONING,
          yellow: [:ink_attachment, :wall_to_ribbon_join]
        }
      ),
      piece.(
        "room:outer-u",
        "Outer U · structural railing trial",
        G.pipe(outer_points, 0.04, 0.02, 8),
        "larger supporting U",
        %{
          movement: "wedging",
          lines: [outer_points],
          source_identity: "room:outer-u",
          evidence: %{
            definition_source: "A04:u-outer/three-edge-excerpt",
            native: outer_source.source_points,
            transform: %{origin: table, across: across, up: forward}
          },
          yellow: [:load, :mount]
        }
      ),
      piece.(
        "room:inner-u",
        "Inner U · curved Regarding",
        G.pipe(inner, 0.025, 0.012, 8),
        "second PINNING curve registered through Table THREE",
        %{
          movement: "wedging",
          lines: [inner],
          source_identity: "room:inner-u",
          evidence: %{
            definition_source: gauge4.id,
            native_quarter: quarter,
            registration_center: table,
            radius: gauge4.radius,
            axes: [across, forward]
          },
          yellow: [:material_join, :optical_correspondence]
        }
      ),
      piece.(
        "room:within-u",
        "U within U · invariant 45° transverse",
        G.strap(hd(within_points), List.last(within_points), 0.03, 0.012, forward),
        "45° ALONG THROUGH curved material frame",
        %{
          movement: "wedging",
          lines: [within_points],
          source_identity: "room:within-u",
          evidence: %{
            definition_source: "A04:u-within-u/diagonal",
            length: within_len,
            tangent: M.scale(across, -1),
            transverse: plane,
            direction: within_dir,
            angle_degrees: 45
          },
          yellow: [:joining, :turn_inheritance]
        }
      ),
      piece.(
        "room:segmentation",
        "SIXTH THROUGH EIGHTH · shared wedging",
        empty,
        "source comparison toward cb:segmentation; no invented shell join",
        %{
          movement: "wedging",
          lines: [[six.target, old.zero], [hd(eighth.points), old.zero]],
          evidence: %{
            sixth: six,
            eighth: eighth,
            common_wedge: "cb:segmentation",
            physical_transform: nil
          },
          yellow: [:source_to_shell_transform, :occupied_seam, :historical_failed_fit]
        }
      ),
      piece.(
        "room:ribbon",
        "Continuous JANUSITE · UNDER and AROUND",
        ribbon.geometry,
        "third PINNING enclosing return; no PITTONING conversion",
        %{
          movement: "pinning",
          source_identity: ribbon.id,
          lines: [ribbon.points],
          affordment: :material_pose_rehearsal,
          evidence: %{
            width: ribbon.width,
            thickness: ribbon.thickness,
            twist_degrees: ribbon.twist_degrees,
            twist_interval: ribbon.twist_interval,
            separately_addressed_passages: ribbon.passages
          },
          yellow: [:bend_law, :supply, :ink_attachment, :return_conversion]
        }
      ),
      piece.(
        "room:R",
        "R · inherited Head of String",
        rposed,
        "first PINNING participation; not a six-high glyph",
        %{
          movement: "pinning",
          source_identity: "specimen:R:1",
          source_geometry: r,
          evidence: %{source_hash: C.digest(r)},
          yellow: [:stitching, :PITTONING]
        }
      ),
      piece.(
        "room:M",
        "M · same returned Tail material",
        posed,
        "lays DOWN; optional UP display is Projectioning only",
        %{
          movement: "pinning",
          source_identity: ribbon.source_M,
          source_geometry: msource,
          display_geometry: if(s.projection?, do: projected, else: posed),
          affordment: :source_continuous_pose_rehearsal,
          evidence: %{
            source_hash: C.digest(msource),
            source_anchor: msource_anchor,
            source_plane:
              "Gallery / monitor plane Z=-1.04; glyph rigidly posed in material frame",
            parent_material: ribbon.id,
            address: 1,
            pose_parameter: s.travel,
            material_normal: f.v,
            projection_only: s.projection?,
            projection_basis: %{
              source_point: f.point,
              x_axis: f.tangent,
              y_axis: f.u,
              target: [3.25, 2.4, -1.04]
            },
            native_ROOM_tail:
              "janusite:577fba0b80d791636e583ebc868cf72baf53b9c32e18d501355f2a4fca8820cd/letter-4; semantic ancestry only, not a geometry alias",
            legacy_template_identity: "return-template:M:1 remains historical"
          },
          yellow: [:source_ink_to_ribbon_attachment, :PITTONING]
        }
      ),
      piece.(
        "room:six-arc",
        "SIX central reference arc",
        empty,
        "central extent; distinct from local YT circuit and Public Field",
        %{
          movement: "stands",
          lines: [central_arc],
          source_identity: "room:six-arc",
          evidence: %{definition_source: gauge6.id, center: center, radius: gauge6.radius},
          yellow: [:physical_arc_mount]
        }
      ),
      piece.(
        "room:stand-bearings",
        "TWO / FIVE THROUGH FOUR TOWARD THREE",
        empty,
        "reciprocal Regarding registration; no second Human Seat",
        %{
          movement: "stands",
          lines: [[eye, table, four, five]],
          evidence: %{
            two: eye,
            three: table,
            four: four,
            five: five,
            forward: forward,
            reciprocal: M.scale(forward, -1)
          },
          yellow: [:physical_optics]
        }
      ),
      piece.(
        "room:eight",
        "EIGHT · Snail segmentation inscription",
        empty,
        "FROM U THROUGH U TOWARD seated HERE; up/downshift office reserved",
        %{
          movement: "stands",
          lines: [eighth.points],
          source_identity: "room:eight",
          evidence: Map.put(eighth, :definition_source, eighth.id),
          yellow: [:snail_mount, :downshift_upshift_mechanism]
        }
      )
    ]

    pieces =
      Enum.map(core ++ additions, fn p ->
        p
        |> Map.put(:standing_locality, %{
          frame: "inherited world axes; fixed ONE",
          occupied_bounds: bounds(p.geometry),
          reference_courses: p.lines,
          source_identity: p.source_identity,
          Groundward_registration: "cb:square-axle / ZERO TO ONE"
        })
        |> Map.put(
          :content_hash,
          C.digest(%{identity: p.source_identity, geometry: p.source_geometry, lines: p.lines})
        )
      end)

    occupied = Enum.filter(core, &(&1.geometry.vertices != []))

    containment =
      Enum.map(occupied, fn p ->
        %{
          id: p.id,
          bounds: bounds(p.geometry),
          all_inside: Enum.all?(p.geometry.vertices, &inside?/1),
          only_subfloor_exception:
            Enum.all?(p.geometry.vertices, fn [x, y, z] ->
              x >= 1.5 - 1.0e-8 and x <= 7.5 + 1.0e-8 and z >= -5.5 and z <= 0.5 and y >= -0.4 and
                y <= 6
            end)
        }
      end)

    obstacles =
      ~w(cb:square-axle cb:seat cb:seat-back cb:zero cb:zero-square cb:table cb:pivot-one cb:pivot-three cb:globe cb:globe-adapter cb:standing-material cb:over-across cb:slate) ++
        Enum.map(
          Enum.filter(inherited, &String.starts_with?(&1.id, "cb:quadranglement-")),
          & &1.id
        )

    clearance =
      Map.new(obstacles, fn id ->
        {id, G.collision?(ribbon.geometry, get.(id).source_geometry)}
      end)

    stands = [
      %{
        id: "SIX",
        kind: :standing_stand,
        material: "room:body-bearing",
        reference: "room:six-arc",
        point: center
      },
      %{
        id: "FOUR",
        kind: :standing_stand,
        material: "room:inner-u",
        point: four,
        office: :WHERE_WITHIN_airiness_gauge,
        measurement_law: :yellow
      },
      %{
        id: "EIGHT",
        kind: :standing_stand,
        material: "room:eight",
        point: hd(eighth.points),
        office: :segmentation_not_distance
      },
      %{id: "TWO", kind: :regarding_stand, point: eye, target: table, physical_seat: "cb:seat"},
      %{
        id: "FIVE",
        kind: :regarding_stand,
        point: five,
        through: four,
        target: table,
        physical_seat: "cb:seat"
      }
    ]

    %{
      contract: contract(),
      pieces: pieces,
      frame: %{
        id: "room-from-axle-v1",
        minimum: @minimum,
        maximum: @maximum,
        measure: [6, 6, 6],
        inherited_old_frame: old.frame
      },
      zero: old.zero,
      one: seat,
      three: table,
      four: four,
      five: five,
      two: eye,
      stands: stands,
      ribbon: ribbon,
      pins: [
        %{number: 1, toward: "ZERO", locality: old.zero, material: "room:r-wall"},
        %{
          number: 2,
          toward: "TWO / inner U",
          locality: table,
          material_port: M.add(table, [0.1, 0.15, 0]),
          material: "room:inner-u",
          centre_purchase: :yellow
        },
        %{
          number: 3,
          toward: "AROUND ABOUT / DOWN",
          locality: List.last(ribbon.points),
          material: ribbon.id
        }
      ],
      containment: containment,
      clearance: clearance,
      body_bearing: %{
        endpoints: [@minimum, @maximum],
        delta: [6, 6, 6],
        length: 6 * :math.sqrt(3),
        elevation: 35.264389682754654,
        flat_appearance: 45
      },
      foundation: %{
        reference_band_y: [-0.4, 0],
        status: :inherited_Groundward_interface_not_ROOM_enlargement
      },
      zero_one: %{
        axle_identity: "cb:square-axle",
        gallery: "gallery-door:1",
        seat: seat,
        root: old.zero,
        axle_height_interval: [[3, 0, -3], seat],
        root_to_axle_offset: [0, 0, -1],
        office: :FROM_DOWN_UNDER
      },
      bearing_clearance:
        Map.new(Enum.filter(inherited, &(&1.group in ~w(metal aperture))), fn p ->
          {p.id, G.collision?(bar, p.source_geometry)}
        end),
      source_registry: %{
        id: "room-ribbon:1",
        standing_on: "gallery-door:1",
        inscription: "ROOM",
        created_by_pinning: false,
        source_M: "room-ribbon:1/M",
        source_R: "specimen:R:1",
        scope: :prospective_material_inheritance
      },
      joining_diagnostics:
        Map.new(
          Enum.filter(
            additions,
            &(&1.id in ~w(room:r-wall room:inner-u room:outer-u room:within-u room:body-bearing))
          ),
          fn p -> {p.id, G.collision?(ribbon.geometry, p.geometry)} end
        ),
      passage_incidence:
        Enum.map(ribbon.passages, fn passage ->
          cell = Enum.at(ribbon.geometry.cells, hd(passage.indices))
          door = PublicSituationMachineTurnZero.Workshop.DoublePassageStudy.door()

          points =
            PublicSituationMachineTurnZero.Workshop.DoublePassageStudy.plane_incidence(
              cell,
              door.plane_z
            )
            |> Enum.filter(
              &PublicSituationMachineTurnZero.Workshop.DoublePassageStudy.inside_opening?(
                &1,
                door
              )
            )

          Map.merge(passage, %{
            boundary_points: points,
            count: length(points),
            four_point_furnishing: :unproved
          })
        end),
      under_post_vertical_margin_bound: 0.28 - (ribbon.width + ribbon.thickness) / 2,
      port_registration: %{
        reference: table,
        material_point: M.add(table, [0.1, 0.15, 0]),
        gap: M.norm([0.1, 0.15, 0]),
        status: :centre_purchase_unproved
      },
      acquisition: %{
        index_delta: 0,
        actual_next_footing: nil,
        pittoning: :not_performed,
        puffing: :not_performed,
        re_step: :unavailable,
        pending_un_buttoning: :separate_unavailable
      },
      stopped_portions: [
        :subfloor_enclosure_interpretation,
        :SIXTH_EIGHTH_physical_join,
        :ink_and_wall_material_attachment,
        :PITTONING_conversion,
        :airiness_law,
        :actual_COB_traversal
      ],
      movements: [
        %{
          id: 1,
          evidence: :fixed_support_containment_and_body_bearing,
          yellow: [:subfloor_foundation, :corner_purchase]
        },
        %{
          id: 2,
          evidence: :registered_finite_U_trials,
          yellow: [:SIXTH_EIGHTH_join, :optical_mount]
        },
        %{
          id: 3,
          evidence: :continuous_finite_under_return_and_half_twist,
          yellow: [:ink_attachment, :purchase, :constitutive_conversion]
        },
        %{
          id: 4,
          evidence: :source_bound_standing_and_reciprocal_regarding_offices,
          yellow: [:Airiness_law, :physical_optics]
        }
      ]
    }
  end

  def controls do
    Enum.map(
      @views,
      &%{id: "rtb-view-" <> &1, office: "Regarding of unchanged material", kind: :regarding}
    ) ++
      Enum.map(
        @movements,
        &%{id: "rtb-movement-" <> &1, office: "inspect construction movement", kind: :inspection}
      ) ++
      Enum.map(
        1..3,
        &%{
          id: "rtb-pin-#{&1}",
          office: "ordered PINNING rehearsal; no PITTONING",
          kind: :material_rehearsal
        }
      ) ++
      [
        %{
          id: "rtb-travel",
          office: "pose one source-addressed M along finite ribbon",
          kind: :material_rehearsal
        },
        %{
          id: "rtb-door",
          office: "pivot same Stage Door and R source",
          kind: :material_rehearsal
        },
        %{
          id: "rtb-projection",
          office: "change M display using registered material frame",
          kind: :projection
        },
        %{id: "rtb-listing", office: "inspect every source material office", kind: :inspection},
        %{
          id: "rtb-selected-ledger",
          office: "inspect selected material source and purchase",
          kind: :inspection
        },
        %{
          id: "rtb-evidence",
          office: "inspect four movement evidence and stopped portions",
          kind: :inspection
        },
        %{
          id: "rtb-scene polygon[data-piece]",
          office: "select existing finite material",
          kind: :inspection
        },
        %{
          id: "rtb-inspect-*",
          office: "select source piece without furnishing new material",
          kind: :inspection
        },
        %{
          id: "room-historical",
          office: "inspect preserved prior experiments under their versions",
          kind: :historical_inspection
        }
      ]
  end

  defp m_glyph do
    strokes = [
      [[0, 0], [0, 0.42]],
      [[0, 0.42], [0.15, 0.18]],
      [[0.15, 0.18], [0.30, 0.42]],
      [[0.30, 0.42], [0.30, 0]]
    ]

    meshes =
      Enum.map(strokes, fn [[x, y], [u, v]] ->
        G.strap([x - 0.15, y - 0.21, 0], [u - 0.15, v - 0.21, 0], 0.025, 0.012, [0, 0, 1])
      end)

    G.mesh(Enum.flat_map(meshes, & &1.faces))
  end

  def camera(s, m) do
    {eye, target, scale} =
      case s.view do
        "flat" -> {[4.5, 3, -14], [4.5, 3, 0], 60}
        "left" -> {[-5, 6, -10], [4.5, 3, -2.5], 60}
        "right" -> {[14, 6, -10], [4.5, 3, -2.5], 60}
        "two" -> {m.two, m.three, 95}
        "five" -> {m.five, m.three, 110}
        "ground" -> {[7, -5, -9], [4.5, 1.5, -2], 60}
        "field" -> {[7, 7, 9], [4.5, 2, -2], 60}
        _ -> {[13, 10, -14], [4.5, 2.5, -2.5], 60}
      end

    f = M.unit(M.sub(target, eye))
    up = if abs(M.dot(f, [0, 1, 0])) > 0.95, do: [0, 0, 1], else: [0, 1, 0]
    right = M.unit(M.cross(up, f))

    %{
      eye: eye,
      target: target,
      forward: f,
      right: right,
      up: M.cross(f, right),
      scale: scale,
      human_seat: m.one,
      scope: :regarding_only
    }
  end

  def project(p, c) do
    q = M.sub(p, c.target)

    [
      420 + M.dot(q, c.right) * c.scale,
      300 - M.dot(q, c.up) * c.scale,
      M.dot(M.sub(p, c.eye), c.forward)
    ]
  end

  def points(ps, c),
    do:
      Enum.map_join(ps, " ", fn p ->
        [x, y, _] = project(p, c)
        "#{x},#{y}"
      end)

  def visible?(p, s),
    do:
      p.movement == "room" or p.movement == s.movement or
        (s.movement == "stands" and p.movement == "wedging")

  def faces(m, s) do
    c = camera(s, m)

    m.pieces
    |> Enum.filter(&visible?(&1, s))
    |> Enum.flat_map(fn p ->
      Enum.map(Map.get(p, :display_geometry, p.geometry).faces, fn f ->
        %{
          id: p.id,
          points: points(f, c),
          depth: Enum.at(project(G.centroid(f), c), 2),
          status: p.status
        }
      end)
    end)
    |> Enum.sort_by(&(-&1.depth))
  end
end
