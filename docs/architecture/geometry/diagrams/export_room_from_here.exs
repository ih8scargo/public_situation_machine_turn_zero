alias PublicSituationMachineTurnZero.Workshop.{
  RoomFromHere,
  TupleExcursionInheritance
}

alias RoomFromHere, as: R

pack = fn mesh ->
  vertices = Enum.uniq(mesh.vertices)
  lookup = vertices |> Enum.with_index() |> Map.new()
  faces = Enum.map(mesh.faces, fn f -> Enum.map(f, &Map.fetch!(lookup, &1)) end)

  cells =
    Enum.map(Map.get(mesh, :cells, []), fn cell ->
      Enum.map(cell.faces, fn f -> Enum.map(f, &Map.fetch!(lookup, &1)) end)
    end)

  %{vertices: vertices, faces: faces, convex_cells: cells}
end

s = R.new()
m = R.model(s)

pieces =
  Enum.map(m.pieces, fn p ->
    p
    |> Map.drop([:geometry, :source_geometry, :display_geometry])
    |> Map.put(:source_mesh, pack.(p.source_geometry))
    |> Map.put(:pose_mesh, pack.(p.geometry))
  end)

seams =
  for i <- 1..m.seams do
    seam = R.seam(m.ribbon, i)

    seam
    |> Map.update!(:arriving, &Map.update!(&1, :cell, pack))
    |> Map.update!(:departing, &Map.update!(&1, :cell, pack))
  end

poses =
  for pivot <- ~w(seat table), angle <- [0.0, 25.0, -25.0] do
    ps =
      %{s | pivot: pivot, follow: pivot, opening: 1.0, view: "oblique"}
      |> Map.put(if(pivot == "seat", do: :seat_angle, else: :table_angle), angle)

    pm = R.model(ps)

    %{
      active: pivot,
      degrees: angle,
      source_digest: pm.source_digest,
      source_pose:
        for(
          p <- pm.pieces,
          p.id in ~w(cb:seat cb:seat-back cb:table cb:square-axle cb:monitor),
          do: %{id: p.id, mesh: pack.(p.geometry), source_hash: p.content_hash}
        ),
      camera: R.camera(ps, pm),
      pivots: pm.pivots,
      clearance: pm.pose_clearance,
      acquisition: pm.acquisition
    }
  end

views =
  for view <- R.views() do
    st = %{s | view: view, opening: 1.0}
    %{view: view, camera: R.camera(st, m), source_digest: m.source_digest, seam: st.seam}
  end

{_, pinning_succession} =
  Enum.reduce(1..3, {s, []}, fn n, {before, rows} ->
    {:ok, after_state} = R.change(before, before.revision, {:pin, n})
    observed = R.model(after_state)

    row = %{
      expected_revision: before.revision,
      pins: after_state.pins,
      event: List.last(after_state.events),
      source_digest: observed.source_digest,
      acquisition: observed.acquisition,
      pieces:
        for(
          p <- observed.pieces,
          p.id in ~w(room:R room:M),
          do: %{
            id: p.id,
            source: p.source_identity,
            source_hash: p.content_hash,
            pose: pack.(p.geometry)
          }
        )
    }

    {after_state, rows ++ [row]}
  end)

regarding_configs = [
  %{s | opening: 0.0},
  %{s | opening: 0.5, disclosing?: true},
  %{s | opening: 1.0, disclosing?: true},
  %{s | opening: 1.0, view: "flat"},
  %{s | opening: 1.0, view: "surface", selected: "room:R", close: 1.0},
  %{s | opening: 1.0, view: "oblique", orbit: 45.0}
]

regarding_poses =
  Enum.map(regarding_configs, fn st ->
    %{
      state: Map.take(st, [:opening, :disclosing?, :view, :selected, :close, :orbit]),
      camera: R.camera(st, m),
      source_digest: m.source_digest
    }
  end)

edge_state = %{s | door: 90.0, view: "flat", opening: 1.0}
edge_model = R.model(edge_state)
edge_r = Enum.find(edge_model.pieces, &(&1.id == "room:R"))

edge_on = %{
  source: edge_r.source_identity,
  source_hash: edge_r.content_hash,
  pose: pack.(edge_r.geometry),
  camera: R.camera(edge_state, edge_model)
}

return_file = "docs/architecture/geometry/diagrams/room-toy-box-v11-witness.json"

