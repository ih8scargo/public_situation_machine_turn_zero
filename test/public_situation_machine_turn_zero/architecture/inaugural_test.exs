defmodule PublicSituationMachineTurnZero.InauguralTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Inaugural, as: I

  defp appointed do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 10, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 0, "pitch" => 0, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    m
  end

  defp op(m, action, rev, extra \\ %{}),
    do: A.operate(m, {:inaugural, Map.merge(%{"action" => action, "revision" => rev}, extra)})

  test "three puffing affordances remain ordered without overwriting constitutional source" do
    m = appointed()
    source = m.standing
    assert I.model(m)["first"]
    assert {:error, :unavailable} = op(m, "puff-over-across", 0)
    {:ok, m} = op(m, "puff-across", 0)
    assert {:error, :unavailable} = op(m, "detent", 1, %{"distance" => 0})
    {:ok, m} = A.operate(m, {:traversal_rehearsal, %{"action" => "appoint", "revision" => 0}})
    distance = m.standing["traversal_rehearsal"]["course"]["base_length"]
    {:ok, m} = op(m, "detent", 1, %{"distance" => distance})
    {:ok, m} = op(m, "puff-over-across", 2)
    assert I.model(m)["over_across"]
    assert {:error, :unavailable} = op(m, "puff-over-across", 3)
    assert Map.drop(m.standing, ["inaugural_approach", "traversal_rehearsal"]) == source
    assert A.restore(m.standing).standing == m.standing
    assert I.model(m)["cabinet_seat"]["occupant"] == "doll"
    refute I.model(m)["cabinet_seat"]["agentive"]
    assert length(I.model(m)["reference_extents"]) == 3
    assert I.model(m)["segments"] == 8
  end
end
