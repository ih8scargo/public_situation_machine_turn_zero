defmodule PublicSituationMachineTurnZero.Workshop.OpeningSliceProjection do
  @moduledoc "Compact wedge reservation followed by explicit source-coordinate Projectioning; no physical compression, new ROOM or constitutional acquisition."
  alias PublicSituationMachineTurnZero.Workshop.{
    SnailBody,
    CoBuilding,
    CoBuildingGeometry,
    MaterialRibbon,
    OneCubicalDoorway,
    LetterTransformInspection,
    RoomToyBox
  }

  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M
  @letters ~w(R O1 O2 M)
  @offset [3.3, 6.1, -0.95]
  @subdivisions 16
  def contract, do: "opening-slice-projection-2026-11-17.v15"

  def new,
    do: %{active: true, phase: "ready", index: 0, progress: 0.0, reservation: nil, resolved: []}

  def offset, do: @offset

  def law do
    profile = %{
      id: "snail-radial-arc-v1",
      source: "SnailBody.arc_frame/1 / arc_length/0",
      authority: :retained_native_trial_not_revised_coiling_law,
      radius: 0.85,
      sweep_radians: 3 * :math.pi(),
      axial_drop: 1.5,
      length: SnailBody.arc_length(),
      direction: :reverse_for_ascending_standing,
      embedding: %{linear: :identity, translation: @offset},
      unit: "inherited trial extent; no source scaling"
    }

    Map.put(profile, :hash, CoBuilding.digest(profile))
  end

  def context(m) do
    %{
      ROOM_hash: CoBuilding.digest(m.frame),
      law_hash: law().hash,
      letter_hashes:
        Map.new(@letters, fn id ->
          p = Enum.find(m.pieces, &(&1.id == "doorway:letter-" <> id))
          {id, p.content_hash}
        end)
    }
  end

  def change(s, :compact, _), do: {:ok, %{s | active: true}}
  def change(s, :ports, _), do: {:ok, %{s | active: false}}

  def change(%{phase: "ready", index: i} = s, :appoint, c) when i < 4 do
    letter = Enum.at(@letters, i)

    r = %{
      id: "ROOM/wedge-#{i + 1}",
      letter: letter,
      source_identity: "doorway:letter-" <> letter,
      source_hash: c.letter_hashes[letter],
      ordinal: i,
      ROOM_hash: Map.fetch!(c, :ROOM_hash),
      law_hash: c.law_hash,
      allocation: %{domain: [[-0.5, 0.5], [-0.5, 0.5], [-0.5, 0.5]], measure: [1, 1, 1]},
      resolved: false
    }

    {:ok, %{s | phase: "reserved", reservation: r, progress: 0.0, active: true}}
  end

  def change(s, cmd, c) do
    cond do
      not is_nil(s.reservation) and not binding_valid?(s.reservation, c) ->
        {:error, :inherited_projection_binding_changed}

      s.phase == "reserved" and cmd == :open ->
        {:ok, %{s | phase: "open"}}

      s.phase in ~w(open issuing) and match?({:progress, _}, cmd) ->
        {:progress, t} = cmd

        if is_number(t) and t >= s.progress and t <= 1,
          do: {:ok, %{s | progress: t, phase: if(t == 1, do: "through", else: "issuing")}},
          else: {:error, :straight_slice_progress_required}

      s.phase == "through" and cmd == :resolve ->
        r = %{s.reservation | resolved: true}
        {:ok, %{s | phase: "review", reservation: r, resolved: s.resolved ++ [r]}}

      s.phase == "review" and cmd == :next ->
        {:ok, %{s | phase: "ready", index: s.index + 1, reservation: nil, progress: 0.0}}

      true ->
        {:error, :one_wedge_predecessor_required}
    end
  end

  defp binding_valid?(r, c),
    do:
      Map.fetch!(r, :ROOM_hash) == Map.fetch!(c, :ROOM_hash) and r.law_hash == c.law_hash and
        r.source_hash == c.letter_hashes[r.letter]

  def resolve_point(ordinal, [u, v, w]) do
    t = 1 - (ordinal + u + 0.5) / SnailBody.arc_length()
    f = SnailBody.arc_frame(t)
    M.add(@offset, M.add(f.point, M.add(M.scale(f.binormal, v), M.scale(f.radial, w))))
  end

  def inverse_point(ordinal, world) do
    [x, y, z] = M.sub(world, @offset)
    length = SnailBody.arc_length()
    by = 0.85 * 3 * :math.pi() / length
    bt = 1.5 / length
    lo = 1 - (ordinal + 1) / length
    hi = 1 - ordinal / length

    residual = fn t ->
      a = 3 * :math.pi() * t
      v = (y + 0.55 + 1.5 * t) / by
      -x * :math.sin(a) + z * :math.cos(a) - v * bt
    end

    if residual.(lo) >= -1.0e-9 and residual.(hi) <= 1.0e-9 do
      {a, b} =
        Enum.reduce(1..60, {lo, hi}, fn _, {a, b} ->
          mid = (a + b) / 2
          if residual.(mid) > 0, do: {mid, b}, else: {a, mid}
        end)

      t = (a + b) / 2
      angle = 3 * :math.pi() * t

      q = [
        (1 - t) * length - ordinal - 0.5,
        (y + 0.55 + 1.5 * t) / by,
        x * :math.cos(angle) + z * :math.sin(angle) - 0.85
      ]

      if Enum.all?(q, &(&1 >= -0.50000001 and &1 <= 0.50000001)),
        do: {:ok, q},
        else: {:error, :outside_unit_allocation}
    else
      {:error, :outside_source_interval}
    end
  end

  defp clip_face(face, cut, lower?) do
    Enum.zip(face, tl(face) ++ [hd(face)])
    |> Enum.flat_map(fn {a, b} ->
      da = if lower?, do: hd(a) - cut, else: cut - hd(a)
      db = if lower?, do: hd(b) - cut, else: cut - hd(b)

      cond do
        da >= -1.0e-12 and db >= -1.0e-12 -> [b]
        da >= -1.0e-12 -> [M.add(a, M.scale(M.sub(b, a), da / (da - db)))]
        db >= -1.0e-12 -> [M.add(a, M.scale(M.sub(b, a), da / (da - db))), b]
        true -> []
      end
    end)
    |> Enum.uniq()
  end

  def resolve_mesh(source, ordinal) do
    provenance =
      Enum.with_index(source.faces)
      |> Enum.flat_map(fn {face, index} ->
        {a, b} = Enum.map(face, &hd/1) |> Enum.min_max()

        if b - a < 1.0e-11 do
          [%{source_face: index, parameter_vertices: face}]
        else
          for i <- 0..(@subdivisions - 1),
              lo = -0.5 + i / @subdivisions,
              hi = lo + 1 / @subdivisions,
              min(b, hi) - max(a, lo) > 1.0e-11,
              polygon = face |> clip_face(lo, true) |> clip_face(hi, false),
              length(polygon) >= 3,
              do: %{source_face: index, parameter_vertices: polygon}
        end
      end)

    mesh =
      G.mesh(
        Enum.map(provenance, fn f ->
          Enum.map(f.parameter_vertices, &resolve_point(ordinal, &1))
        end)
      )

    %{geometry: mesh, provenance: provenance}
  end

  def allocation_envelopes(ordinal) do
    omega = 3 * :math.pi() / SnailBody.arc_length()
    amplitude = :math.sqrt(1.35 * 1.35 + :math.pow(0.5 * 1.5 / SnailBody.arc_length(), 2))
    error = omega * omega * amplitude / (8 * @subdivisions * @subdivisions)

    for i <- 0..(@subdivisions - 1) do
      lo = -0.5 + i / @subdivisions
      hi = lo + 1 / @subdivisions

      vertices =
        for u <- [lo, hi],
            v <- [-0.5, 0.5],
            w <- [-0.5, 0.5],
            do: resolve_point(ordinal, [u, v, w])

      bounds = for axis <- 0..2, do: Enum.map(vertices, &Enum.at(&1, axis)) |> Enum.min_max()

      lower =
        Enum.with_index(bounds)
        |> Enum.map(fn {{a, _}, j} -> a - if(j == 1, do: 0, else: error) end)

      upper =
        Enum.with_index(bounds)
        |> Enum.map(fn {{_, b}, j} -> b + if(j == 1, do: 0, else: error) end)

      %{source_u_interval: [lo, hi], chord_error_bound: error, geometry: G.box(lower, upper)}
    end
  end

  defp piece(id, name, mesh, office, evidence) do
    %{
      id: id,
      name: name,
      source_identity: id,
      source_geometry: mesh,
      geometry: mesh,
      content_hash: CoBuilding.digest(%{id: id, mesh: mesh}),
      material_office: office,
      standing_locality: %{frame: :v11_world, bounds: RoomToyBox.bounds(mesh)},
      bearing: :source_registered,
      attachment: :candidate_not_acquired,
      inheritance: ["same SIX ROOM / bound source curvature law"],
      affordment: :reservation_and_resolution_inspection,
      regarding: :view_independent,
      status: :prospective_material,
      render_layer: :both,
      candidate_family: :opening_slice,
      movement: "room",
      lines: [],
      yellow: [:constitutional_acceptance],
      evidence: evidence
    }
  end

  def hardware(m) do
    # Behind the existing leaf: its entire 0..90-degree swing stays X >= 3.64.
    # Insert ends at X=3.62, so it neither occupies the closed leaf nor its swing.
    x = 3.60
    y = 5.02
    z = -4.2
    t = 0.02
    h = 0.64
    vy = 0.07
    vz = 0.09

    boxes = [
      G.box([x - t, y - h, z - h], [x + t, y - vy, z + h]),
      G.box([x - t, y + vy, z - h], [x + t, y + h, z + h]),
      G.box([x - t, y - vy, z - h], [x + t, y + vy, z - vz]),
      G.box([x - t, y - vy, z + vz], [x + t, y + vy, z + h])
    ]

    insert = G.mesh(Enum.flat_map(boxes, & &1.faces)) |> Map.put(:cells, boxes)
    wedge = G.prism([[3, 4.98, -4.26], [3, 5.06, -4.2], [3, 4.98, -4.14]], 0.02)
    toe = LetterTransformInspection.record(m, LetterTransformInspection.new()).toe
    anchor = resolve_point(0, toe.unit_point)
    [_ax, ay, az] = anchor
    receiver = [3, ay, -2.01]

    links = [
      G.strap(anchor, [3, ay, az], 0.03, 0.015, [0, 1, 0]),
      G.strap([3, ay, az], receiver, 0.03, 0.015, [0, 1, 0]),
      G.box(M.sub(anchor, [0.025, 0.025, 0.025]), M.add(anchor, [0.025, 0.025, 0.025])),
      G.box([2.94, ay - 0.04, -2.04], [3.06, ay + 0.04, -1.98])
    ]

    joint = G.mesh(Enum.flat_map(links, & &1.faces)) |> Map.put(:cells, links)

    [
      piece(
        "projection:compact-opening",
        "Compact opening · reservation slice",
        insert,
        "compact aperture reserves one wedge; expanded letter is not the payload",
        %{
          normal: [1, 0, 0],
          plane_X: x,
          opening: [0.18, 0.14],
          source: "existing Stage frame insert; no monitor alteration"
        }
      ),
      piece(
        "projection:opening-slice",
        "One source-addressed wedge reservation",
        wedge,
        "reservation token; contains no miniature letter",
        %{section: [0.12, 0.08], thickness: 0.02, allocation_inside_token: false}
      ),
      piece(
        "projection:R-resolved-purchase",
        "Resolved R toe TO full-height wall",
        joint,
        "candidate purchase constructed only in resolved coordinates",
        %{
          source_toe: toe.id,
          parameter_point: toe.unit_point,
          resolved_anchor: anchor,
          receiver: receiver,
          wall: "doorway:r-wall",
          PITTONING: :not_accepted
        }
      )
    ]
  end

  def decorate(m, s) do
    c = context(m)
    extras = hardware(m)

    extras =
      Enum.map(extras, fn p ->
        active =
          s.active and
            (p.id != "projection:R-resolved-purchase" or
               Enum.any?(s.resolved, &(&1.letter == "R")))

        p = Map.put(p, :opening_slice_visible, active)

        if p.id == "projection:opening-slice" do
          posed = G.translate(p.source_geometry, [0.85 * s.progress, 0, 0])

          p
          |> Map.put(:opening_slice_visible, s.active and not is_nil(s.reservation))
          |> Map.put(:geometry, posed)
          |> Map.put(:standing_locality, %{frame: :v11_world, bounds: RoomToyBox.bounds(posed)})
          |> Map.put(:reservation, s.reservation)
        else
          p
        end
      end)

    {parts, records} =
      Enum.map_reduce(m.pieces, [], fn p, records ->
        if s.active and String.starts_with?(p.id, "doorway:letter-") do
          r = Enum.find(s.resolved, &(&1.source_identity == p.id))

          if r do
            result = resolve_mesh(p.source_geometry, r.ordinal)
            mid = SnailBody.arc_frame(1 - (r.ordinal + 0.5) / SnailBody.arc_length())

            p =
              p
              |> Map.put(:geometry, result.geometry)
              |> Map.put(:active_letter, true)
              |> Map.put(:standing_locality, %{
                frame: :resolved_Gallery_chart,
                source_allocation: r.allocation,
                bounds: RoomToyBox.bounds(result.geometry),
                law_hash: c.law_hash
              })
              |> Map.put(
                :evidence,
                Map.merge(p.evidence, %{
                  projection_resolution: r.id,
                  surface_target: resolve_point(r.ordinal, [0, 0, -0.5]),
                  surface_normal: M.scale(mid.radial, -1),
                  position: resolve_point(r.ordinal, [0, 0, 0])
                })
              )

            {p,
             records ++
               [
                 %{
                   reservation: r,
                   provenance: result.provenance,
                   derived_hash: CoBuilding.digest(result.geometry)
                 }
               ]}
          else
            {Map.put(p, :active_letter, false), records}
          end
        else
          {p, records}
        end
      end)

    parts =
      if s.active do
        Enum.map(parts, fn p ->
          if p.id == "doorway:stage-leaf" do
            angle = if s.phase in ~w(open issuing through review), do: 90, else: 0
            posed = OneCubicalDoorway.leaf_pose(p.source_geometry, angle)

            p
            |> Map.put(:geometry, posed)
            |> Map.put(:bearing, %{degrees: angle, axis: :existing_Door_hinge})
            |> Map.put(:standing_locality, %{frame: :v11_world, bounds: RoomToyBox.bounds(posed)})
          else
            p
          end
        end)
      else
        parts
      end

    all = parts ++ extras

    toe = LetterTransformInspection.record(m, LetterTransformInspection.new()).toe

    report = %{
      contract: contract(),
      state: s,
      context: c,
      law: law(),
      calibration: :candidate_embedding_not_proof_of_canonical_coiling_correspondence,
      toe: %{
        visible: s.active and Enum.any?(s.resolved, &(&1.letter == "R")),
        source: toe,
        resolved_point: resolve_point(0, toe.unit_point),
        target_YT: m.frame.maximum,
        PINNING: :not_accepted,
        PITTONING: :not_accepted
      },
      source_allocation: %{measure: [1, 1, 1], domain: [[-0.5, 0.5], [-0.5, 0.5], [-0.5, 0.5]]},
      mapping: %{
        formula:
          "F(i,[u,v,w]) = offset + arc_point(t) + v*binormal(t) + w*radial(t); t=1-(i+u+.5)/arc_length",
        offset: @offset,
        source_coordinates_edited: false,
        interval_per_letter: 1.0,
        source_mapping_kind: :explicit_projection_chart_not_physical_compression,
        manufacturing_strain_law: :not_claimed,
        subdivisions: @subdivisions
      },
      records: records,
      extras: extras,
      comparison: %{
        port_based:
          "preserved resolved-unit transport trial; lateral-exit collision remains valid in that scope",
        compact:
          "opening transports only appointed wedge; resolved-unit fit is not an admission prerequisite",
        preferred: :compact_reservation_then_resolution
      },
      constitutional: %{
        acquired_delta: 0,
        PUFFING: :not_accepted,
        PITTONING: :not_accepted,
        RE_STEP: :not_performed,
        material_purchase: :candidate_geometric_contact
      }
    }

    m
    |> Map.put(:pieces, all)
    |> Map.put(:opening_projection, report)
    |> Map.put(:source_digest, CoBuilding.digest(Enum.map(all, &[&1.id, &1.content_hash])))
  end

  def visible?(p, s),
    do:
      not String.starts_with?(p.id, "projection:") or
        (s.active and Map.get(p, :opening_slice_visible, false))

  def measurements(m) do
    get = fn id -> Enum.find(m.pieces, &(&1.id == id)) end

    fixed =
      Enum.filter(m.pieces, fn p ->
        p.geometry.vertices != [] and Map.get(p, :render_layer) != :legacy and
          not String.starts_with?(p.id, "doorway:letter-") and
          p.id not in [
            "projection:opening-slice",
            "projection:R-resolved-purchase",
            "doorway:stage-leaf"
          ]
      end)

    open_leaf = OneCubicalDoorway.leaf_pose(get.("doorway:stage-leaf").source_geometry, 90)
    fixed = fixed ++ [%{id: "open-leaf", geometry: open_leaf}]

    rows =
      for ordinal <- 0..3 do
        cells = allocation_envelopes(ordinal)

        hits =
          for p <- fixed,
              Enum.any?(cells, &OneCubicalDoorway.interferes?(&1.geometry, p.geometry)),
              do: p.id

        %{
          letter: Enum.at(@letters, ordinal),
          ordinal: ordinal,
          envelope_count: length(cells),
          chord_error_bound: hd(cells).chord_error_bound,
          intersections: hits,
          inside_ROOM:
            Enum.all?(cells, fn cell ->
              Enum.all?(cell.geometry.vertices, &RoomToyBox.inside?/1)
            end)
        }
      end

    sweep = G.box([2.99, 4.98, -4.26], [3.86, 5.06, -4.14])
    insert = get.("projection:compact-opening").geometry
    joint = get.("projection:R-resolved-purchase").geometry

    joint_hits =
      for p <- fixed,
          p.id not in ["doorway:r-wall"],
          OneCubicalDoorway.interferes?(joint, p.geometry),
          do: p.id

    %{
      reservation_sweep_intersections:
        for(p <- fixed, OneCubicalDoorway.interferes?(sweep, p.geometry), do: p.id),
      resolved_unit_would_hit_compact_insert:
        OneCubicalDoorway.interferes?(OneCubicalDoorway.unit_box([3.65, 5.02, -4.2]), insert),
      insert_closed_leaf_interference:
        OneCubicalDoorway.interferes?(insert, get.("doorway:stage-leaf").source_geometry),
      insert_leaf_swing_envelope_interference:
        OneCubicalDoorway.interferes?(insert, G.box([3.64, 4.44, -4.79], [4.811, 5.60, -3.61])),
      insert_frame_attachment:
        OneCubicalDoorway.interferes?(insert, get.("doorway:stage-frame").geometry),
      resolved_allocations: rows,
      purchase_unintended_intersections: joint_hits,
      purchase_wall_incidence:
        OneCubicalDoorway.interferes?(joint, get.("doorway:r-wall").geometry),
      intrinsic_unit_lengths: [1, 1, 1],
      source_law_hash: law().hash,
      acquired_delta: 0
    }
  end

  def controls,
    do:
      Enum.map(
        ~w(slice-compact slice-ports slice-appoint slice-open slice-resolve slice-next rtb-slice_progress slice-ledger),
        &%{
          id: &1,
          office:
            "one wedge reservation / explicit Projectioning / resolved inspection; no constitutional acquisition",
          kind: :prospective_material
        }
      )
end
