defmodule PublicSituationMachineTurnZero.SteelingTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop, as: W
  alias W.{Steeling, LegacyV1}

  test "25 stable indexed identities, four groups, and independent U13/N18 returns" do
    s = W.new()["steeling"]
    assert length(s["stations"]) == 25
    assert Enum.map(s["stations"], & &1["index"]) == Enum.to_list(1..25)
    assert length(Enum.uniq_by(s["stations"], & &1["id"])) == 25
    assert Enum.map_join(s["stations"], & &1["letter"]) == "THEPUBLICSITUATIONMACHINE"

    assert Enum.map(~w(THE PUBLIC SITUATION MACHINE), fn group ->
             Enum.count(s["stations"], &(&1["group"] == group))
           end) == [3, 6, 9, 7]

    assert Enum.at(s["stations"], 12)["letter"] == "U"
    assert Enum.at(s["stations"], 17)["letter"] == "N"
    assert s["u_return"]["id"] != s["n_return"]["id"]
    assert s["u_return"]["point"] != s["n_return"]["point"]
    assert hd(s["stations"])["point"] == [0.0, 0.0, 0.0]
    assert List.last(s["the_public"]["samples"]) == hd(s["situation"]["points"])
    assert s["the_public"]["representation"] == "cubic Bezier"
  end

  test "corrected initial intervals retain all four volumes and architectural center is not midpoint" do
    m = W.new()
    assert m["positions"] == %{"tc" => 0, "ch" => 6}
    assert m["entities"]["tc"]["frame"]["origin"] == [0, 0, -3]
    assert m["entities"]["ch"]["frame"]["origin"] == [6, 0, -3]
    assert m["entities"]["central"]["frame"]["origin"] == [12, 0, -3]
    assert m["entities"]["lower"]["frame"]["origin"] == [12, -6, -3]
    assert m["assembly"]["longitudinal_extents"] == 18
    assert m["assembly"]["name"] == "THIS ONE RE-STEPPING AND MAY BE RE-STOMPING CONTRAPTION"
    assert Enum.all?(Map.values(m["entities"]), &(&1["dimensions"] == [6, 6, 6]))
  end

  test "editable N heading and reach derive MACHINE from N without relocating U or cube frames" do
    m = W.new()

    for heading <- [105, 123, 135, 165], reach <- [3, 5.5, 8] do
      p = %{Steeling.defaults() | "n_heading" => heading, "machine_reach" => reach}
      {:ok, next} = W.operate(m, 0, {:steeling, p})
      s = next["steeling"]
      assert s["u_return"] == m["steeling"]["u_return"]
      assert Enum.take(s["stations"], 18) == Enum.take(m["steeling"]["stations"], 18)
      assert s["machine"]["origin"] == s["n_return"]["point"]
      assert s["machine"]["inherited_from"] == s["n_return"]["id"]
      assert hd(s["machine"]["points"]) == s["n_return"]["point"]
      assert List.last(s["n_return"]["points"]) == List.last(s["machine"]["points"])
      assert Enum.zip_with(s["n_return"]["outgoing"], [-3, 3, 0], &(&1 * &2)) |> Enum.sum() > 0
      assert next["entities"] == m["entities"]
      assert next["turn"] == m["turn"]
    end
  end

  test "stations are not equally spaced and PUBLIC/SITUATION are members of one inspectable plane" do
    s = W.new()["steeling"]
    assert length(s["gallery"]["members"]) == 15
    for station <- Enum.slice(s["stations"], 3, 15), do: assert(Enum.at(station["point"], 2) == 0)
    assert Enum.at(s["stations"], 3)["references"] == ["the-public-curve", "gallery-plane"]

    distances =
      s["stations"]
      |> Enum.map(& &1["point"])
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] ->
        Enum.zip_with(a, b, &:math.pow(&1 - &2, 2)) |> Enum.sum() |> :math.sqrt()
      end)

    assert Enum.max(distances) - Enum.min(distances) > 0.5
  end

  test "course operations are revision guarded, recorded in LOCK and restored without carriage changes" do
    m = W.new()
    {:ok, next} = W.operate(m, 0, {:steeling, %{Steeling.defaults() | "approach_bend" => 5}})
    assert {:error, :stale_revision} = W.operate(next, 0, :lock)
    {:ok, locked} = W.operate(next, 1, :lock)
    assert hd(locked["witnesses"])["snapshot"]["steeling"] == next["steeling"]
    assert {:error, :unavailable} = W.operate(locked, 2, {:steeling, Steeling.defaults()})

    assert {:ok, ^locked, %{"regarding" => "transverse", "yaw" => 63}} =
             W.import(W.export(locked, "transverse", 63))

    {:ok, released} = W.operate(locked, 2, :release)
    {:ok, reset} = W.operate(released, 3, :reset_steeling)
    assert reset["steeling"] == m["steeling"]
    assert reset["positions"] == m["positions"]
    assert reset["witnesses"] == locked["witnesses"]

    assert {:error, :invalid_parameters} =
             W.operate(m, 0, {:steeling, %{Steeling.defaults() | "n_heading" => 90}})

    bad =
      Jason.decode!(W.export(next, "front"))
      |> put_in(["construction", "steeling", "u_return", "point"], [0, 0, 0])

    assert {:error, :invalid_witness} = W.import(Jason.encode!(bad))

    malformed =
      Jason.decode!(W.export(next, "front")) |> put_in(["construction", "steeling"], "not a map")

    assert {:error, :invalid_witness} = W.import(Jason.encode!(malformed))
  end

  test "schema-1 witnesses preserve geometry and LOCK exactly; migration creates a new construction with full source" do
    fixture =
      File.read!(Path.expand("../fixtures/workshop_milestone_one.json", __DIR__))
      |> Jason.decode!()

    assert %{LegacyV1.new() | "construction_id" => fixture["construction_id"]} == fixture
    {:ok, old} = LegacyV1.operate(fixture, 0, {:move, "ch", 4})
    {:ok, old} = LegacyV1.operate(old, 1, :lock)
    json = LegacyV1.export(old, "reverse")
    assert {:ok, ^old, %{"regarding" => "reverse", "yaw" => 0}} = W.import(json)
    assert Jason.decode!(W.export(old, "reverse")) == Jason.decode!(json)
    assert {:error, :legacy_read_only} = W.operate(old, 2, :release)
    {:ok, migrated} = W.migrate_legacy(old, "reverse")
    assert migrated["construction_id"] != old["construction_id"]
    assert migrated["legacy_source"] == Jason.decode!(json)
    assert is_nil(migrated["lock"])
    assert migrated["positions"] == %{"tc" => 0, "ch" => 6}
    assert {:ok, ^migrated, _} = W.import(W.export(migrated, "front"))
    {:ok, locked} = W.operate(migrated, 0, :lock)
    assert {:ok, ^locked, _} = W.import(W.export(locked, "front"))
    assert locked["legacy_source"]["construction"]["witnesses"] == old["witnesses"]
  end
end
