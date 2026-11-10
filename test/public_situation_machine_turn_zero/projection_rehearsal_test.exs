defmodule PublicSituationMachineTurnZero.ProjectionRehearsalTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop, as: W
  alias W.{Projection, Rehearsal, LegacyV2}
  defp collect(m, index), do: W.rehearse(m, m["rehearsal"]["revision"], {:collect, index})

  test "any five indexed stations in arbitrary order record ordered Footings and readiness only at five" do
    for start <- 1..25 do
      initial = W.new()
      order = Enum.map([0, 7, 13, 3, 19], &(rem(start - 1 + &1, 25) + 1))

      final =
        Enum.with_index(order, 1)
        |> Enum.reduce(initial, fn {index, count}, model ->
          {:ok, next} = collect(model, index)
          state = next["rehearsal"]
          assert state["ready"] == (count == 5)
          f = List.last(state["footings"])
          assert f["sequence"] == count
          assert f["before"] == Enum.take(order, count - 1)
          assert f["after"] == Enum.take(order, count)
          assert f["station_index"] == index
          assert f["station_id"] == "steeling-letter-#{index}"
          assert f["station_point"] == Enum.at(next["steeling"]["stations"], index - 1)["point"]
          assert f["source_point"] == Projection.source_point(count)
          assert state["progress"] == 0
          next
        end)

      assert final["rehearsal"]["collected"] == order
      assert length(final["rehearsal"]["footings"]) == 5
      assert final["turn"] == initial["turn"]
      assert final["revision"] == initial["revision"]
      assert final["provenance"] == initial["provenance"]
      assert final["steeling"] == initial["steeling"]
      assert {:ok, ^final} = collect(final, hd(order))
      uncollected = Enum.find(1..25, &(&1 not in order))
      assert {:error, :five_acquired} = collect(final, uncollected)
      assert {:error, :unavailable} = W.operate(final, 0, :re_step)
    end
  end

  test "same character at distinct indices counts twice; duplicate and stale acquisition add no Footing" do
    {:ok, m} = collect(W.new(), 3)
    assert {:ok, ^m} = collect(m, 3)
    assert {:error, :stale_rehearsal} = W.rehearse(m, 0, {:collect, 25})
    {:ok, m} = collect(m, 25)
    assert Enum.map(m["rehearsal"]["footings"], & &1["letter"]) == ["E", "E"]
    assert m["rehearsal"]["collected"] == [3, 25]
    assert Enum.count(m["steeling"]["stations"]) == 25
  end

  test "projection candidates share lower geometry with explicit entry, intersection and matrix" do
    for x <- [-1, 0, 1], z <- [-2, 0, 2] do
      p = Projection.model(%{"oblique_x" => x, "oblique_z" => z})
      assert p["vertical"] == Projection.model(Projection.defaults())["vertical"]
      assert p["vertical"]["source"] == p["oblique"]["source"]
      assert p["source"]["origin"] == [15, -3, 0]
      assert p["vertical"]["direction"] == [0.0, 1.0, 0.0]

      for bearing <- ~w(vertical oblique) do
        b = p[bearing]
        assert Enum.at(b["entry"], 1) == 0
        assert Enum.at(b["exit"], 1) == 6
        delta = Enum.zip_with(b["exit"], b["entry"], &(&1 - &2))

        assert_in_delta :math.sqrt(Enum.reduce(delta, 0, &(&1 * &1 + &2))),
                        b["intersection"]["length"],
                        1.0e-9

        assert b["intersection"]["region"] == "central"

        for i <- 1..5 do
          f = %{
            "id" => "test-#{i}",
            "station_id" => "steeling-letter-#{i}",
            "source_point" => Projection.source_point(i)
          }

          point = Projection.material(p, f)[bearing]["point"]
          [px, py, pz] = point
          assert px >= 12 and px <= 18 and py == 3 and pz >= -3 and pz <= 3

          expected =
            Enum.map(Enum.take(b["matrix"], 3), fn row ->
              Enum.zip_with(Enum.take(row, 3), f["source_point"], &(&1 * &2))
              |> Enum.sum()
              |> Kernel.+(List.last(row))
            end)

          assert point == expected
        end
      end
    end
  end

  test "COB progress is reference-course distance, not letter count or physical height" do
    initial = W.new()
    {:ok, m} = W.rehearse(initial, 0, {:progress, 0.6})
    cob = Projection.cob(m["projection"], m["rehearsal"]["progress"])
    assert_in_delta cob["distance"], 2.7, 1.0e-9
    assert Enum.at(cob["point"], 1) == 3

    m =
      Enum.reduce([13, 18, 1, 25, 4], m, fn index, m ->
        {:ok, next} = collect(m, index)
        next
      end)

    assert Projection.cob(m["projection"], m["rehearsal"]["progress"]) == cob
    {:ok, moved} = W.rehearse(m, m["rehearsal"]["revision"], {:progress, 0.9})
    assert moved["rehearsal"]["footings"] == m["rehearsal"]["footings"]
    assert moved["rehearsal"]["collected"] == [13, 18, 1, 25, 4]
    assert Enum.at(Projection.cob(moved["projection"], 0.9)["point"], 1) == 3
  end

  test "LOCK is construction-only while rehearsal, reset archive and witness round trip retain provenance" do
    {:ok, locked} = W.operate(W.new(), 0, :lock)
    {:ok, acquired} = collect(locked, 13)
    assert acquired["lock"] == locked["lock"]
    assert acquired["witnesses"] == locked["witnesses"]

    assert {:error, :unavailable} =
             W.operate(acquired, 1, {:projection, %{Projection.defaults() | "oblique_x" => 0}})

    {:ok, reset} = W.rehearse(acquired, 1, :reset)
    assert reset["rehearsal"]["collected"] == []
    assert reset["rehearsal"]["progress"] == 0

    assert hd(reset["rehearsal"]["previous_runs"])["footings"] ==
             acquired["rehearsal"]["footings"]

    assert reset["entities"] == acquired["entities"]
    assert reset["projection"] == acquired["projection"]
    assert reset["witnesses"] == acquired["witnesses"]

    assert {:ok, ^reset, %{"bearing" => "oblique", "yaw" => 37}} =
             W.import(W.export(reset, "reciprocal", 37, "oblique"))

    assert {:error, :stale_rehearsal} = W.rehearse(reset, 1, {:collect, 18})
  end

  test "Footing acquisition references remain truthful after later source-course changes" do
    {:ok, m} = collect(W.new(), 19)
    original = hd(m["rehearsal"]["footings"])

    {:ok, changed} =
      W.operate(m, 0, {:steeling, %{m["steeling"]["parameters"] | "n_heading" => 123}})

    assert changed["rehearsal"]["footings"] == [original]
    assert original["station_point"] != Enum.at(changed["steeling"]["stations"], 18)["point"]
    assert {:ok, ^changed, _} = W.import(W.export(changed, "front"))
  end

  test "corrupt rehearsal ledgers, readiness, transforms and view mode are rejected" do
    {:ok, m} = collect(W.new(), 13)
    envelope = W.export(m, "front") |> Jason.decode!()

    for invalid <- [
          put_in(envelope, ["construction", "rehearsal", "ready"], true),
          put_in(envelope, ["construction", "rehearsal", "collected"], [18]),
          put_in(envelope, ["construction", "rehearsal", "footings"], []),
          put_in(envelope, ["construction", "projection", "vertical", "entry"], [0, 0, 0]),
          put_in(envelope, ["view", "bearing"], "fake")
        ] do
      assert {:error, :invalid_witness} = W.import(Jason.encode!(invalid))
    end
  end

  test "schema-2 witnesses retain their original LOCK and course until explicit schema-3 derivation" do
    old =
      File.read!(Path.expand("../fixtures/workshop_assignment_two.json", __DIR__))
      |> Jason.decode!()

    {:ok, old} = LegacyV2.operate(old, 0, :lock)
    json = LegacyV2.export(old, "transverse", 12)
    assert {:ok, ^old, %{"yaw" => 12}} = W.import(json)
    assert Jason.decode!(W.export(old, "transverse", 12)) == Jason.decode!(json)
    {:ok, current} = W.migrate_legacy(old, "transverse")
    assert current["schema_version"] == 3
    assert current["legacy_source"]["construction"] == old
    assert current["rehearsal"]["collected"] == []
    assert current["steeling"] == old["steeling"]
    assert {:ok, ^current, _} = W.import(W.export(current, "front"))
  end

  test "companion status is deterministic and readiness does not erase the ledger" do
    m = W.new()
    assert Rehearsal.companion(m["rehearsal"]) == "Shall we collect a letter?"

    m =
      Enum.reduce([13, 18, 1, 25, 4], m, fn index, m ->
        {:ok, next} = collect(m, index)
        next
      end)

    assert Rehearsal.companion(m["rehearsal"]) == "Five letters! Shall we see about RE-STEPPING?"
    assert length(m["rehearsal"]["footings"]) == 5
  end
end
