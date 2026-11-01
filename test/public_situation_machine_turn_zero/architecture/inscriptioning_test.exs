defmodule PublicSituationMachineTurnZero.InscriptioningTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Inscriptioning, as: I

  test "each accomplished event retains its convertible XT-axle surface and provenance" do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 12, "dy" => 0}})
    first = hd(I.retained(m.standing))
    assert first["id"] == "xt-axle-first-pull"
    assert first["provenance"] == "first-pull"
    assert first["frame"] == "grounded-xt-axle"
    assert hd(m.standing["events"])["inscription_locality"] == I.locality("first-pull")
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 19, "pitch" => 6, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    {:ok, m} = A.operate(m, :second_puff)
    standing = m.standing
    assert length(I.retained(standing)) == 4
    assert hd(I.retained(standing)) == first

    for surface <- I.retained(standing) do
      assert Map.has_key?(standing["relations"], surface["relation"])
      assert surface["provenance"] in Enum.map(standing["events"], & &1["id"])
      assert length(surface["surface"]) == 4
    end

    {:ok, inspected} = A.operate(m, {:inspect, "pointingable-standing"})
    assert inspected.standing == standing
    assert I.retained(A.restore(standing).standing) == I.retained(standing)
    assert A.restore(standing).regarding.bearing == A.new().regarding.bearing
    assert length(standing["events"]) == 4
  end

  test "older snapshots recover deterministic localities without rewriting consequential records" do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 8, "dy" => 0}})

    old =
      Map.update!(m.standing, "events", fn events ->
        Enum.map(events, &Map.delete(&1, "inscription_locality"))
      end)

    surfaces = I.retained(old)
    assert surfaces == I.retained(m.standing)
    refute Map.has_key?(hd(old["events"]), "inscription_locality")
    assert I.retained(old) == I.retained(A.restore(old).standing)
  end
end
