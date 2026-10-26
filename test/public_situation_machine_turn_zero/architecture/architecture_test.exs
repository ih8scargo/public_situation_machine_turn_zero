defmodule PublicSituationMachineTurnZero.ArchitectureTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A

  @appointments [
    "approach",
    "appoint-cob",
    "furnish-pretend",
    "appoint-pointing",
    "stand-tc",
    "stand-place"
  ]

  defp drive(actions, m \\ A.new()) do
    Enum.reduce(actions, m, fn action, m ->
      assert {:ok, next} = A.operate(m, action)
      next
    end)
  end

  test "approach starts with differentiated givens and an empty trace, without a future Place or Landinging" do
    m = A.new()
    assert m.standing["stations"] == []
    assert m.standing["events"] == []
    assert m.standing["from"]["up_on"] == "landinging-here"
    assert m.standing["from"]["temporal_purchase"] == "time-here"
    assert m.standing["relations"]["human-up-on"]["object"] == "landinging-here"
    assert m.standing["relations"]["landinging-upon-time"]["object"] == "time-here"
    refute A.furnished?(m, "place-standing")
    refute Enum.any?(m.standing["relations"], fn {_, r} -> r["object"] == "landinging-there" end)
    assert {:error, :unavailable} = A.operate(m, "stand-place")
    assert {:error, :unavailable} = A.operate(m, "seat")
    assert {:error, :unavailable} = A.operate(m, "step")
  end

  test "four completed Appointmentings accumulate; FIRST's two labors are one locality" do
    m = drive(["approach", "appoint-cob"])
    assert Enum.map(m.standing["stations"], & &1["id"]) == ["zeroeth"]
    m = drive(["furnish-pretend"], m)
    assert length(m.standing["stations"]) == 1
    assert m.standing["relations"]["pretend-pointing"]["object"] == "terrestrial-computer"
    assert m.standing["relations"]["pretend-toward-pointing"]["object"] == "pointingable"
    m = drive(["appoint-pointing", "stand-tc", "stand-place"], m)
    assert Enum.map(m.standing["stations"], & &1["id"]) == ["zeroeth", "first", "second", "third"]
    assert length(m.standing["events"]) == 6
  end

  test "Second makes Place furnishable, but only Third furnishes it THERE without arrival" do
    before = drive(Enum.take(@appointments, 4))
    assert {:error, :unavailable} = A.operate(before, "stand-place")
    second = drive(["stand-tc"], before)
    assert A.furnished?(second, "tc-down-under")
    assert second.standing["relations"]["tc-down-under"]["relation"] == "FROM DOWN UNDER"
    refute A.furnished?(second, "place-standing")
    refute A.furnished?(second, "landinging-staging")
    third = drive(["stand-place"], second)
    assert third.standing["relations"]["machine-through-tc"]["object"] == "terrestrial-computer"
    assert "tc-down-under" in third.standing["relations"]["place-standing"]["dependencies"]
    assert third.standing["relations"]["place-upon-landinging"]["object"] == "landinging-there"
    assert third.standing["relations"]["next-landinging-upon-time"]["object"] == "time-there"
    assert third.standing["relations"]["rugging-for-place"]["subject"] != "place"
    assert third.standing["from"] == A.new().standing["from"]
    refute A.within?(third)
    assert {:error, :unavailable} = A.operate(third, "step")
  end

  test "seating stages an actual way THROUGH Current Local Moment, then STEP alone changes FROM" do
    third = drive(@appointments)
    seated = drive(["seat"], third)
    assert seated.standing["from"] == third.standing["from"]
    assert seated.standing["passages"] == []
    assert seated.standing["relations"]["human-seated"]["object"] == "place"
    assert seated.standing["relations"]["moment-way-through"]["subject"] == "current-local-moment"
    assert seated.standing["relations"]["moment-way-through"]["object"] == "passage"
    within = drive(["step"], seated)
    assert A.within?(within)
    assert within.standing["from"]["up_on"] == "landinging-there"
    assert within.standing["from"]["within"] == "place"
    assert within.standing["from"]["temporal_purchase"] == "time-there"
    assert within.standing["relations"]["human-from-here"]["fulfilled_by"] == "step"
    [passage] = within.standing["passages"]
    assert passage["from"] == third.standing["from"]
    assert passage["standing_toward"] == "place-toward-human"
    assert passage["approaching_landinging"] == "landinging-there"
    assert passage["by_way_of"] == "current-local-moment"
    assert passage["consequent_from"] == within.standing["from"]
    assert passage["from_temporal_purchase"] != passage["toward_temporal_purchase"]
    assert A.next(within).action == nil
    assert length(within.standing["stations"]) == 4
    assert {:error, :unavailable} = A.operate(within, "step")
    assert {:error, :unavailable} = A.operate(within, "inner-aperture")
  end

  test "every beat preserves actual local ancestry and structured In-Stringing consequences" do
    Enum.reduce(@appointments ++ ["seat", "step"], A.new(), fn action, before ->
      beat = A.next(before)
      assert {:ok, m} = A.operate(before, action)
      event = List.last(m.standing["events"])
      assert event["actor"] == "human"
      assert event["from"] == before.standing["from"]
      assert event["from_after"] == m.standing["from"]
      assert event["inherited_before"] == Enum.sort(Map.keys(before.standing["relations"]))
      assert Enum.map(event["ancestry"], & &1["id"]) == event["dependencies"]

      for r <- event["ancestry"] do
        assert Map.delete(r, "id") == before.standing["relations"][r["id"]]
      end

      assert event["semantical_in_stringing_menting"] == beat.consequences
      assert event["labor_toward"] == event["consequences"]
      assert Enum.all?(event["consequences"], &(&1 in event["inherited_after"]))
      assert event["next_for"] == A.next(m).for
      assert {:error, :unavailable} = A.operate(m, action)
      if action != "step", do: assert(m.standing["from"] == before.standing["from"])
      m
    end)
  end

  test "Regarding cannot invent localities, change FROM, or become consequential" do
    m = drive(@appointments)
    assert {:error, :unavailable} = A.operate(m, {:regard, "future-gallery"})

    for id <- ["zeroeth", "first", "second", "third"] do
      assert {:ok, regarded} = A.operate(m, {:regard, id})
      assert regarded.standing == m.standing
      assert A.restore(regarded.standing).regarding == nil
      assert {:ok, ^m} = A.operate(regarded, :clear_regard)
    end
  end

  test "Round One ancestry can be inspected but is never rewritten into the new succession" do
    standing = %{
      "version" => "spindle-round-one",
      "relations" => %{"place-standing" => %{}},
      "events" => [],
      "from" => %{"up_on" => "standinging-landinging"}
    }

    m = A.restore(standing)
    assert A.legacy?(m)
    assert m.standing == standing
    assert A.next(m).action == nil
    assert {:error, :unavailable} = A.operate(m, "stand-tc")
  end
end
