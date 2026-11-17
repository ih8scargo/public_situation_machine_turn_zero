alias PublicSituationMachineTurnZero.Workshop.{RoomFromHere, LetterTransformInspection}

pack = fn mesh ->
  vertices = Enum.uniq(mesh.vertices)
  indices = vertices |> Enum.with_index() |> Map.new()

  %{
    vertices: vertices,
    faces: Enum.map(mesh.faces, fn f -> Enum.map(f, &Map.fetch!(indices, &1)) end)
  }
end

s = RoomFromHere.new()
base = RoomFromHere.model(s)

configs = [
  %{LetterTransformInspection.new() | active: true},
  %{LetterTransformInspection.new() | active: true, door: 45.0},
  %{LetterTransformInspection.new() | active: true, door: 90.0},
  %{LetterTransformInspection.new() | active: true, door: 90.0, bearing: 90.0}
]

configs =
  configs ++
    Enum.map(
      [0.0, 0.25, 0.5, 0.75, 1.0],
      &%{LetterTransformInspection.new() | active: true, door: 90.0, bearing: 30.0, curvature: &1}
    )

snapshots =
  Enum.map(configs, fn config ->
    state = %{s | letter_inspection: config}
    m = RoomFromHere.model(state)
    r = m.letter_inspection

    r
    |> Map.drop([:posed_geometry, :posed_allocation])
    |> Map.merge(%{
      controls: config,
      material_mesh: pack.(r.posed_geometry),
      allocation_mesh: pack.(r.posed_allocation),
      camera: RoomFromHere.camera(state, m),
      source_digest: m.source_digest,
      acquired_delta: 0
    })
  end)

paths =
  ~w(lib/public_situation_machine_turn_zero/workshop/letter_transform_inspection.ex lib/public_situation_machine_turn_zero/workshop/room_from_here.ex lib/public_situation_machine_turn_zero/workshop/one_cubical_doorway.ex lib/public_situation_machine_turn_zero_web/components/letter_transform_panel.ex lib/public_situation_machine_turn_zero_web/components/room_toy_box_panel.ex lib/public_situation_machine_turn_zero_web/live/architecture_live.ex docs/architecture/geometry/same-letter-clarification-2026-11-17.txt docs/architecture/geometry/diagrams/export_letter_transform_inspection.exs)

sources =
  Map.new(paths, fn p ->
    {p, :crypto.hash(:sha256, File.read!(p)) |> Base.encode16(case: :lower)}
  end)

letter = Enum.find(base.pieces, &(&1.id == "doorway:letter-R"))
{:error, gate} = RoomFromHere.change(s, 0, {:letter_inspection, :puff})

w = %{
  contract: LetterTransformInspection.contract(),
  scope:
    "independent Regarding and prospective rigid wedging-frame inspection; lawful curvature-standing acceptance remains unbound",
  frame: base.frame,
  source_identity: letter.source_identity,
  source_hash: letter.content_hash,
  source_mesh: pack.(letter.source_geometry),
  source_files: sources,
  snapshots: snapshots,
  preserved_material_hashes: Map.new(base.pieces, &{&1.id, &1.content_hash}),
  PUFFING_gate: %{result: gate, acquired_delta: 0, actual_curvature_standing: false},
  dependency: %{
    file: "one-cubical-doorway-v13-witness.json",
    sha256:
      :crypto.hash(
        :sha256,
        File.read!(Path.join(__DIR__, "one-cubical-doorway-v13-witness.json"))
      )
      |> Base.encode16(case: :lower)
  }
}

File.write!(
  Path.join(__DIR__, "same-letter-transformations-v14-witness.json"),
  Jason.encode!(w, pretty: true) <> "\n"
)

IO.puts(
  "Exported nine same-source letter snapshots, fixed ROOM and source-toe provenance; PUFFING gate stays blocked."
)
