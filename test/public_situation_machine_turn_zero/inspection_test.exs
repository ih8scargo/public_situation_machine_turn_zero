defmodule PublicSituationMachineTurnZero.InspectionTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop, as: W
  alias W.{Inspection, Calibration}

  test "five FROM stands and temporary foci preserve original registrations, acquisition and U" do
    m =
      Enum.reduce([13, 18, 1, 25, 4], W.new(), fn i, m ->
        {:ok, m} = W.rehearse(m, m["rehearsal"]["revision"], {:collect, i})
        m
      end)

    r = Calibration.registry(Calibration.new(), m)
    source = m

    state =
      Enum.reduce(Inspection.stands(), Inspection.new(m), fn i, s ->
        {:ok, s} = Inspection.appoint(s, m, i)
        assert s["parameters"]["from"] == Inspection.station(m, i)["point"]
        original = s["parameters"]["from"]

        for target <- [
              "letter:1",
              "letter:13",
              "letter:18",
              "region:tc",
              "region:ch",
              "region:central",
              "region:lower",
              "plane:lower-surface-y-max"
            ] do
          assert {:ok, focused} = Inspection.focus(s, m, r, target)
          assert focused["parameters"]["from"] == original
          assert focused["parameters"]["stand"] == i
        end

        s
      end)

    assert m == source
    assert Inspection.valid?(state)
    assert Inspection.registered?(state, m)
    assert r["u_frame"]["origin"] == [15, 3, 0]
    assert m["rehearsal"]["ready"]
    assert m["turn"]["anchored_index"] == 0
  end

  test "physical monitor approach decreases distance; ordinary mode refuses crossing; THROUGH is explicit" do
    m = W.new()
    r = Calibration.registry(Calibration.new(), m)
    s = Inspection.new(m)
    {:ok, s} = Inspection.monitor(s, m, r)
    before = Inspection.instrument(s, m, r)
    p = Map.put(s["parameters"], "monitor_offset", 0.08)
    {:ok, close} = Inspection.change(s, s["revision"], p)
    after_pose = Inspection.instrument(close, m, r)
    assert after_pose["monitor_distance"] < before["monitor_distance"]
    assert_in_delta after_pose["monitor_distance"], 0.08, 1.0e-10

    assert {:error, :invalid} =
             Inspection.change(close, close["revision"], Map.put(p, "monitor_offset", -0.2))

    assert {:ok, through} =
             Inspection.change(
               close,
               close["revision"],
               Map.merge(p, %{"through" => true, "monitor_offset" => -0.2})
             )

    assert Inspection.instrument(through, m, r)["monitor_signed"] * before["monitor_signed"] < 0
    assert through["parameters"]["from"] == s["parameters"]["from"]

    assert Enum.find(r["items"], &(&1["id"] == "flat-monitor"))["frame"]["origin"] == [
             13.8,
             2.1,
             -2
           ]
  end

  test "surface approaches remain on appointed side, region approaches stay outside bounding sphere" do
    m = W.new()
    r = Calibration.registry(Calibration.new(), m)

    for region <- ~w(tc ch central lower), side <- ~w(x-min x-max y-min y-max z-min z-max) do
      {:ok, s} = Inspection.focus(Inspection.new(m), m, r, "plane:#{region}-surface-#{side}")
      p = Map.merge(s["parameters"], %{"distance" => 0.08, "orbit" => 170, "elevation" => 0})
      {:ok, s} = Inspection.change(s, s["revision"], p)
      f = Inspection.instrument(s, m, r)
      delta = Enum.zip_with(f["eye"], f["target"]["point"], &(&1 - &2))
      signed = Enum.zip_with(delta, f["target"]["normal"], &(&1 * &2)) |> Enum.sum()
      assert signed >= 0.079999
    end
  end

  test "schema-5 restores both extensions and rejects unsupported fields or forged FROM registrations" do
    m = W.new()
    c = Calibration.new()
    s = Inspection.new(m)

    for calibration <- [nil, c] do
      json = W.export(m, "front", 0, "both", calibration, s)
      envelope = Jason.decode!(json)
      assert envelope["schema_version"] == 5
      assert {:ok, ^m, view} = W.import(json)
      assert view["inspection_v1"] == s
      assert view["calibration_v1"] == calibration
      corrupt = put_in(envelope, ["extensions", "inspection_v1", "original_from"], [0, 0, 0])
      assert {:error, :invalid_witness} = W.import(Jason.encode!(corrupt))
    end

    assert {:error, :stale} = Inspection.change(s, 2, s["parameters"])
    assert {:error, :invalid} = Inspection.change(s, 0, Map.put(s["parameters"], "distance", 0))
    assert {:ok, ^m, _} = W.import(W.export(m, "front"))
    assert {:ok, ^m, _} = W.import(W.export(m, "front", 0, "both", c))
  end
end
