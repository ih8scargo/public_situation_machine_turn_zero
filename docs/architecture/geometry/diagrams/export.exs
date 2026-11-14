# Run: elixir -pa _build/test/lib/public_situation_machine_turn_zero/ebin -pa _build/test/lib/jason/ebin docs/architecture/geometry/diagrams/export.exs
alias PublicSituationMachineTurnZero.Workshop.GeometryExploration, as: G
{:ok,s}=G.operate(G.new(),0,:furnish_frame)
{:ok,s}=G.operate(s,1,:propose_coil)
{:ok,s}=G.operate(s,2,:propose_coil)
File.write!(Path.join(__DIR__,"geometry-witness.json"),Jason.encode!(Map.put(G.model(s), :outward_specimen,G.specimen("crossing",90,"y")),pretty: true))
