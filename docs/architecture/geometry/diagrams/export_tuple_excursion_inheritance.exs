alias PublicSituationMachineTurnZero.Workshop.{RoomToyBox, TupleExcursionInheritance}

sources = ~w(
lib/public_situation_machine_turn_zero/workshop/tuple_excursion_inheritance.ex
lib/public_situation_machine_turn_zero/workshop/room_toy_box.ex
lib/public_situation_machine_turn_zero/workshop/rail_recovery.ex
lib/public_situation_machine_turn_zero_web/live/canonical_tuple_live.ex
docs/architecture/geometry/re-step-wall-canonical-inheritance-2026-11-16.txt
)

witness =
  RoomToyBox.new()
  |> RoomToyBox.model()
  |> TupleExcursionInheritance.model()
  |> Map.put(:source_files, Map.new(sources, fn path ->
    {path, :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)}
  end))

File.write!(Path.join(__DIR__, "tuple-excursion-inheritance-v1.json"), Jason.encode!(witness, pretty: true) <> "\n")
