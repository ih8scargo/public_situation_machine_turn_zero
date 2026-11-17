defmodule PublicSituationMachineTurnZero.Workshop.LetterTransformInspection do
  @moduledoc "Two explicitly scoped inspections of one existing unit letter; no new ROOM, glyph deformation or PUFFING acceptance."
  alias PublicSituationMachineTurnZero.Workshop.{
    CoBuildingGeometry,
    MaterialRibbon,
    RoomRibbon,
    OneCubicalDoorway,
    RoomToyBox
  }

  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M
  def contract, do: "same-letter-transformations-2026-11-17.v14"
  def new, do: %{active: false, bearing: 0.0, door: 0.0, curvature: 0.0}
  def change(s, :activate), do: {:ok, %{s | active: true}}
  def change(s, :close), do: {:ok, %{s | active: false}}
  def change(_, :puff), do: {:error, :unit_letter_puffing_acceptance_unbound}

  def change(s, {key, v}) when key in [:bearing, :door] and is_number(v) and v >= 0 and v <= 90,
    do: {:ok, s |> Map.put(key, v) |> Map.put(:active, true)}

  def change(s, {:curvature, v}) when is_number(v) and v >= 0 and v <= 1,
    do: {:ok, %{s | curvature: v, active: true}}

  def change(_, _), do: {:error, :unsupported_letter_inspection}

  def record(m, s) do
    letter = Enum.find(m.pieces, &(&1.id == "doorway:letter-R"))
    original = Enum.find(m.pieces, &(&1.id == "room:R"))
    u = Enum.find(m.pieces, &(&1.id == "doorway:inner-u"))
    curve = Enum.slice(u.source_geometry.source_course, 1, 33)
    frames = G.frames(curve)
    index = min(round(s.curvature * 32), 32)
    f = Enum.at(frames, index)
    first = hd(frames)

    angle =
      :math.atan2(Enum.at(f.tangent, 1), hd(f.tangent)) -
        :math.atan2(Enum.at(first.tangent, 1), hd(first.tangent))

    degrees = angle * 180 / :math.pi()
    centre = letter.evidence.position
    rotate = fn p -> RoomRibbon.rotate(p, [0, 0, 1], angle) end
    pose = fn p -> M.add(centre, rotate.(p)) end
    glyph = original.source_geometry
    # Last stroke is the original R's descending leg. Its second face is the finite toe end-cap.
    toe_face_index = length(glyph.faces) - 5
    toe_face = Enum.at(glyph.faces, toe_face_index)
    toe_source = G.centroid(toe_face)
    embedding = M.sub([0, 0, -0.48], G.centroid(glyph.vertices))
    toe_local = M.add(toe_source, embedding)
    toe_world = pose.(toe_local)
    target = m.frame.maximum
    dir = M.sub(target, toe_world)

    hit =
      if abs(hd(dir)) > 1.0e-10 do
        t = (3.65 - hd(toe_world)) / hd(dir)
        p = M.add(toe_world, M.scale(dir, t))

        %{
          point: p,
          parameter: t,
          inside_opening:
            t >= 0 and t <= 1 and Enum.at(p, 1) >= 4.42 and Enum.at(p, 1) <= 5.62 and
              Enum.at(p, 2) >= -4.8 and Enum.at(p, 2) <= -3.6
        }
      else
        %{point: nil, inside_opening: false}
      end

    i = max(1, min(index, 31))
    prev = Enum.at(frames, i - 1)
    next = Enum.at(frames, i + 1)
    turn = :math.acos(max(-1, min(1, M.dot(prev.tangent, next.tangent))))

    span =
      M.distance(Enum.at(curve, i - 1), Enum.at(curve, i)) +
        M.distance(Enum.at(curve, i), Enum.at(curve, i + 1))

    leaf =
      OneCubicalDoorway.leaf_pose(
        Enum.find(m.pieces, &(&1.id == "doorway:stage-leaf")).source_geometry,
        s.door
      )

    leaf_hit = G.ray(toe_world, M.unit(dir), leaf.faces)
    posed = G.transform(letter.source_geometry, pose)
    allocation = G.transform(OneCubicalDoorway.unit_box([0, 0, 0]), pose)
    normal = RoomRibbon.rotate([0, 0, -1], [0, 1, 0], s.bearing * :math.pi() / 180)

    %{
      contract: contract(),
      active: s.active,
      source_identity: letter.source_identity,
      source_hash: letter.content_hash,
      inscription_source: original.source_identity,
      allocation: %{
        frame: :letter_local,
        measure: [1, 1, 1],
        source_bounds: RoomToyBox.bounds(letter.source_geometry),
        world_bounds: RoomToyBox.bounds(allocation),
        world_vertices: allocation.vertices,
        inside_ROOM: Enum.all?(allocation.vertices, &RoomToyBox.inside?/1)
      },
      material_pose: %{
        origin: centre,
        axis: [0, 0, 1],
        degrees: degrees,
        linear: Enum.map([[1, 0, 0], [0, 1, 0], [0, 0, 1]], rotate),
        linear_convention: :basis_columns,
        source_to_world: "origin + x*linear[0] + y*linear[1] + z*linear[2]",
        applied_to_scene: s.active,
        kind: :rigid_frame_transport_not_glyph_bending
      },
      Regarding: %{
        bearing_degrees: s.bearing,
        eye: M.add(centre, M.scale(normal, 3)),
        target: centre,
        normal: normal,
        projection: :orthographic,
        pixels_per_trial_extent: 240,
        source_material_pose_changed: false
      },
      Door: %{
        identity: "doorway:stage-leaf",
        degrees: s.door,
        letter_moves_with_leaf: false,
        office: :separate_finite_Door_motion
      },
      curvature: %{
        source: u.source_identity,
        source_course: curve,
        index: index,
        source_course_index: index + 1,
        co_registration_translation: M.sub(centre, f.point),
        physical_mount: :unproved,
        point: f.point,
        tangent: f.tangent,
        normal: [0, 0, 1],
        relative_frame_degrees: degrees,
        local_discrete_curvature: turn / span,
        unit: "radians per trial extent",
        basis: "turn between neighboring sampled tangents divided by their two-chord span",
        analytic_reference: %{radius: 0.8, curvature: 1 / 0.8},
        placement: :frame_co_registered_at_existing_letter_origin_not_a_new_passage
      },
      toe: %{
        id: "specimen:R:1/leading-toe/end-cap",
        source_definition:
          "CoBuilding.glyph/2: final diagonal stroke [0.17,0.38] TOWARD [0.48,0]",
        source_face_index: toe_face_index,
        source_face: toe_face,
        source_point: toe_source,
        unit_embedding_translation: embedding,
        unit_point: toe_local,
        world_point: toe_world,
        source_normal: G.normal(toe_face),
        world_normal: RoomRibbon.rotate(G.normal(toe_face), [0, 0, 1], angle),
        world_face: Enum.map(toe_face, &pose.(M.add(&1, embedding)))
      },
      issuing: %{
        subject: "specimen:R:1/leading-toe/end-cap",
        ordered_prepositioning: ["FROM", "THROUGH", "TOWARD"],
        origin: toe_world,
        through: "doorway:stage-frame",
        object: "body-bearing/back-wall-YT",
        target: target,
        direction: M.unit(dir),
        Stage_plane_incidence: hit,
        Door_leaf_hit_distance: leaf_hit,
        Door_leaf_clear_to_target: is_nil(leaf_hit) or leaf_hit > M.norm(dir),
        status: :source_registered_issuing_reference,
        PINNING: :not_accepted,
        PITTONING: :not_accepted
      },
      gate: %{
        PUFFING: :unbound_for_unit_letter_curvature,
        acquired_delta: 0,
        actual_curvature_standing: false,
        missing: [
          :registered_wedging_to_letter_material_mount,
          :source_bound_PITTONING_and_PUFFING_acceptance,
          :validated_occupied_curvature_passage
        ]
      },
      posed_geometry: posed,
      posed_allocation: allocation
    }
  end

  def decorate(m, s) do
    r = record(m, s)

    if s.active do
      replace = fn p ->
        cond do
          p.id == r.source_identity ->
            p
            |> Map.put(:geometry, r.posed_geometry)
            |> Map.put(:active_letter, true)
            |> Map.put(:standing_locality, %{
              frame: :v11_world,
              bounds: RoomToyBox.bounds(r.posed_geometry),
              allocation: r.allocation
            })
            |> Map.put(:inspection_pose, r.material_pose)
            |> Map.put(:bearing, %{
              origin: r.material_pose.origin,
              linear: r.material_pose.linear,
              front_normal: [0, 0, -1]
            })

          p.id == "doorway:stage-leaf" ->
            mesh = OneCubicalDoorway.leaf_pose(p.source_geometry, s.door)

            p
            |> Map.put(:geometry, mesh)
            |> Map.put(:standing_locality, %{frame: :v11_world, bounds: RoomToyBox.bounds(mesh)})
            |> Map.put(:bearing, %{
              source_normal: [1, 0, 0],
              normal: RoomRibbon.rotate([1, 0, 0], [0, 1, 0], s.door * :math.pi() / 180),
              axis: [0, 1, 0],
              degrees: s.door
            })

          true ->
            p
        end
      end

      parts = Enum.map(m.pieces, replace)

      obstacles =
        Enum.filter(parts, fn p ->
          p.id != r.source_identity and p.geometry.vertices != [] and
            Map.get(p, :render_layer) != :legacy and Map.get(p, :active_letter, true)
        end)

      overlaps =
        for p <- obstacles,
            OneCubicalDoorway.interferes?(r.posed_allocation, p.geometry),
            do: p.id

      r = Map.put(r, :prospective_allocation_intersections, overlaps)

      m
      |> Map.put(:pieces, parts)
      |> Map.put(:doorway, %{m.doorway | pieces: Enum.map(m.doorway.pieces, replace)})
      |> Map.put(:letter_inspection, r)
    else
      Map.put(m, :letter_inspection, r)
    end
  end
end
