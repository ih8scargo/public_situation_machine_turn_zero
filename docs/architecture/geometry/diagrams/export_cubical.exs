alias PublicSituationMachineTurnZero.Workshop.CubicalConstruction, as: C

model = C.model()
payload = %{
  geometry_contract: C.version(),
  scope: :geometry_preview,
  source_module: "CubicalConstruction.model/1",
  inherited_contract: model.frame.geometry_version,
  model: model,
  reference_comparisons: Enum.map(~w(FOUR SIX EIGHT), &C.gauge/1),
  presentations: Enum.map(~w(flat tunneling reciprocal return), fn facet ->
    {:ok, state} = C.change(C.new(), 0, {:facet, facet})
    %{facet: facet, yaw: state.yaw, projected_frame: C.project(model.vertices,state)}
  end)
}
File.write!(Path.join(__DIR__,"cubical-witness.json"),Jason.encode!(payload,pretty: true))
