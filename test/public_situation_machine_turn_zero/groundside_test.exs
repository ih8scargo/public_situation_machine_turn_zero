defmodule PublicSituationMachineTurnZero.GroundsideTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop, as: W
  alias W.{Groundside, DrawOut, Calibration, Surfacing}
  alias PublicSituationMachineTurnZero.Architecture.ApplianceCutaway

  defp stage(text) do
    s = Surfacing.new()
    {:ok, s} = Surfacing.operate(s, 0, {:quill, text})
    {:ok, s} = Surfacing.operate(s, s["revision"], {:route, "staging"})
    s
  end

  test "only a lower-source field copy doubles; first upper NEXT experiment and all registered geometry remain available" do
    m = W.new()
    r = Calibration.registry(Calibration.new(), m)
    seat = ApplianceCutaway.model()["reserved_seat"]
    original = DrawOut.witness(m, r, "side")

    for mode <- ~w(groundside groundside-tunnel), progress <- [0, 0.5, 1] do
      {:ok, model} = W.rehearse(m, 0, {:progress, progress})
      g = Groundside.witness(model, r, mode, nil, seat)
      assert g.base == 6 and g.reach == 12
      assert g.crossing_world == m["entities"]["central"]
      assert g.crossing_world["dimensions"] == [6, 6, 6]
      assert g.source_world == m["projection"]["source"]["outline"]
      assert Enum.uniq(Enum.map(g.strip_world, &hd/1)) |> Enum.sort() == [12, 24]
      assert Enum.all?(g.strip_world, fn [_, y, z] -> y == -3 and abs(z) == 0.5 end)
      assert g.native_seat == seat
      assert g.probe_eye == [15, 3, -6]
      assert g.probe_direction == [0, 0, 1]
      assert g.tokens == []
      assert String.contains?(g.relations["seat_gap"], "NOT the Traversaling Seat")
      assert g.craft_world == W.Projection.cob(model["projection"], progress)["point"]
    end

    assert DrawOut.witness(m, r, "side") == original
    assert Enum.all?(original.prospective_world, fn [x, y, _] -> x in [18.0, 24.0] and y == 6 end)
  end

  test "candidate window is distinct from U plane and every probe-window ray passes through the actual aperture corner" do
    m = W.new()

    for width <- [1.8, 2.4, 3], height <- [1.8, 3] do
      {:ok, c} =
        Calibration.change(
          Calibration.new(),
          0,
          Map.merge(Calibration.defaults(), %{"u_width" => width, "u_height" => height}),
          false
        )

      r = Calibration.registry(c, m)
      side = Groundside.witness(m, r, "groundside")
      tunnel = Groundside.witness(m, r, "groundside-tunnel")
      assert side.strip_world == tunnel.strip_world
      assert side.window_world == tunnel.window_world

      for {a, b} <- Enum.zip(side.aperture_world, side.aperture_hits),
          {x, y} <- Enum.zip(a, b),
          do: assert_in_delta(x, y, 1.0e-12)

      assert Enum.all?(side.aperture_world, fn [_, _, z] -> z == 0 end)
      assert Enum.all?(side.window_world, fn [_, _, z] -> z == 6 end)
      assert tunnel.vanishing_point == {400, 215}
      assert side.vanishing_point == nil
    end
  end

  test "static unvanishing witness retains exact authored order and provenance, with last-in farthest and no acquisitions" do
    {:ok, m} = W.rehearse(W.new(), 0, {:collect, 13})
    r = Calibration.registry(Calibration.new(), m)
    s = stage("HEAD LAST")

    for mode <- ~w(groundside groundside-tunnel) do
      g = Groundside.witness(m, r, mode, s)
      assert Enum.map_join(g.tokens, & &1.text) == "HEAD LAST"
      assert Enum.map(g.tokens, & &1.index) == Enum.to_list(1..9)
      assert hd(g.tokens).world |> Enum.at(2) == 6
      assert List.last(g.tokens).world |> Enum.at(2) == 12

      assert Enum.all?(
               g.tokens,
               &(&1.author == "Constitutioning Human" && Enum.at(&1.world, 1) == 4)
             )

      assert hd(g.standing).id == hd(m["rehearsal"]["footings"])["id"]
      assert Enum.at(hd(g.standing).world, 1) == 3
      assert g.record == hd(s["records"])
      refute g.record["operation_performed"]
    end

    g = Groundside.witness(m, r, "groundside", stage("ABCDEFGHIJKLMNOPQRST"))
    assert Enum.map(g.tokens, & &1.index) == Enum.to_list(1..6) ++ Enum.to_list(15..20)
    assert g.token_count == 20
    assert m["rehearsal"]["collected"] == [13]
    assert m["turn"]["anchored_index"] == 0
  end
end
