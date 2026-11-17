alias PublicSituationMachineTurnZero.Workshop.{
  RoomFromHere,
  OneCubicalDoorway
}

alias OneCubicalDoorway, as: D

pack = fn mesh ->
  vertices = Enum.uniq(mesh.vertices)
  indices = vertices |> Enum.with_index() |> Map.new()

  %{
    vertices: vertices,
    faces: Enum.map(mesh.faces, fn f -> Enum.map(f, &Map.fetch!(indices, &1)) end),
    convex_cells:
      Enum.map(Map.get(mesh, :cells, []), fn cell ->
        Enum.map(cell.faces, fn f -> Enum.map(f, &Map.fetch!(indices, &1)) end)
      end),
    source_course: Map.get(mesh, :source_course),
    sections: Map.get(mesh, :sections)
  }
end

s = RoomFromHere.new()
m = RoomFromHere.model(s)
measure = D.measurements(m)

pieces =
  Enum.map(m.doorway.pieces, fn p ->
    p
    |> Map.drop([:geometry, :source_geometry])
    |> Map.put(:source_mesh, pack.(p.source_geometry))
    |> Map.put(:pose_mesh, pack.(p.geometry))
  end)

commands =
  List.duplicate(
    [
      :trace,
      :select,
      :place,
      :open,
      {:progress, 0.25},
      {:progress, 0.5},
      {:progress, 0.75},
      {:progress, 1.0},
      :needle,
      {:progress, 0.25},
      {:progress, 0.5},
      {:progress, 0.75},
      {:progress, 1.0}
    ],
    4
  )
  |> List.flatten()

{_, succession} =
  Enum.reduce(commands, {s, []}, fn command, {before, rows} ->
    {:ok, after_state} = RoomFromHere.change(before, before.revision, {:doorway, command})
    observed = RoomFromHere.model(after_state)

    row = %{
      expected_revision: before.revision,
      command:
        if(is_tuple(command), do: ["progress", elem(command, 1)], else: [Atom.to_string(command)]),
      event: List.last(after_state.events),
      phase: after_state.doorway.phase,
      completed: after_state.doorway.completed,
      moving_index: after_state.doorway.index,
      source_digest: observed.source_digest,
      letters:
        for(
          p <- observed.doorway.pieces,
          String.starts_with?(p.id, "doorway:letter-"),
          do: %{
            source: p.source_identity,
            source_hash: p.content_hash,
            translation: p.evidence.position,
            visible: p.active_letter
          }
        ),
      leaf_degrees:
        if(after_state.doorway.phase in ~w(open passing passed offloading), do: 90, else: 0),
      acquired_delta: 0
    }

    {after_state, rows ++ [row]}
  end)

source_paths =
  ~w(lib/public_situation_machine_turn_zero/workshop/one_cubical_doorway.ex lib/public_situation_machine_turn_zero/workshop/room_from_here.ex lib/public_situation_machine_turn_zero/workshop/room_toy_box.ex lib/public_situation_machine_turn_zero/workshop/room_ribbon.ex lib/public_situation_machine_turn_zero/workshop/co_building_geometry.ex lib/public_situation_machine_turn_zero/workshop/material_ribbon.ex lib/public_situation_machine_turn_zero_web/components/one_cubical_doorway_panel.ex lib/public_situation_machine_turn_zero_web/components/room_toy_box_panel.ex lib/public_situation_machine_turn_zero_web/live/architecture_live.ex assets/css/room_toy_box.css docs/architecture/geometry/one-cubical-doorway-addendum-2026-11-17.txt docs/architecture/geometry/diagrams/export_one_cubical_doorway.exs)

sources =
  Map.new(source_paths, fn path ->
    {path, :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)}
  end)

dependencies =
  for name <- ~w(room-from-here-v12-witness.json room-toy-box-v11-witness.json) do
    path = Path.join(__DIR__, name)
    %{file: name, sha256: :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)}
  end

box_meshes = %{
  Table_A: pack.(Map.fetch!(m.doorway.alternatives.table_A, :COB)),
  Door_A: pack.(m.doorway.alternatives.door_A.unit_at_monitor)
}

measurement =
  measure
  |> Map.update!(:leaf_swing, fn value -> Map.update!(value, :conservative_envelope, pack) end)

old_pieces = Enum.filter(m.pieces, &(not String.starts_with?(&1.id, "doorway:")))
old_source_hashes = Map.new(old_pieces, &{&1.id, &1.content_hash})

witness = %{
  contract: D.contract(),
  inherited_inspection_contract: m.contract,
  unit: "inherited trial extent; unscaled source material",
  frame: m.frame,
  THREE: m.three,
  table: m.doorway.table,
  correspondence: m.doorway.correspondence,
  alternatives: %{
    geometry: box_meshes,
    rationale: Map.drop(m.doorway.alternatives, [:table_A, :door_A])
  },
  parts: pieces,
  measurements: measurement,
  letter_succession: succession,
  source_digest: m.source_digest,
  preserved_v12_source_hashes: old_source_hashes,
  dependencies: dependencies,
  source_files: sources,
  constitutional: m.doorway.protected,
  source_R_profile: pack.(Enum.find(m.pieces, &(&1.id == "room:R")).source_geometry),
  original_M_profile: pack.(Enum.find(m.pieces, &(&1.id == "room:M")).source_geometry),
  R62: PublicSituationMachineTurnZero.Workshop.TupleExcursionInheritance.model(m),
  active_scope:
    "constructed prospective material; neutral locked Seat/Table source pose; conditional Needle appointment is not actual stitching"
}

encoded = Jason.encode!(witness, pretty: true) <> "\n"
File.write!(Path.join(__DIR__, "one-cubical-doorway-v13-witness.json"), encoded)

IO.puts(
  "Exported #{length(pieces)} new material records and #{length(succession)} ordered rehearsal records; exact swept-body proof retained."
)
