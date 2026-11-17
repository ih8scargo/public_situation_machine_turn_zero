alias PublicSituationMachineTurnZero.Workshop.JanusiteInheritance, as: J

File.write!(
  Path.join(__DIR__, "janusite-witness.json"),
  Jason.encode!(
    %{
      scope: :geometry_preview,
      source_module: "JanusiteInheritance.model/1",
      state: J.new(),
      model: J.model(J.new()),
      two_fixture: J.model(%{J.new() | footing: "two", hypothetical?: true}).inheritance
    },
    pretty: true
  )
)
