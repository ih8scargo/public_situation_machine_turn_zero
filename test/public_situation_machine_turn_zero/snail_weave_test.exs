defmodule PublicSituationMachineTurnZero.SnailWeaveTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Workshop.{SnailWeave, SnailWeaveGeometry, SnailBody}
  alias SnailWeave, as: W

  test "inbound tunnel centerline clears the walls while an off-axis course clips them" do
    for pose <- [0, 45, 90], quarter <- 0..5 do
      model = SnailWeaveGeometry.model(W.new(), pose, quarter)
      passage = model.crossing.yt_through
      probe = passage.probe

      assert [probe.far_mouth, probe.near_mouth] == model.fold[:YT_to_XT]
      assert probe.center_wall_hits == []
      assert [%{object: "tunnel-wall-" <> _} | _] = probe.control_wall_hits
      assert passage.here_receipt == :unappointed
    end
  end

  test "the default inbound course meets two displayed faces at the near mouth" do
    probe = SnailWeaveGeometry.model(W.new()).crossing.yt_through.probe
    hits = Map.new(probe.displayed_face_hits, &{&1.object, &1.parameter})

    assert_in_delta hits["pittoning-surface"], 0.8, 1.0e-8
    assert_in_delta hits["radial-interface-fold"], 0.8, 1.0e-8
  end

  defp act(s, c) do
    assert {:ok, n} = W.operate(s, s["revision"], c)
    n
  end

  defp opened, do: W.new() |> act({:pull, 0, 1}) |> act(:puff)

  defp ready,
    do:
      opened()
      |> act(:pull_brace)
      |> act({:quill, "One authored material"})
      |> act(:seat)
      |> act({:appoint, "xt"})
      |> act({:appoint, "yt"})

  defp provided(s) do
    s = act(s, :provide)
    m = List.last(s["body"]["material"])["id"]
    s |> act({:register, m}) |> act(:settle)
  end

  defp finish(s, mode, human) do
    t = List.last(s["turns"])

    s
    |> act({:take, t["id"], t["passage"], mode, human})
    |> act(:advance)
    |> act(:advance)
    |> act(:complete)
  end

  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()

  defp js_numbers(v) when is_map(v), do: Map.new(v, fn {k, x} -> {k, js_numbers(x)} end)
  defp js_numbers(v) when is_list(v), do: Enum.map(v, &js_numbers/1)
  defp js_numbers(v) when is_float(v), do: if(v == Float.floor(v), do: round(v), else: v)
  defp js_numbers(v), do: v

  test "opening uses existing labor; brace ancestry and YT depend on words, not page or geometry initialization" do
    s = W.new()
    refute s["yt"]
    assert s["opening"]["events"] == []
    assert {:error, _} = W.operate(s, 0, :pull_brace)
    assert {:error, :human_labor_required} = W.operate(s, 0, {:quill, "unearned"})
    s = opened()
    assert A.opened?(A.restore(s["opening"])) && A.puffed?(A.restore(s["opening"]))
    refute s["yt"]
    s = act(s, :pull_brace)
    assert {:error, :needle_or_labor} = W.operate(s, s["revision"], {:body, {:withdraw, 500}})
    s = act(s, {:quill, "Human words"})
    assert s["yt"]
    raw = List.last(s["body"]["material"])
    piece = raw["piece"]
    assert s["opening"]["relations"][piece]["through_by_way_of"] == "zeroeth-brace"
    assert List.last(s["tool_ancestry"])["needle_piece"] == piece
    assert s["opening"]["relations"][raw["id"]]["through_by_way_of"] == piece
    assert {:ok, ^s} = W.import(W.export(s))
  end

  test "CUBICAL precedes registration; affected emplacement folds only; raw material has one identity across all relay stages" do
    s = ready()
    material = List.last(s["body"]["material"])["id"]
    assert {:error, :cubical_first} = W.operate(s, s["revision"], {:register, material})
    s = act(s, :provide)
    t = List.last(s["turns"])
    assert t["material"] == nil
    assert s["opening"]["relations"][t["cubical"]["id"]]["arc"] == "snail-radial-arc-v1"
    s = act(s, {:register, material})
    refute W.fold_allowed?(s, 0, 45)
    assert W.fold_allowed?(s, 0, 90) && W.fold_allowed?(s, 1, 45)
    before = W.export(s)

    for view <- ~w(alongside across), pose <- [0, 45, 90] do
      g = SnailWeaveGeometry.model(s, pose, 1, 30, view, 0.8)
      assert Enum.all?(g.tags, &(&1.id == material))
      assert g.projection_relay.identity == material
      assert length(g.tags) == 7
      assert W.export(s) == before
    end

    assert length(s["body"]["material"]) == 1
    assert s["footings"] == []
    s = act(s, :settle)
    assert W.fold_allowed?(s, 0, 45)
    assert {:ok, ^s} = W.import(W.export(s))
    browser_json = W.export(s) |> Jason.decode!() |> js_numbers() |> Jason.encode!()
    assert {:ok, ^s} = W.import(browser_json)
  end

  test "two woven turns, rehearsal has no Footing, actual appointment completes once, alternate entry and scrubbing cannot acquire" do
    s = ready() |> provided()
    t = List.last(s["turns"])

    assert {:error, :unfurnished_alternate} =
             W.operate(s, s["revision"], {:take, t["id"], "other-course", "actual", "Human"})

    s = act(s, {:take, t["id"], t["passage"], "rehearsal", "Author"})
    assert SnailWeaveGeometry.model(s).crossing.second.held_UP
    assert {:error, :completion_not_scrubbing} = W.operate(s, s["revision"], :complete)
    SnailWeaveGeometry.model(s, 90, 0, 0, "across", 1.0)
    assert s["footings"] == []
    s = s |> act(:advance) |> act(:advance) |> act(:complete)
    assert s["footings"] == [] && length(s["completions"]) == 1
    s = finish(s, "actual", "Visiting Constitutioning Human")
    assert length(s["footings"]) == 1
    f = hd(s["footings"])

    assert s["opening"]["relations"][f["id"]]["relation"] ==
             "ACQUIRES OWN SCOOPING SPOONING FOOTING"

    assert {:error, :completion_not_scrubbing} = W.operate(s, s["revision"], :complete)

    assert {:error, :already_completed} =
             W.operate(
               s,
               s["revision"],
               {:take, t["id"], t["passage"], "actual", "Visiting Constitutioning Human"}
             )

    first = f
    s = s |> provided() |> finish("actual", "Visiting Constitutioning Human")
    assert length(s["turns"]) == 2 && length(s["footings"]) == 2
    assert hd(s["footings"]) == first
    assert Enum.all?(s["footings"], &(&1["human"] == "Visiting Constitutioning Human"))
    refute SnailWeaveGeometry.model(s).crossing.second.held_UP
    assert {:ok, ^s} = W.import(W.export(s))
    assert {:error, :bounded_two_turns} = W.operate(s, s["revision"], :provide)
  end

  test "analytic arc is shared, frames and addresses deterministic; six datum margins, sight and cabinet conflict are explicit" do
    s = ready()
    g = SnailWeaveGeometry.model(s)
    arc = SnailBody.reference_arc()

    for {p, i} <- Enum.with_index(arc.purchases) do
      b = SnailBody.model(s["body"], 90, i)
      assert p.point == b.fold.center
      assert_in_delta dot(p.tangent, p.radial), 0, 1.0e-10
      assert_in_delta dot(p.tangent, p.tangent), 1, 1.0e-10
      assert_in_delta dot(p.binormal, p.tangent), 0, 1.0e-10
      assert_in_delta dot(p.binormal, p.radial), 0, 1.0e-10
    end

    assert arc.length > 8
    assert Enum.sort(Enum.map(arc.samples, & &1.address)) == Enum.map(arc.samples, & &1.address)
    matrix = s["seat"]["reference_to_body"]
    mapped = Enum.map(Enum.take(matrix, 3), &dot(&1, [3, 3, 0, 1]))
    assert Enum.zip_with(mapped, s["seat"]["eye"], &abs(&1 - &2)) |> Enum.max() < 1.0e-10
    assert_in_delta g.clearances.long_run_sweep_margin, 0.29, 1.0e-10
    assert_in_delta g.clearances.long_run_cabinet_margin, 0.55, 1.0e-10
    assert g.clearances.tunnel_computer_vertical_margin > 0.03
    assert Enum.at(g.clearances.source_lead_conflict.point, 2) == 1.45

    refute Enum.any?(
             g.surfaces,
             &(&1.kind == "intermediate-shield" || &1.id == "corner-fold-plane")
           )

    assert g.clearances.sight.eye_inside_existing_wedging
    assert g.sight_tests.upward_to_ceiling == [] && g.sight_tests.toward_receiver == []
    assert SnailWeaveGeometry.ray_hits(g.surfaces, [1, -0.5, 0], [1, 0.5, 0]) != []

    for q <- 0..5, pose <- Enum.to_list(0..6) do
      body = SnailBody.model(s["body"], pose * 15, q)

      points =
        body.surfaces
        |> Enum.filter(&(&1.kind in ["wedging", "tunnel"]))
        |> Enum.flat_map(& &1.points)

      assert Enum.all?(points, fn [x, y, z] ->
               abs(x) <= g.clearances.swept_radial_bound &&
                 abs(z) <= g.clearances.swept_radial_bound &&
                 y >= -2.25 + g.clearances.tunnel_computer_vertical_margin - 1.0e-10
             end)
    end

    p = act(s, :point)
    assert p["pointing"]["pinning"] == false
    pointing = SnailWeaveGeometry.model(p)
    pole = Enum.find(pointing.lines, &(&1.id == "Fishing-Pole-Pointing-able-Thing"))
    assert pole.points == [s["seat"]["eye"], p["pointing"]["target"]]

    assert SnailWeaveGeometry.ray_hits(pointing.surfaces, hd(pole.points), List.last(pole.points)) ==
             []

    assert Enum.zip_with(p["pointing"]["target"], g.within_eye, &abs(&1 - &2)) |> Enum.max() > 0
  end

  test "Inkwell/gathering preserve word and brace ancestry; replay rejects altered Footings, raw words and stale operation" do
    s = ready() |> act({:body, {:withdraw, 1500}})
    raw = s["body"]["material"]
    s = s |> act({:body, :return}) |> act({:body, {:gather, 1500}})
    assert s["body"]["ready_for_pinning"]
    assert s["body"]["material"] == raw
    assert s["body"]["withdrawn"] == s["body"]["gathered"]
    assert {:ok, ^s} = W.import(W.export(s))
    bad = put_in(s, ["yt"], false)
    assert {:error, :invalid_witness} = W.import(W.export(bad))
    assert {:error, :stale} = W.operate(s, s["revision"] - 1, :seat)
    assert {:error, :invalid_witness} = W.import("{}")
  end
end
