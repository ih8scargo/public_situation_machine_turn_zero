defmodule PublicSituationMachineTurnZero.Refolding.ContinuityTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Refolding.{MemoryStore, Proof}

  test "continuity derives consequence and present relations, never a gesture history" do
    store = start_supervised!({MemoryStore, []})
    initial = Proof.return(store, "human")
    act = fn session, action, target -> Proof.gesture(store, "human", session, action, target) end
    initial_line = Proof.continuity(initial)
    assert froms(initial_line) == ["ENZO"]
    assert act.(initial, "step", "HUCKLEBERRY") |> Proof.continuity() == initial_line

    prepared =
      Enum.reduce(["regard", "approach", "seat", "step", "furnish"], initial, fn action, s ->
        act.(s, action, "HUCKLEBERRY")
      end)

    line = Proof.continuity(prepared)
    assert froms(line) == ["ENZO"]

    assert Enum.map(Enum.filter(line, &(&1.scope == :ephemeral)), & &1.kind) ==
             [:apparatus, :regarding, :approach, :seating, :step, :furnishing]

    assert Enum.count(line, &(&1.kind == :regarding)) == 1
    assert act.(prepared, "regard", "HUCKLEBERRY") |> Proof.continuity() == line

    zipped = act.(prepared, "zipper", "HUCKLEBERRY")
    consequence = Enum.filter(Proof.continuity(zipped), &(&1.scope == :consequential))
    assert Enum.map(consequence, & &1.kind) == [:from, :zippering, :from]
    assert froms(consequence) == ["ENZO", "HUCKLEBERRY"]
    altered = act.(zipped, "regard", "ENZO")
    folded = Proof.refold(altered)
    assert Proof.continuity(folded) == consequence
    returned = Proof.return(store, folded.standing.by_way_of)
    returned_line = Proof.continuity(returned)
    assert Enum.filter(returned_line, &(&1.scope == :consequential)) == consequence
    assert Enum.count(returned_line, &(&1.kind == :zippering)) == 1
    assert Enum.find(returned_line, &(&1.kind == :apparatus)).standing == "HUCKLEBERRY"
    refute Enum.any?(returned_line, &(&1.kind in [:approach, :seating, :step, :furnishing]))
    assert returned.standing == zipped.standing
  end

  defp froms(line), do: for(node <- line, node.kind == :from, do: node.standing)
end
