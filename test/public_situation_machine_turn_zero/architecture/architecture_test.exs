defmodule PublicSituationMachineTurnZero.ArchitectureTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.PullWitness

  defp open(metrics \\ %{}) do
    m = A.rehearsal()
    {:ok, m} = A.operate(m, :take_purchase)
    t = m.pulling.token
    {:ok, m} = A.operate(m, {:pull, t})
    {:ok, m} = A.operate(m, {:release, t, metrics})
    m
  end

  defp feeding(m) do
    {:ok, m} = A.operate(m, :start_feed)
    t = m.feeding.token
    {:ok, m} = A.operate(m, {:feed_through, t, "regarding-square"})
    {:ok, m} = A.operate(m, {:feed_through, t, "center-square"})
    {m, t}
  end

  test "fashioned CUBICAL has real bounded extent, a center square and available toys before calibration" do
    m = A.rehearsal()
    assert A.label() == "PULL."

    assert m.standing["geometry"]["landinging"]["bottom"] <
             m.standing["geometry"]["landinging"]["top"]

    assert m.standing["geometry"]["landinging"]["bounds"]["z"] == [-4.5, 4.5]
    assert A.furnished?(m, "center-square-standing")
    assert A.furnished?(m, "cob-standing")

    for id <- ["doll", "stick", "regarding-square", "needle"],
        do: assert(A.furnished?(m, id <> "-available"))

    assert {:ok, needle} = A.operate(m, {:tool, "needle"})
    assert needle.standing == m.standing
    refute A.opened?(m)
    assert A.spindle_extent(m) == 0
    refute A.complete?(m)
  end

  test "pull resolves Regarding of exactly the same volume and square without moving FROM" do
    initial = A.rehearsal()
    m = open()
    assert A.opened?(m)
    assert m.regarding.bearing == "situated"
    assert m.standing["geometry"] == initial.standing["geometry"]
    assert m.standing["material"] == initial.standing["material"]
    assert m.standing["from"] == initial.standing["from"]

    for b <- ["end-on", "situated"] do
      {:ok, r} = A.operate(m, {:bearing, b})
      assert r.standing == m.standing

      assert A.projection(r)["objects"]["center-square"] ==
               A.projection(m)["objects"]["center-square"]
    end
  end

  test "instrumentation has a returnable relational locality and no measurement affects standing" do
    a = open(%{"dx" => 3, "dy" => 4, "duration_ms" => 1000})
    b = open(%{"dx" => 300, "dy" => 400, "duration_ms" => 1})
    assert a.standing["relations"] == b.standing["relations"]
    assert a.standing["geometry"] == b.standing["geometry"]
    locality = a.standing["localities"]["pull-instrumentation"]
    assert locality["relative_to"] == "landinging"
    assert locality["witness"]["computational_outreading"]["displacement_px"] == 5.0
    assert locality["witness"]["computational_outreading"]["mean_velocity_px_s"] == 5.0
    refute locality["witness"]["affects_standing"]
    {:ok, hidden} = A.operate(a, {:instrumentation, false})
    assert hidden.standing == a.standing
    {:ok, returned} = A.operate(hidden, {:instrumentation, true})
    assert returned.standing["localities"]["pull-instrumentation"]["id"] == locality["id"]

    assert PullWitness.build(%{"dx" => "bad", "duration_ms" => 0})["computational_outreading"][
             "mean_velocity_px_s"
           ] == nil
  end

  test "Fountainhead material and XT have actual separate infrastructural ancestry" do
    m = A.rehearsal()
    ids = A.ancestry(m, "material-standing") |> Enum.map(& &1["id"])

    for id <- [
          "xt-upon-track",
          "xt-standing",
          "xt-opening-standing",
          "crossing-standing",
          "track-standing",
          "janusite-standing",
          "fountaining-standing",
          "page-by-way-of"
        ],
        do: assert(id in ids)

    assert m.standing["geometry"]["xt-course"]["bends"] |> hd() |> Map.fetch!("relation") ==
             "xt-opening-standing"

    {:ok, r} = A.operate(m, {:material, "fountaining-character-3"})
    {:ok, r} = A.operate(r, {:bearing, "situated"})
    assert r.standing == m.standing

    assert Enum.map(A.projection(r)["material"], & &1["id"]) ==
             Enum.map(m.standing["material"], & &1["id"])
  end

  test "feed must pass both squares in order; finite growth cannot skip or exceed extent" do
    assert {:error, :unavailable} = A.operate(A.rehearsal(), :start_feed)
    m = open()
    {:ok, m} = A.operate(m, :start_feed)
    t = m.feeding.token
    assert {:error, :unavailable} = A.operate(m, {:feed_through, t, "center-square"})
    assert {:error, :unavailable} = A.operate(m, {:feed, t, 1})
    {:ok, m} = A.operate(m, {:feed_through, t, "regarding-square"})
    {:ok, m} = A.operate(m, {:feed_through, t, "center-square"})
    assert {:error, :unavailable} = A.operate(m, {:feed, t, 2})
    {:ok, one} = A.operate(m, {:feed, t, 1})
    assert {:error, :unavailable} = A.operate(one, {:feed, t, 1})
    assert one.standing["geometry"]["center-square"] == m.standing["geometry"]["center-square"]
    {:ok, stopped} = A.operate(one, {:cancel_feed, t})
    resumed = A.restore(stopped.standing)
    assert A.spindle_extent(resumed) == 1
    {resumed, t2} = feeding(resumed)

    complete =
      Enum.reduce(2..6, resumed, fn n, m ->
        {:ok, m} = A.operate(m, {:feed, t2, n})
        m
      end)

    assert A.complete?(complete)
    assert A.spindle_extent(complete) == 6
    assert {:error, :unavailable} = A.operate(complete, {:feed, t2, 7})
    assert {:error, :unavailable} = A.operate(complete, :start_feed)
    assert complete.standing["from"] == m.standing["from"]
  end

  test "same COB chain and square persist before during and after Spindle and Pointingable co-labor" do
    m = open()
    square = m.standing["geometry"]["center-square"]
    chain = m.standing["zipperings"]["cob-course"]
    cob = m.standing["relations"]["cob-standing"]
    glyphs = m.standing["material"]
    {m, t} = feeding(m)

    complete =
      Enum.reduce(1..6, m, fn n, m ->
        {:ok, next} = A.operate(m, {:feed, t, n})
        assert next.standing["geometry"]["center-square"] == square
        assert next.standing["zipperings"]["cob-course"] == chain
        assert next.standing["relations"]["cob-standing"] == cob
        assert next.standing["material"] == glyphs
        assert A.projection(next)["cob_embedding_relation"] == "cob-lift-#{n}"
        next
      end)

    ids = A.ancestry(complete, "pointingable-standing") |> Enum.map(& &1["id"])

    for id <- [
          "stick-through-spindle",
          "pointingable-co-labor",
          "spindle-6",
          "center-square-standing",
          "xt-upon-track",
          "fountaining-standing"
        ],
        do: assert(id in ids)

    assert "feed-stick-through-regarding" in ids
    assert "feed-stick-through-center" in ids
    e = List.last(complete.standing["events"])
    assert "cob-standing" in e["dependencies"]
    assert "stick-available" in e["dependencies"]
    assert e["actor"] == "human ALONGSIDE WITH COB"
    assert A.next(complete).action == nil
  end

  test "transient purchase and bad tokens cannot furnish consequence" do
    m = A.rehearsal()
    {:ok, p} = A.operate(m, :take_purchase)
    assert p.standing == m.standing
    assert {:error, :unavailable} = A.operate(p, {:release, p.pulling.token, %{}})
    assert {:error, :unavailable} = A.operate(p, {:pull, "other"})
    {:ok, c} = A.operate(p, {:cancel_pull, p.pulling.token})
    assert c.standing == m.standing
    assert A.restore(p.standing).pulling == nil
  end

  test "all courses retain held immediate predecessors and causal events, older versions remain witnesses" do
    m = open()

    for {_, course} <- m.standing["zipperings"], step <- course["steps"] do
      assert A.furnished?(m, step["through"])
      assert m.standing["relations"][step["link"]]["object"] == step["through"]
      # Typed infrastructural/co-labor branches are traversed alongside the local predecessor.
      assert Enum.any?(A.ancestry(m, step["id"]), &(&1["id"] == "ground-standing"))
    end

    for e <- m.standing["events"] do
      assert Enum.all?(e["dependencies"], &(&1 in e["inherited_before"]))
      assert Enum.all?(e["consequences"], &(&1 in e["inherited_after"]))
      assert e["from"] == e["from_after"]
    end

    for v <- ["spindle-round-one", "spindle-rail-pass", "toy-box-opening-v1"] do
      s = %{"version" => v, "relations" => %{}, "events" => []}
      witness = A.restore(s)
      assert witness.standing == s
      assert {:error, :unavailable} = A.operate(witness, :take_purchase)
    end
  end
end
