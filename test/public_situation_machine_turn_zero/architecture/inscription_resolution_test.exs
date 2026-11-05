defmodule PublicSituationMachineTurnZero.Architecture.InscriptionResolutionTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias A.{CrossingRehearsal, InscriptionResolution}

  defp near(a, b), do: Enum.zip_with(a, b, &abs(&1 - &2)) |> Enum.all?(&(&1 < 1.0e-9))

  test "PUBLIC belongs to bend and face without copying the 25 letter identities" do
    model = InscriptionResolution.model()
    letters = model["letters"]
    assert Enum.map_join(letters, & &1["letter"]) == "THEPUBLICSITUATIONMACHINE"
    assert length(Enum.uniq_by(letters, & &1["id"])) == 25

    assert Enum.frequencies_by(letters, & &1["word"]) == %{
             "THE" => 3,
             "PUBLIC" => 6,
             "SITUATION" => 9,
             "MACHINE" => 7
           }

    assert Enum.all?(Enum.filter(letters, &(&1["word"] == "PUBLIC")), fn l ->
             l["relations"] == ["the-public-bend", "public-situation-face"]
           end)

    assert Enum.at(letters, 17)["letter"] == "N"
    assert "situation-n-twist" in Enum.at(letters, 17)["relations"]
    assert model["twist"]["letter_id"] == Enum.at(letters, 17)["id"]
    assert model["twist"]["angle"] == nil
    assert List.last(model["relations"])["through"] == model["twist"]["relation"]
    assert model["end_bearing"] == "XT toward XT"
  end

  test "trial arcs and surface edges join continuously through words and N; return restores tangent without asserting spatial closure" do
    letters = InscriptionResolution.model()["letters"]

    for [a, b] <- Enum.chunk_every(letters, 2, 1, :discard) do
      last = List.last(a["samples"])
      first = hd(b["samples"])
      assert near(last["point"], first["point"])
      assert near(last["tangent"], first["tangent"])
      for {a, b} <- Enum.zip(last["edges"], first["edges"]), do: assert(near(a, b))
    end

    first = hd(hd(letters)["samples"])
    last = List.last(List.last(letters)["samples"])
    assert near(first["tangent"], last["tangent"])
    refute near(first["point"], last["point"])
  end

  test "derived resolution survives JSON restore without moving FROM, adding events or changing the appointed instrument" do
    m = A.new()
    {:ok, m} = CrossingRehearsal.operate(m, %{"action" => "pull", "value" => 1, "revision" => 0})
    {:ok, m} = CrossingRehearsal.operate(m, %{"action" => "feed", "value" => 1, "revision" => 1})

    {:ok, m} = CrossingRehearsal.operate(m, %{"action" => "lock", "revision" => 2})

    {:ok, m} =
      CrossingRehearsal.operate(m, %{"action" => "receive", "value" => 1, "revision" => 3})

    before = m.standing
    expected = CrossingRehearsal.model(m)["inscription_resolution"]
    restored = A.restore(Jason.decode!(Jason.encode!(before)))
    assert CrossingRehearsal.model(restored)["inscription_resolution"] == expected
    assert restored.standing["from"] == before["from"]
    assert restored.standing["events"] == before["events"]

    assert restored.standing["opening_geometry"]["stick"] ==
             Jason.decode!(Jason.encode!(before["opening_geometry"]["stick"]))

    assert m.standing == before
  end
end
