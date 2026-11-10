defmodule PublicSituationMachineTurnZero.WedgingRoundTwoTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.{WedgingGeometry, WedgingRehearsal}
  alias WedgingGeometry, as: G
  alias WedgingRehearsal, as: R

  defp act(s, c) do
    assert {:ok, n} = R.operate(s, s["revision"], c)
    n
  end

  defp confirmed do
    R.new()
    |> act({:appoint, "furnishing"})
    |> act({:propose, G.pair_defaults(0), 0, "forward", "Human candidate"})
    |> act(:confirm)
  end

  defp complete(s, id, course),
    do: s |> act({:enter, id, course}) |> act({:progress, 0.25}) |> act({:progress, 1})

  test "one common spine yields congruent local elbows, distinct full 3D curvature and tangent UPON contact" do
    for layout <- ~w(same next previous) do
      p = G.pair_defaults(0, layout)
      g = G.pair(p)
      assert g["within_reserved"]
      assert g["up_over"].return == g["ordinary"].return
      assert g["up_over"].entrance == [0.0, p["radius"], 0.0]
      assert g["up_over"].length > g["ordinary"].length
      assert g["curvature_measurements"]["local_elbow_max_difference"] < 1.0e-9
      assert g["curvature_measurements"]["whole_course_max_difference"] > 0.1
      for value <- Map.values(g["contact_distance"]), do: assert(value < 1.0e-9)

      assert Enum.at(g["up_over"].centerline, 48) |> Enum.at(1) >
               Enum.at(Enum.at(g["ordinary"].centerline, 48), 1)
    end

    assert G.pair(G.pair_defaults(0, "same"))["clearance"] > 0.002
    assert G.pair(G.pair_defaults(0, "previous"))["clearance"] < 0
    assert G.pair(Map.put(G.pair_defaults(0, "previous"), "radius", 0.025))["clearance"] > 0.002
  end

  test "capsule clearance checks segment interiors; Ground and every rendered tube vertex obey the one shared room reservation" do
    assert G.segment_distance([-1, 0, 0], [1, 0, 0], [0, -1, 0], [0, 1, 0]) < 1.0e-10
    assert_in_delta G.segment_distance([-1, 0, 0], [1, 0, 0], [-1, 2, 0], [1, 2, 0]), 2, 1.0e-10
    g = G.pair(G.pair_defaults(0))

    for kind <- ~w(up_over ordinary),
        ring <- g[kind].rings,
        [_, y, _] <- ring,
        do: assert(y >= -1.0e-9 && y <= 3)

    assert G.at_distance(g["ordinary"].centerline, 0) == g["ordinary"].entrance
    point = G.at_distance(g["ordinary"].centerline, g["ordinary"].length)
    assert G.distance(point, g["ordinary"].return) < 1.0e-10
    assert G.conflict_clearance(g, g) < 0
    assert G.conflict_clearance(g, G.pair(G.pair_defaults(2))) > 0
  end

  test "appointments and confirmation are distinct; one founding PITTONING is inherited by two returns and further furnishings" do
    s = R.new()

    assert {:error, :appointment} =
             R.operate(s, 0, {:propose, G.pair_defaults(0), 0, "forward", ""})

    s = act(s, {:appoint, "furnishing"})

    assert {:error, :unavailable} =
             R.operate(s, s["revision"], {:propose, G.pair_defaults(0, "next"), 0, "mouth", ""})

    s = act(s, {:propose, G.pair_defaults(0, "previous"), 0, "forward", "Inspect collision"})
    assert {:error, :clearance} = R.operate(s, s["revision"], :confirm)
    assert s["founding"] == nil
    s = s |> act({:revise, G.pair_defaults(0), "Revised"}) |> act(:confirm)
    id = hd(s["confirmed"])["id"]
    founder = s["founding"]["id"]
    assert {:error, :appointment} = R.operate(s, s["revision"], {:enter, id, "ordinary"})
    s = act(s, {:appoint, "traversaling"})
    assert s["furnishing"]["TOWARD"] != s["traversaling"]["TOWARD"]
    s = s |> complete(id, "up_over") |> complete(id, "ordinary")
    assert length(s["footings"]) == 2
    assert hd(s["footings"])["holds_inaugural_office"]
    refute List.last(s["footings"])["holds_inaugural_office"]
    assert s["founding"]["first_footing"] == hd(s["footings"])["id"]
    s = s |> complete(id, "ordinary")
    assert length(s["footings"]) == 2

    for bay <- [2, 4, 6], reduce: s do
      current ->
        next =
          current
          |> act({:propose, G.pair_defaults(bay), div(bay, 2), "forward", "Inherited"})
          |> act(:confirm)

        assert next["founding"]["id"] == founder
        assert List.last(next["confirmed"])["inherits"] == id
        next
    end
  end

  test "candidate removal preserves founding standing, and versioned replay rejects modified records" do
    s = confirmed()
    id = hd(s["confirmed"])["id"]

    s =
      s |> act({:appoint, "traversaling"}) |> complete(id, "up_over") |> complete(id, "ordinary")

    founder = s["founding"]
    s = s |> act({:propose, G.pair_defaults(2), 1, "forward", "Held material"}) |> act(:discard)
    assert s["founding"] == founder
    assert {:ok, ^s} = R.import(R.export(s))
    bad = R.export(s) |> Jason.decode!() |> put_in(["state", "founding", "point"], [1, 0, 0])
    assert {:error, :invalid_witness} = R.import(Jason.encode!(bad))
    assert {:error, :stale} = R.operate(s, 0, :confirm)
    assert {:error, :command} = R.operate(s, s["revision"], :restep)
  end
end
