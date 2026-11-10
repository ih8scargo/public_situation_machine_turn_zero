defmodule PublicSituationMachineTurnZero.Workshop.SnailGalleryRegistration do
  @moduledoc "Reversible CUBICAL/Gallery inspection. No furnishing, staging resolution or navigation operation."
  alias PublicSituationMachineTurnZero.Workshop.{
    SnailBody,
    SnailWeaveGeometry,
    WedgingGeometry,
    SnailFurnishingConstraints
  }

  def defaults, do: %{"radius" => "0", "orbit" => "0", "spin" => "0", "coupling" => "independent"}

  def parse(p) do
    with {r, ""} <- Float.parse(p["radius"] || ""),
         {o, ""} <- Float.parse(p["orbit"] || ""),
         {s, ""} <- Float.parse(p["spin"] || ""),
         true <- r >= 0 and r <= 3 and o >= 0 and o <= 360 and s >= -180 and s <= 180,
         true <- p["coupling"] in ~w(independent co counter) do
      {:ok, Map.take(p, ~w(radius orbit spin coupling))}
    else
      _ -> {:error, :inspection_parameters}
    end
  end

  def model(state, geometry, params \\ defaults()) do
    r = number(params["radius"])
    orbit = number(params["orbit"])
    spin = number(params["spin"])
    half = (geometry.fixed.here |> Enum.map(&hd/1) |> Enum.max()) * 1.0
    scale = 2 * half / 6
    boundary = Enum.map(WedgingGeometry.outline(), fn {x, z} -> [x, 0, z] end)
    eye = geometry.emergence.registration.revised_eye
    cob_eye = geometry.emergence.registration[:COB_eye]
    eye_relative = sub(cob_eye, eye)

    human_forward = [
      0,
      -sin(geometry.emergence.regard.quarter_turn),
      cos(geometry.emergence.regard.quarter_turn)
    ]

    eye_angle =
      :math.acos(max(-1, min(1, dot(eye_relative, human_forward) / norm(eye_relative)))) * 180 /
        :math.pi()

    walls =
      Enum.filter(
        geometry.emergence.presentation.surfaces,
        &(&1.kind in ~w(corkscrew janusite-wall wedging tunnel pittoning))
      )

    table = Enum.filter(geometry.surfaces, &(&1.kind == "table"))
    table_vertices = Enum.flat_map(table, & &1.points)
    table_radius = table_vertices |> Enum.map(&radial/1) |> Enum.max()
    table_y = table_vertices |> Enum.map(&Enum.at(&1, 1)) |> Enum.min()
    table_face = hd(table)
    table_work = centroid(table_face.points)
    body = SnailBody.model(state["body"], geometry.fold.degrees, geometry.fold.quarter)

    sight_surfaces =
      Enum.reject(geometry.emergence.presentation.surfaces, &(&1.kind == "registration"))

    table_inner = table_vertices |> Enum.map(&radial/1) |> Enum.min()
    yaws = %{"independent" => spin, "co" => spin + orbit, "counter" => spin - orbit}
    yaw = Map.fetch!(yaws, params["coupling"])
    center = [r * cos(orbit), 0, r * sin(orbit)]
    square = square(center, half, yaw)
    cube = square ++ Enum.map(square, &add(&1, [0, 2 * half, 0]))
    proposed_radius = 1.5 * scale

    proposed_table = %{
      nominal_diameter_extents: 3,
      nominal_radius_extents: 1.5,
      comparison_radius: proposed_radius,
      plan_center: [0, 0],
      height: nil,
      thickness: nil,
      inner_profile: nil,
      status:
        "PROPOSED working dimension; not confirmed constitutional geometry. No height or solid inferred.",
      centered_side_inset_extents: 1.5,
      inset_is_pathway: false,
      gallery_plan_margin:
        Enum.map(edges(boundary), fn {a, b} -> abs(dot(a, inward(a, b))) - proposed_radius end)
        |> Enum.min(),
      ghost_rim_containment_margin: rim_margin(square, proposed_radius),
      seat_point_inside_outer_envelope: true,
      cob_base_inside_outer_envelope: radial(cob_eye) <= proposed_radius,
      cob_nearest_plan_rim_distance: abs(proposed_radius - radial(cob_eye)),
      cob_farthest_plan_rim_distance: proposed_radius + radial(cob_eye),
      volumetric_reach: nil,
      physical_fit: nil,
      note:
        "The 1.5-extent centered side difference is arithmetic, not an acquired or traversaling pathway. Craft and stand dimensions remain unknown."
    }

    selected = static_fit(boundary, center, half, yaw)
    collisions = wall_contacts(walls, center, half, yaw)
    next = geometry.landinging_registration.next
    next_vector = sub(next.center, [0, 0, 0])
    next_plan = plan_angle(next_vector)
    heading = [cos(yaw), 0, sin(yaw)]

    approach = %{
      from: [0, 0, 0],
      toward: next.center,
      plan_bearing: next_plan,
      ghost_to_next_plan_bearing: plan_angle(sub(next.center, center)),
      ghost_heading_error: angular_error(yaw, plan_angle(sub(next.center, center))),
      meaning: "HERE TOWARD the original NEXT; not toward the Table."
    }

    radial_range = polygon_radial_range(square)

    planar_table_overlap =
      elem(radial_range, 0) <= table_radius and elem(radial_range, 1) >= table_inner

    material = geometry.near_monitor.flat.material
    source_turns = Enum.filter(state["turns"], &(material && &1["material"] == material["id"]))

    observations =
      Enum.map(0..24, fn i ->
        t = i / 24
        p = SnailBody.arc_point(t)

        %{
          id: "registered-observation-#{i}",
          t: t,
          address: SnailBody.arc_length() * t,
          point: p,
          material: material && material["id"]
        }
      end)

    targets =
      [
        %{id: "NEXT", point: next.center},
        %{id: "prior-annulus-axle-aperture", point: [0, table_y, 0]},
        %{id: "prior-annulus-work-preview", point: table_work},
        %{id: "existing-wedge", point: geometry.fold.tunnel_axis}
      ] ++
        Enum.with_index(boundary, fn p, i -> %{id: "Gallery-vertex-#{i}", point: p} end)

    %{
      version: "cubical-gallery-registration-v1",
      parameters: params,
      furnishing_constraints: SnailFurnishingConstraints.model(state, geometry),
      observed: %{
        gallery: %{
          boundary: boundary,
          source: "WedgingGeometry.outline/0; earlier unitless Gallery study",
          cross_frame_registration:
            "unresolved; identity X/Z overlay is an explicit comparison hypothesis",
          regular: false,
          side_lengths: Enum.map(edges(boundary), fn {a, b} -> norm(sub(b, a)) end),
          radial_min: 2.0,
          radial_max: :math.sqrt(5),
          height: [0, 3]
        },
        axle: %{
          point: [0, 0, 0],
          direction: [0, 1, 0],
          source: "SnailBody spindle; separate from monitor-page axle"
        },
        page_axle: geometry.seat.page_center,
        table: %{
          center: [0, table_y, 0],
          radius: table_radius,
          inner_radius: table_inner,
          mesh: table,
          role:
            "existing ROUND annulus, same plan axle; RE-SURFACING office is a provisional appointment, not a new Table"
        },
        here: %{
          id: "THIS HERE APPROACHING LANDINGING",
          points: geometry.fixed.here,
          reference_extent: [6, 6, 6],
          model_width: 2 * half,
          status:
            "existing planar registration retained; six-unit normal axis awaits wedge UN-FOLDING registration"
        },
        standing: %{
          id: "THIS ONE STANDINGING LANDINGING",
          center: geometry.fixed.landinging.center,
          radius: geometry.fixed.landinging.radius
        },
        next: next,
        walls: walls,
        wall_status:
          "Existing registered body/wedge meshes and provisional Seat-emergence prefix; complete furnished Caterpillar deformation is not established.",
        apertures: %{
          monitor: geometry.near_monitor.flat.plane,
          groundward: geometry.emergence.registration.revised_aperture,
          native_inner: body.instrumentation.inner,
          cabinet_side: Enum.find(body.surfaces, &(&1.id == "cabinet-side-aperture")).points,
          distinction:
            "monitor, inner aperture and cabinet-side aperture remain separate source registrations"
        }
      },
      provisional: %{
        table: proposed_table,
        scale: scale,
        normal_scale_in_existing_planar_matrix: 1,
        volume_embedding:
          "SUPERSEDED normal-axis preview: only wedge UN-FOLDING may furnish the recovered six-unit vertical relation. Historical scaled box metrics are not current clearance evidence.",
        comparison_to_gallery:
          "Identity overlay of the existing Gallery study and body axes; not constitutionally registered.",
        ghost: %{
          center: center,
          points: square,
          historical_cube: cube,
          orbit_degrees: orbit,
          local_spin_degrees: spin,
          world_yaw: yaw,
          heading: heading,
          historical_box_height: 2 * half,
          vertical_status: "historical trial value only; no active normal-axis furnishing",
          status: "MOVEMENT GHOST ONLY; fixed HERE remains at its original coordinates"
        },
        craft: %{
          seat: geometry.emergence.registration.fixed_seat,
          normal: [0, 1, 0],
          plan_degrees_from_inaugural: nil,
          historical_trial_degrees: 45,
          heading: nil,
          inaugural_heading: [1, 0, 0],
          toward_axle_bearing: nil,
          reason:
            "45 degrees is superseded as a prescribed relationship. Derive bearing from an actual registration; no fixed orbital placement is appointed.",
          physical_envelope: nil
        },
        cob: %{
          stand_base: nil,
          historical_stand_base: [hd(cob_eye), 0, Enum.at(cob_eye, 2)],
          reference_status:
            "Legacy eye and reach measurements only; not the new centered one-extent stand or its eye registration.",
          eye: cob_eye,
          human_eye: eye,
          eye_delta_y: Enum.at(cob_eye, 1) - Enum.at(eye, 1),
          angle_from_current_human_regard: eye_angle,
          human_azimuth_toward_cob: plan_angle(eye_relative),
          visibility_limit:
            "Equal height is not co-inspection visibility: COB is lateral to the current +Z-to-minus-Y quarter-turn plane. A lateral camera bearing is not furnished by this inspection.",
          ghost_square_to_fixed_seat_distance: r,
          reach_limit: nil,
          clearance_scope:
            "required point distances and source-mesh eye rays, not mechanical reach or solid-body access",
          role:
            "same COB, distinct Furnishing/Traversaling capacities; stand and eye calibration provisional"
        },
        material_work: %{
          material: material,
          source_turns: source_turns,
          source_footings:
            Enum.filter(state["footings"], &(material && &1["material"] == material["id"])),
          existing_wall_registrations: geometry.emergence.wall_test.marks,
          proposed_destination: table_work,
          proposed_host: table_face.id,
          proposed_three_extent_table_destination: nil,
          status:
            "Historical annulus work preview only; this face is NOT assigned to the proposed three-extent Table. Its working destination remains unresolved until height/profile registration. Original placement retained."
        }
      },
      computed: %{
        selected:
          Map.merge(selected, %{
            wall_contacts: collisions,
            wall_contact_scope:
              "Historical scaled-box contacts only; not the recovered UN-FOLDING volume.",
            wall_distance_lower_bound: wall_distance_lower_bound(walls, center, half, yaw),
            table_plan_overlap: planar_table_overlap,
            table_vertical_gap: -table_y,
            physical_table_clearance:
              "PRIOR ANNULUS only: cube floor Y=0 versus source Y=-0.1. This height/gap is not assigned to the proposed three-extent Table; physical fit remains unknown."
          }),
        feasible_centers: feasible_centers(boundary, half, yaw),
        unscaled_six_in_gallery_units: static_fit(boundary, [0, 0, 0], 3, 0),
        courses:
          Enum.map(~w(independent co counter), fn mode ->
            course(boundary, r, half, spin, mode)
            |> convenience(next.center, table_work)
            |> sample_wall_course(walls, half)
            |> proposed_table_course(half, proposed_radius)
          end),
        static_vs_continuous_counterexample: %{
          radius: 1.2,
          start: static_fit(boundary, [1.2, 0, 0], half, 0),
          course: course(boundary, 1.2, half, 0, "independent")
        },
        approach: approach,
        cob_targets:
          Enum.map(targets, fn t ->
            Map.merge(t, %{
              required_distance: norm(sub(t.point, cob_eye)),
              outside_here_footprint: abs(hd(t.point)) > half or abs(Enum.at(t.point, 2)) > half,
              sight_obstructions: SnailWeaveGeometry.ray_hits(sight_surfaces, cob_eye, t.point),
              physical_reach_feasible: nil
            })
          end),
        wall_test: geometry.emergence.wall_test,
        curvature: %{
          observations: observations,
          samples: geometry.reference_arc.samples,
          analytic_curvature: 0.85 / (0.85 * 0.85 + :math.pow(0.5 / :math.pi(), 2)),
          evidence:
            "25 successive registered observations plus analytic helix constraint; not inferred from two observations",
          semantic_deformation:
            "UNRESOLVED: authored words do not currently deform the source mesh. No displacement law or fabricated wall is introduced."
        },
        inherited_nav_intervals:
          Enum.map(state["footings"], fn footing ->
            turn = Enum.find(state["turns"], &(&1["id"] == footing["turn"]))

            %{
              footing: Map.take(footing, ~w(id turn material address point)),
              source_turn: turn && Map.take(turn, ~w(id arc interval addresses status)),
              geometry_only: true
            }
          end),
        nav_status:
          "Existing Footing/turn ancestry only. No course joins the proposed Gallery orbit to an operational NAV-STEP; body samples are not navigation authority."
      },
      ledger: %{
        constitutionally_confirmed:
          "Source records only: no new constitutional confirmation or acquisition in this rehearsal.",
        standing: %{
          here: geometry.fixed.here,
          standing_circle: geometry.fixed.landinging,
          next: next,
          footings: Enum.map(state["footings"], & &1["id"])
        },
        affordmenting:
          "Independent orbit/spin and three candidate couplings; paired mesh outreadings and Table work preview.",
        outreading:
          "Observed source, computed results, provisional registration and unresolved dimensions are separated.",
        human_laboring:
          "No new words, furnishing or operation events are appended by inspection.",
        confirmationing:
          "Boundary-only continuity certificate is not physical clearance, lawful pathway or LOCK.",
        returnability:
          "Defaults return the movement ghost to HERE. Original material and acquired standing persist."
      },
      unresolved: [
        "Gallery-to-body transform",
        "UN-FOLDING-derived six-unit vertical registration",
        "Craft/Seat thickness and envelope",
        "physical COB stand and reach",
        "Table support/working reach",
        "Caterpillar wall deformation law",
        "continuous solid collision and acquired NAV course",
        "mechanical coupling/LOCK contract"
      ],
      recommendation:
        "Retain independent inspection degrees of freedom. Do not mechanically couple or authorize traversaling from boundary fit alone."
    }
  end

  def square([x, y, z], half, degrees) do
    Enum.map([{-half, -half}, {half, -half}, {half, half}, {-half, half}], fn {u, v} ->
      [x + u * cos(degrees) - v * sin(degrees), y, z + u * sin(degrees) + v * cos(degrees)]
    end)
  end

  def static_fit(boundary, center, half, yaw) do
    points = square(center, half, yaw)
    margin = for {a, b} <- edges(boundary), p <- points, do: dot(sub(p, a), inward(a, b))
    minimum = Enum.min(margin)

    %{
      boundary_margin: minimum,
      admissible: minimum >= -1.0e-9,
      scope:
        "exact planar convex-boundary containment of all square corners AND edges; no physical or acquired-path claim"
    }
  end

  def course(boundary, radius, half, spin, mode) do
    samples =
      Enum.map(0..90, fn phi ->
        yaw = spin + coupling(mode) * phi
        center = [radius * cos(phi), 0, radius * sin(phi)]

        %{
          orbit: phi,
          center: center,
          yaw: yaw,
          margin: static_fit(boundary, center, half, yaw).boundary_margin
        }
      end)

    # Signed distance to each fixed half-plane is 1-Lipschitz. This bounds
    # every corner's movement between samples, not merely endpoint agreement.
    bound = (radius + :math.sqrt(2) * half * abs(coupling(mode))) * :math.pi() / 180
    lower = Enum.min(Enum.map(samples, & &1.margin)) - bound

    %{
      mode: mode,
      interval_degrees: [0, 90],
      step_degrees: 1,
      samples: samples,
      minimum_sample_margin: Enum.min(Enum.map(samples, & &1.margin)),
      between_sample_motion_bound: bound,
      continuous_boundary_lower_bound: lower,
      continuous_boundary_certified: lower > 1.0e-9,
      continuous_physical_clearance: nil,
      traversaling_authorized: false
    }
  end

  def feasible_centers(boundary, half, yaw) do
    Enum.reduce(edges(boundary), boundary, fn {a, b}, polygon ->
      n = inward(a, b)
      u = [cos(yaw), 0, sin(yaw)]
      v = [-sin(yaw), 0, cos(yaw)]
      offset = dot(a, n) + half * (abs(dot(n, u)) + abs(dot(n, v)))
      clip(polygon, n, offset)
    end)
  end

  def wall_contacts(walls, center, half, yaw) do
    walls
    |> Enum.filter(fn face ->
      points =
        Enum.map(face.points, fn p ->
          [x, y, z] = sub(p, add(center, [0, half, 0]))
          [x * cos(yaw) + z * sin(yaw), y, -x * sin(yaw) + z * cos(yaw)]
        end)

      Enum.chunk_every(tl(points), 2, 1, :discard)
      |> Enum.any?(fn [b, c] -> triangle_box?([hd(points), b, c], half) end)
    end)
    |> Enum.map(& &1.id)
  end

  def wall_distance_lower_bound(walls, center, half, yaw) do
    walls
    |> Enum.map(fn face ->
      local =
        Enum.map(face.points, fn p ->
          [x, y, z] = sub(p, add(center, [0, half, 0]))
          [x * cos(yaw) + z * sin(yaw), y, -x * sin(yaw) + z * cos(yaw)]
        end)

      0..2
      |> Enum.map(fn i ->
        coords = Enum.map(local, &Enum.at(&1, i))
        max(0, max(Enum.min(coords) - half, -half - Enum.max(coords)))
      end)
      |> norm()
    end)
    |> Enum.min(fn -> 0.0 end)
  end

  defp triangle_box?([a, b, c] = points, half) do
    basis = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    sides = [sub(b, a), sub(c, b), sub(a, c)]
    axes = basis ++ [cross(sub(b, a), sub(c, a))] ++ for(e <- sides, u <- basis, do: cross(e, u))

    Enum.all?(axes, fn axis ->
      projections = Enum.map(points, &dot(&1, axis))
      radius = half * Enum.sum(Enum.map(axis, &abs/1))
      Enum.min(projections) <= radius + 1.0e-9 and Enum.max(projections) >= -radius - 1.0e-9
    end)
  end

  defp clip([], _, _), do: []

  defp clip(points, n, threshold) do
    Enum.flat_map(edges(points), fn {a, b} ->
      da = dot(a, n) - threshold
      db = dot(b, n) - threshold

      cond do
        da >= -1.0e-9 and db >= -1.0e-9 -> [b]
        da >= -1.0e-9 -> [add(a, mul(sub(b, a), da / (da - db)))]
        db >= -1.0e-9 -> [add(a, mul(sub(b, a), da / (da - db))), b]
        true -> []
      end
    end)
  end

  defp polygon_radial_range(points) do
    min_distance =
      if Enum.all?(edges(points), fn {a, b} -> dot(sub([0, 0, 0], a), inward(a, b)) >= -1.0e-9 end),
         do: 0.0,
         else:
           Enum.min(
             Enum.map(edges(points), fn {a, b} ->
               d = sub(b, a)
               t = max(0, min(1, -dot(a, d) / dot(d, d)))
               norm(add(a, mul(d, t)))
             end)
           )

    {min_distance, Enum.max(Enum.map(points, &radial/1))}
  end

  defp rim_margin(points, radius) do
    Enum.map(edges(points), fn {a, b} -> dot(sub([0, 0, 0], a), inward(a, b)) - radius end)
    |> Enum.min()
  end

  defp proposed_table_course(course, half, radius) do
    margins =
      Enum.map(course.samples, fn sample ->
        rim_margin(square(sample.center, half, sample.yaw), radius)
      end)

    Map.merge(course, %{
      proposed_table_minimum_rim_containment_margin: Enum.min(margins),
      proposed_table_height: nil,
      proposed_table_physical_clearance: nil
    })
  end

  defp sample_wall_course(course, walls, half) do
    # Horizontal motion preserves the vertical slab; prefilter only faces that
    # can meet that slab. This does not hide them from either rendering.
    relevant =
      Enum.filter(walls, fn face ->
        ys = Enum.map(face.points, &Enum.at(&1, 1))
        Enum.max(ys) >= -1.0e-9 and Enum.min(ys) <= 2 * half + 1.0e-9
      end)

    contacts =
      Enum.flat_map(course.samples, fn sample ->
        hits = wall_contacts(relevant, sample.center, half, sample.yaw)
        if hits == [], do: [], else: [%{orbit: sample.orbit, objects: hits}]
      end)

    Map.merge(course, %{
      wall_sample_count: length(course.samples),
      sampled_wall_contact_poses: contacts,
      wall_scope:
        "Historical scaled-box/triangle contacts at one-degree poses, including shared floor contact. Not a continuous solid-clearance certificate."
    })
  end

  defp convenience(course, next, table) do
    Map.merge(course, %{
      maximum_next_heading_error:
        Enum.map(course.samples, fn p ->
          angular_error(p.yaw, plan_angle(sub(next, p.center))) || 0
        end)
        |> Enum.max(),
      maximum_table_distance_from_ghost:
        Enum.map(course.samples, &norm(sub(table, &1.center))) |> Enum.max(),
      note:
        "Required geometry only. Table distance uses the PRIOR ANNULUS work point, not the proposed three-extent Table. No Human/COB working reach or NAV authority is inferred."
    })
  end

  defp centroid(points) do
    Enum.reduce(points, [0, 0, 0], &add/2) |> mul(1 / length(points))
  end

  defp coupling("co"), do: 1
  defp coupling("counter"), do: -1
  defp coupling(_), do: 0
  defp number(s), do: s |> Float.parse() |> elem(0)
  defp edges([]), do: []
  defp edges(points), do: Enum.zip(points, tl(points) ++ [hd(points)])

  defp inward(a, b) do
    [dx, _, dz] = sub(b, a)
    mul([-dz, 0, dx], 1 / :math.sqrt(dx * dx + dz * dz))
  end

  defp plan_angle([x, _, z]) when abs(x) + abs(z) < 1.0e-9, do: nil
  defp plan_angle([x, _, z]), do: :math.atan2(z, x) * 180 / :math.pi()
  defp angular_error(_, nil), do: nil
  defp angular_error(a, b), do: abs(a - b - 360 * :math.floor((a - b + 180) / 360))
  defp radial([x, _, z]), do: :math.sqrt(x * x + z * z)
  defp sin(a), do: :math.sin(a * :math.pi() / 180)
  defp cos(a), do: :math.cos(a * :math.pi() / 180)
  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp mul(a, n), do: Enum.map(a, &(&1 * n))
  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  defp norm(a), do: :math.sqrt(dot(a, a))
  defp cross([a, b, c], [x, y, z]), do: [b * z - c * y, c * x - a * z, a * y - b * x]
end
