defmodule PublicSituationMachineTurnZero.CalibrationTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop, as: W
  alias W.Calibration, as: C
  defp item(r, id), do: Enum.find(r["items"], &(&1["id"] == id))

  test "locked U, nested enclosure, pinned toes and Ground resolution survive all bounded axes and couplings" do
    model = W.new()
    initial = C.registry(C.new(), model)

    for axis <- ~w(x z),
        coupling <- ~w(independent counter linked),
        angle <- [0, 45, 90],
        opening <- [0, 22.5, 45] do
      p =
        Map.merge(C.defaults(), %{
          "axis" => axis,
          "coupling" => coupling,
          "quarter_turn" => angle,
          "opening" => opening
        })

      assert {:ok, state} = C.change(C.new(), 0, p, false)
      r = C.registry(state, model)
      assert r["u_frame"] == initial["u_frame"]
      assert item(r, "u-aperture")["points"] == item(initial, "u-aperture")["points"]
      assert r["toe_points"] == initial["toe_points"]
      assert Enum.take(item(r, "flat-aperture")["points"], 2) == r["toe_points"]
      assert Enum.at(r["ground_resolution"], 1) == -6
      assert Enum.at(r["quarter_endpoint"], 1) >= 0
      assert item(r, "flat-monitor")["points"] == item(initial, "flat-monitor")["points"]
      assert item(r, "HERE")["points"] != item(r, "NEXT")["points"]

      assert item(r, "bobbining-enclosure")["points"]
             |> Enum.all?(fn [x, y, z] ->
               x >= 13.8 && x <= 16.2 && y >= 1.8 && y <= 4.2 && z == 0
             end)

      assert Enum.count(r["items"], &String.starts_with?(&1["id"], "six-mark-")) == 6
    end
  end

  test "45-degree opening aims Projectioning through fixed monitor center; below-line material stays above Ground" do
    m = W.new()
    r = C.registry(C.new(), m)

    assert Enum.zip_with(
             r["projection_thing"]["monitor_hit"],
             r["projection_thing"]["center"],
             fn a, b -> abs(a - b) < 1.0e-12 end
           )
           |> Enum.all?()

    assert item(r, "monitor-prospective")["points"]
           |> Enum.all?(fn [_x, y, _z] -> y < 3 && y > -6 end)

    assert item(r, "monitor-already-standing")["material_status"] == "STANDING FOR STAGING"
    assert {:ok, s} = C.change(C.new(), 0, Map.put(C.defaults(), "opening", 0), false)
    flat = C.registry(s, m)
    assert flat["projection_thing"]["monitor_hit"] != r["projection_thing"]["monitor_hit"]
    assert item(flat, "flat-monitor")["points"] == item(r, "flat-monitor")["points"]
  end

  test "limits, stale commands and construction LOCK reject changes rather than wrapping or clamping" do
    s = C.new()

    for {key, value} <- [
          {"quarter_turn", -0.1},
          {"quarter_turn", 90.1},
          {"opening", 45.1},
          {"axis", "y"},
          {"coupling", "flip180"},
          {"radius", 2}
        ] do
      assert {:error, :invalid} = C.change(s, 0, Map.put(C.defaults(), key, value), false)
    end

    assert {:error, :stale} = C.change(s, 1, C.defaults(), false)
    assert {:error, :locked} = C.change(s, 0, C.defaults(), true)
  end

  test "ZERO is unfurnished until first acquisition, then begins at explicit bottom hypothesis toward ONE" do
    m = W.new()
    assert item(C.registry(C.new(), m), "camera-zero") == nil
    assert {:ok, m} = W.rehearse(m, 0, {:collect, 13})
    r = C.registry(C.new(), m)
    [x, y, z] = hd(m["rehearsal"]["footings"])["source_point"]
    assert hd(item(r, "camera-zero")["points"]) == [x, y - 0.1, z]
    assert List.last(item(r, "camera-zero")["points"]) == hd(item(r, "camera-one")["points"])
    assert item(r, "camera-two")["id"] != item(r, "projection-thing")["id"]
    assert r["acquisition_context"]["traversaling_acquisitions"] == []
    assert r["acquisition_context"]["furnished_by_way_of"] == nil
  end

  test "planar ledger covers existing surfaces and material, with explicit appointment classes and unchanged Footings" do
    m = W.new()
    r = C.registry(C.new(), m)

    for e <- Map.values(m["entities"]),
        surface <- e["surfaces"],
        do: assert(item(r, surface["id"]))

    for id <-
          ~w(u13-return n18-return flat-aperture flat-monitor a03-source a03-vertical-material a03-oblique-material SIX-upstage) do
      record = item(r, id)
      assert record["frame"]["origin"] == hd(record["points"])
      assert hd(record["outreadings"])["class"] == "MEASURED"
      assert List.last(record["outreadings"])["class"] in ~w(MEASURED APPOINTED PROVISIONAL)
      assert record["relations"]["FROM"]
      assert record["camera_invariants"] != []
    end

    assert List.last(item(r, "SIX-upstage")["outreadings"])["class"] == "APPOINTED"
    assert item(r, "HERE")["material_status"] == "STANDING FOR STAGING"
    assert item(r, "NEXT")["material_status"] == "STAGING FOR STANDING"
    assert r["purchase"]["completed_restep_turns"] == 0
  end

  test "optional versioned envelope round-trips calibration without rewriting schema-3 acquisitions or LOCK" do
    m =
      Enum.reduce([13, 18, 1, 25, 4], W.new(), fn i, m ->
        {:ok, next} = W.rehearse(m, m["rehearsal"]["revision"], {:collect, i})
        next
      end)

    assert {:ok, m} = W.operate(m, 0, :lock)
    assert {:ok, s} = C.change(C.new(), 0, Map.put(C.defaults(), "quarter_turn", 90), false)

    for view <- ~w(tunneling diorama reciprocal) do
      assert {:ok, ^m, spec} = W.import(W.export(m, view, 31, "both", s))
      assert spec["calibration_v1"] == s
    end

    assert {:ok, ^m, spec} = W.import(W.export(m, "front"))
    refute Map.has_key?(spec, "calibration_v1")
    envelope = W.export(m, "diorama", 0, "both", s) |> Jason.decode!()

    for invalid <- [
          nil,
          [],
          %{"calibration_v1" => %{}},
          %{"calibration_v1" => s, "unknown" => true}
        ] do
      assert {:error, :invalid_witness} =
               W.import(Jason.encode!(Map.put(envelope, "extensions", invalid)))
    end

    forged_view = put_in(envelope, ["view", "calibration_v1"], %{"invalid" => true})
    assert {:error, :invalid_witness} = W.import(Jason.encode!(forged_view))

    corrupt =
      put_in(
        envelope,
        ["extensions", "calibration_v1", "history", Access.at(0), "quarter_turn"],
        45
      )

    assert {:error, :invalid_witness} = W.import(Jason.encode!(corrupt))
  end
end
