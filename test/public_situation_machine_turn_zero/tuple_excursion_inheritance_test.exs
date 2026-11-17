defmodule PublicSituationMachineTurnZero.TupleExcursionInheritanceTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.{RoomToyBox, TupleExcursionInheritance}

  test "material purchases retain distinct identities from reciprocal Regarding and projected return" do
    toy = RoomToyBox.model(RoomToyBox.new())
    m = TupleExcursionInheritance.model(toy)
    assert length(m.entries) == 5
    assert length(Enum.uniq_by(m.entries, & &1.source_identity)) == 5
    by_id = Map.new(m.entries, &{&1.id, &1})
    assert by_id["tuple:re-step-wall"].standing_locality.office == "FOUR–FIVE Tuple seam"
    assert by_id["tuple:gimbalizing-piton"].evidence.finite_profile == nil

    assert by_id["toybox:regarding-five"].evidence.material_equivalence_to_purchase_surface ==
             :unproved

    assert by_id["tuple:six-return-reference"].evidence.physical_return_join == nil
    assert Enum.map(m.correspondences, & &1.stand.id) == ~w(FOUR FIVE SIX)

    for c <- m.correspondences do
      assert c.stand == Enum.find(toy.stands, &(&1.id == c.stand.id))
      assert c.material_transform == nil
      assert c.physical_equivalence == :unproved
    end

    for entry <- m.entries do
      assert entry.geometry == nil
      assert entry.affordment == :inspection_only
      assert entry.standing_locality.toybox_material_transform == nil
    end

    assert m.relations |> Enum.at(1) |> Map.take([:origin, :object, :ordered_prepositioning]) ==
             %{
               origin: "tuple:re-step-wall",
               object: "tuple:purchase-surface-five",
               ordered_prepositioning: ["FROM", "TOWARD"]
             }

    assert m.operation.acquired_delta == 0
    refute m.operation.push_off_alone_permits_re_step
  end
end
