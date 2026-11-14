alias PublicSituationMachineTurnZero.Workshop.{HereWedging,GeometryExploration}
File.write!(Path.join(__DIR__,"here-wedging-witness.json"),Jason.encode!(%{geometry_contract: GeometryExploration.version(),scope: :geometry_preview,model: HereWedging.model()},pretty: true))
