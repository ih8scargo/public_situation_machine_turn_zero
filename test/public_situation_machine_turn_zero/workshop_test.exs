defmodule PublicSituationMachineTurnZero.WorkshopTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop, as: W
  alias W.Geometry

  test "four registered cubes retain dimensions, distinct surfaces, frames and rail length" do
    m = W.new()
    assert m["rail"]["length"] == 18
    assert m["rail"]["start"] == [0, 0, 0]
    assert m["rail"]["end"] == [18, 0, 0]
    assert map_size(m["entities"]) == 4

    for {id, cube} <- m["entities"] do
      assert cube["id"] == id
      assert cube["dimensions"] == [6, 6, 6]
      assert length(cube["edges"]) == 12
      assert length(cube["surfaces"]) == 6

      for axis <- 0..2 do
        coordinates = Enum.map(cube["vertices"], &Enum.at(&1, axis))
        assert Enum.max(coordinates) - Enum.min(coordinates) == 6
      end
    end

    assert m["entities"]["lower"]["frame"]["origin"] == [12, -6, -3]

    assert Enum.find(m["entities"]["lower"]["surfaces"], &(&1["id"] == "lower-surface-y-min"))[
             "role"
           ] =~ "Ground"

    assert Enum.find(m["entities"]["lower"]["surfaces"], &(&1["id"] == "lower-surface-y-max"))[
             "role"
           ] =~ "Monitor"
  end

  test "independent carriages permit observed overlap and never alter central, lower, rail or turn" do
    m = W.new()
    {:ok, moved} = W.operate(m, 0, {:move, "tc", 8.5})
    assert moved["positions"] == %{"tc" => 8.5, "ch" => 6}
    {:ok, moved} = W.operate(moved, 1, {:move, "ch", 7})
    assert moved["positions"] == %{"tc" => 8.5, "ch" => 7}
    assert length(Geometry.overlaps(moved["positions"])) == 3
    for id <- ~w(central lower), do: assert(moved["entities"][id] == m["entities"][id])
    assert moved["rail"] == m["rail"]
    assert moved["turn"] == m["turn"]
    assert {:error, :unavailable} = W.operate(moved, 2, {:move, "tc", -1})
    assert {:error, :unavailable} = W.operate(moved, 2, {:move, "ch", 12.1})
    assert {:error, :unavailable} = W.operate(moved, 2, :re_step)
    {:ok, reset} = W.operate(moved, 2, :reset)
    assert reset["entities"] == m["entities"]
  end

  test "LOCK records the exact revision, geometry and provenance; release preserves old witness" do
    m = W.new()
    {:ok, moved} = W.operate(m, 0, {:move, "ch", 4})
    assert {:error, :stale_revision} = W.operate(moved, 0, :lock)
    {:ok, locked} = W.operate(moved, 1, :lock)
    [record] = locked["witnesses"]
    assert record["revision"] == 2

    assert record["snapshot"] ==
             Map.drop(locked, ["lock", "witnesses", "legacy_source", "rehearsal"])

    assert locked["entities"] == moved["entities"]
    assert {:error, :unavailable} = W.operate(locked, 2, {:move, "ch", 5})
    assert {:error, :stale_revision} = W.operate(locked, 1, :release)
    {:ok, released} = W.operate(locked, 2, :release)
    {:ok, revised} = W.operate(released, 3, {:move, "ch", 5})
    assert revised["witnesses"] == [record]
    assert is_nil(revised["lock"])
    assert revised["turn"] == m["turn"]
  end

  test "portable witness round trips unlocked, locked and released arrangements with separate views" do
    m = W.new()
    {:ok, moved} = W.operate(m, 0, {:move, "tc", 3.2})
    {:ok, locked} = W.operate(moved, 1, :lock)
    {:ok, released} = W.operate(locked, 2, :release)
    {:ok, locked_again} = W.operate(released, 3, :lock)

    for model <- [m, moved, locked, released, locked_again], view <- W.views() do
      assert {:ok, ^model, %{"regarding" => ^view, "yaw" => 0}} = W.import(W.export(model, view))
    end
  end

  test "import rejects edited coordinates, transforms, provenance, LOCK snapshots and foreign schemas" do
    {:ok, locked} = W.operate(W.new(), 0, :lock)
    envelope = Jason.decode!(W.export(locked, "front"))

    invalids = [
      put_in(envelope, ["schema_version"], 4),
      put_in(envelope, ["view", "regarding"], "cab"),
      put_in(envelope, ["construction", "entities", "ch", "dimensions"], [6, 6, 7]),
      put_in(envelope, ["construction", "entities", "ch", "frame", "origin"], [0, 0, 0]),
      put_in(envelope, ["construction", "positions", "ch"], 5),
      put_in(envelope, ["construction", "provenance"], []),
      put_in(envelope, ["construction", "lock"], nil),
      put_in(envelope, ["construction", "witnesses"], []),
      put_in(envelope, ["construction", "turn", "anchored_index"], 1)
    ]

    for invalid <- invalids,
        do: assert({:error, :invalid_witness} = W.import(Jason.encode!(invalid)))

    assert {:error, :invalid_witness} = W.import("{}")
    assert {:error, :invalid_witness} = W.import("not json")
    assert {:error, :invalid_witness} = W.import(String.duplicate("x", 16_000_001))
  end

  test "canonical JS fixture matches the Phoenix model and maximum witness remains portable" do
    fixture =
      File.read!(Path.expand("../fixtures/workshop_initial.json", __DIR__)) |> Jason.decode!()

    assert W.new()
           |> Map.put("construction_id", fixture["construction_id"])
           |> put_in(["rehearsal", "id"], fixture["rehearsal"]["id"]) == fixture

    bounded =
      Enum.reduce(0..99, W.new(), fn revision, model ->
        {:ok, next} =
          W.operate(model, revision, if(rem(revision, 2) == 0, do: :lock, else: :release))

        next
      end)

    json = W.export(bounded, "front")
    assert byte_size(json) <= W.import_limit()
    assert {:ok, ^bounded, %{"regarding" => "front", "yaw" => 0}} = W.import(json)
    assert {:error, :revision_limit} = W.operate(bounded, 100, :lock)
  end

  test "a LOCK at the revision bound can still be released and round-tripped" do
    model =
      Enum.reduce(0..98, W.new(), fn revision, model ->
        {:ok, next} =
          W.operate(model, revision, {:move, "ch", if(rem(revision, 2) == 0, do: 8, else: 9)})

        next
      end)

    {:ok, locked} = W.operate(model, 99, :lock)
    {:ok, released} = W.operate(locked, 100, :release)
    assert released["revision"] == 101
    assert released["witnesses"] == locked["witnesses"]

    assert {:ok, ^released, %{"regarding" => "front", "yaw" => 0}} =
             W.import(W.export(released, "front"))
  end

  test "future interfaces have identity but no invented frames or dimensions" do
    for reservation <- W.new()["reservations"] do
      assert reservation["status"] == "reserved"
      assert is_nil(reservation["frame"])
      assert is_nil(reservation["dimensions"])
    end
  end
end