return_dependency = %{
  file: return_file,
  sha256: :crypto.hash(:sha256, File.read!(return_file)) |> Base.encode16(case: :lower),
  office: "preserved 10-pose one-M return witness"
}

sources = ~w(
lib/public_situation_machine_turn_zero/workshop/room_from_here.ex
lib/public_situation_machine_turn_zero/workshop/room_toy_box.ex
lib/public_situation_machine_turn_zero/workshop/room_ribbon.ex
lib/public_situation_machine_turn_zero/workshop/snail_body.ex
lib/public_situation_machine_turn_zero/workshop/tuple_excursion_inheritance.ex
lib/public_situation_machine_turn_zero_web/components/room_toy_box_panel.ex
lib/public_situation_machine_turn_zero_web/components/room_from_here_controls.ex
docs/architecture/geometry/room-from-here-commission-2026-11-17.txt
lib/public_situation_machine_turn_zero_web/live/architecture_live.ex
lib/public_situation_machine_turn_zero/workshop/co_building_geometry.ex
lib/public_situation_machine_turn_zero/workshop/material_ribbon.ex
assets/css/room_toy_box.css
docs/architecture/geometry/diagrams/export_room_from_here.exs
)

hashes =
  Map.new(sources, fn path ->
    {path, :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)}
  end)

witness =
  m
  |> Map.take([
    :contract,
    :geometry_contract,
    :source_digest,
    :frame,
    :zero_one,
    :body_bearing,
    :registration,
    :circular_offices,
    :sectors,
    :material_assessment,
    :aperture_planes,
    :projection_offices,
    :authoring,
    :pivots,
    :gear_observations,
    :control_ledger,
    :acquisition,
    :stopped_portions,
    :pins,
    :passage_incidence
  ])
  |> Map.merge(%{
    unit: "inherited trial extent; no terrestrial scale",
    pieces: pieces,
    pinning_succession: pinning_succession,
    regarding_poses: regarding_poses,
    R_edge_on: edge_on,
    inherited_return_witness: return_dependency,
    seams: seams,
    views: views,
    pivot_poses: poses,
    tuple_inheritance: TupleExcursionInheritance.model(m),
    prospective_staircase: m.staircase,
    source_files: hashes,
    sketch: %{
      source: "Richard's numbered ZERO–SIX drawing supplied in conversation; earlier ROOM panels",
      metric_calibration: nil,
      FOUR_FIVE: :provisional_material_correspondence
    },
    stabilization: %{
      before: m.material_assessment.ports,
      after: m.material_assessment.ports,
      result: :stopped_no_unappointed_joint_repair
    },
    digest_profile: "CoBuilding sorted typed SHA256 v2; source independent of pose or camera"
  })

encoded = Jason.encode!(witness, pretty: true) <> "\n"
file = "room-from-here-v12-witness.json"
File.write!(Path.join(__DIR__, file), encoded)
sha = :crypto.hash(:sha256, encoded) |> Base.encode16(case: :lower)

checkpoints = [
  %{
    stage: 1,
    evidence: %{
      registration: m.registration,
      circles: m.circular_offices,
      conflicts: m.material_assessment
    }
  },
  %{
    stage: 2,
    evidence: %{
      before_after: witness.stabilization,
      fixed_clearance: m.clearance,
      foundation: m.foundation,
      port_registration: m.port_registration
    }
  },
  %{
    stage: 3,
    evidence: %{
      views: views,
      pivot_poses: poses,
      gear_observations: m.gear_observations,
      seam_count: m.seams,
      sectors: m.sectors,
      controls: m.control_ledger
    }
  },
  %{
    stage: 4,
    evidence: %{
      letters: m.authoring.sources,
      return: m.ribbon |> Map.drop([:geometry]),
      staircase: m.staircase,
      tuple: TupleExcursionInheritance.model(m),
      pins: m.pins
    }
  }
]

for checkpoint <- checkpoints do
  payload =
    Map.merge(checkpoint, %{
      contract: R.contract(),
      main_witness: file,
      main_sha256: sha,
      acquisition: m.acquisition
    })

  File.write!(
    Path.join(__DIR__, "room-from-here-stage-#{checkpoint.stage}.json"),
    Jason.encode!(payload, pretty: true) <> "\n"
  )
end

IO.puts(
  "Exported #{length(pieces)} pieces, #{length(seams)} finite seam pairs, #{length(views)} Regardings and four bounded stages."
)
