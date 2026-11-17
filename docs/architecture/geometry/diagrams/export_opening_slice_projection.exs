alias PublicSituationMachineTurnZero.Workshop.{
  RoomFromHere,
  OpeningSliceProjection,
  OneCubicalDoorway,
  CoBuilding,
  LetterTransformInspection
}

alias OpeningSliceProjection, as: P

step = fn s, cmd ->
  {:ok, n} = RoomFromHere.change(s, s.revision, cmd)
  n
end

initial = RoomFromHere.new()
base = RoomFromHere.model(initial)

{states, _} =
  Enum.reduce(0..3, {[initial], initial}, fn _, {states, s} ->
    a = step.(s, {:slice_projection, :appoint})
    b = step.(a, {:slice_projection, :open})
    c = step.(b, {:slice_progress, 1.0})
    d = step.(c, {:slice_projection, :resolve})
    e = step.(d, {:slice_projection, :next})
    {states ++ [a, c, d, e], e}
  end)

snapshots =
  Enum.map(states, fn s ->
    m = RoomFromHere.model(s)

    %{
      revision: s.revision,
      state: s.opening_projection,
      ROOM: m.frame,
      source_digest: m.source_digest,
      report: Map.drop(m.opening_projection, [:extras, :records]),
      resolved_material_refs:
        Enum.map(m.opening_projection.records, & &1.reservation.source_identity),
      token_pose: Enum.find(m.pieces, &(&1.id == "projection:opening-slice")).standing_locality,
      acquired_delta: m.acquisition.index_delta
    }
  end)

toe = LetterTransformInspection.record(base, LetterTransformInspection.new()).toe.unit_point

inverse =
  for i <- 0..3, q <- [[-0.5, -0.5, -0.5], [0, 0, 0], [0.5, 0.5, 0.5], toe] do
    world = P.resolve_point(i, q)
    {:ok, recovered} = P.inverse_point(i, world)
    %{ordinal: i, source_point: q, resolved_point: world, recovered: recovered}
  end

witness = %{
  contract: P.contract(),
  dependencies: [
    "one-cubical-doorway-v13-witness.json / parts",
    "lib/public_situation_machine_turn_zero/workshop/snail_body.ex / arc_frame, arc_length"
  ],
  new_profiles:
    base.pieces
    |> Enum.filter(&String.starts_with?(&1.id, "projection:"))
    |> Enum.map(&Map.take(&1, [:id, :source_identity, :source_geometry, :content_hash])),
  resolved_material:
    RoomFromHere.model(List.last(states)).pieces
    |> Enum.filter(&Map.has_key?(&1.evidence, :projection_resolution))
    |> Enum.map(
      &Map.take(&1, [:id, :source_geometry, :geometry, :content_hash, :standing_locality])
    ),
  face_provenance: RoomFromHere.model(List.last(states)).opening_projection.records,
  law: P.law(),
  measurements: P.measurements(base),
  prior_port_measurements: OneCubicalDoorway.measurements(base),
  snapshots: snapshots,
  inverse_witnesses: inverse,
  prior_79_source_hashes:
    base.pieces
    |> Enum.reject(&String.starts_with?(&1.id, "projection:"))
    |> Map.new(&{&1.id, &1.content_hash}),
  digest_encoding: CoBuilding.digest(%{contract: P.contract()})
}

File.write!(
  "docs/architecture/geometry/diagrams/opening-slice-projection-v15-witness.json",
  Jason.encode!(witness, pretty: true) <> "\n"
)

IO.puts("Exported #{length(snapshots)} source-bound snapshots; acquired delta ZERO.")
