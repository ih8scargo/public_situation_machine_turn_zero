defmodule PublicSituationMachineTurnZero.SemanticalCourseTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.SemanticalCourse, as: C

  test "each distinct semantic transition is held, ordered and traversable THROUGH before ALONG THROUGH" do
    m = A.rehearsal()
    course = m.standing["semantical_course"]

    assert Enum.map(course["steps"], & &1["kind"]) == [
             "from_out_of",
             "end_on",
             "up_over",
             "pivoting",
             "up_from_here",
             "through",
             "along_through",
             "toward"
           ]

    Enum.reduce(course["steps"], "fountaining-standing", fn step, prior ->
      r = m.standing["relations"][step["relation"]]
      assert r["through_by_way_of"] == prior
      assert step["through"] == prior
      assert r["provenance"] == "stand-semantic-course"
      assert m.standing["localities"][step["id"]]["relation"] == step["relation"]
      step["id"]
    end)

    ids = A.ancestry(m, "sc-toward") |> Enum.map(& &1["id"])

    for id <- [
          "sc-through",
          "sc-pivot",
          "sc-up-over",
          "fountaining-standing",
          "page-by-way-of",
          "ground-standing"
        ],
        do: assert(id in ids)
  end

  test "no preauthored geometry survives the loss of the semantic cause of a bend" do
    m = A.rehearsal()
    assert {:ok, c} = C.compile(m.standing)

    assert Enum.filter(c["segments"], & &1["bend"]) |> Enum.map(& &1["relation"]) == [
             "sc-up-over",
             "sc-pivot"
           ]

    for id <- ["sc-up-over", "sc-pivot", "sc-through"] do
      missing = Map.update!(m.standing, "relations", &Map.delete(&1, id))
      assert {:error, :unfurnished_semantical_transition} = C.compile(missing)
    end

    changed = put_in(m.standing, ["relations", "sc-pivot", "relation"], "a generic annotation")
    assert {:error, :unfurnished_semantical_transition} = C.compile(changed)
    # Latent prior point coordinates do not author this new rail.
    ignored_points =
      put_in(m.standing, ["geometry", "xt-course", "points"], [[0, 0, 0], [999, 999, 999]])

    assert C.compile(ignored_points) == C.compile(m.standing)

    reordered =
      Map.update!(m.standing, "semantical_course", fn c ->
        Map.update!(c, "steps", &Enum.reverse/1)
      end)

    assert {:error, :unfurnished_semantical_transition} = C.compile(reordered)
  end

  test "drawing purchases change depiction but never why the local bend stands" do
    m = A.rehearsal()
    {:ok, a} = C.compile(m.standing)
    {:ok, b} = C.compile(m.standing, %{over_radius: 85.0, pivot_radius: 55.0})
    assert Enum.map(a["segments"], & &1["relation"]) == Enum.map(b["segments"], & &1["relation"])
    refute a["samples"] == b["samples"]
    assert {:error, :unfurnished_semantical_transition} = C.compile(m.standing, %{over_radius: 0})

    assert m.standing["geometry"]["landinging"] ==
             PublicSituationMachineTurnZero.Architecture.Extent.geometry()["landinging"]
  end

  test "same held ordinary S resolves edge to face; no replacement glyph or completed stitch" do
    m = A.rehearsal()
    {:ok, c} = A.semantic_projection(m)
    assert hd(m.standing["rehearsal_material"])["glyph"] == "S"
    assert Enum.map(m.standing["rehearsal_material"], & &1["glyph"]) |> Enum.join() == "Stringing"

    for ch <- m.standing["rehearsal_material"] do
      assert ch["course"] == C.id()
      refute ch["stitched"]
      assert ch["stringing_available"]
    end

    assert hd(c["samples"])["face_angle"] == 88
    assert List.last(c["samples"])["face_angle"] == 0
    last = List.last(c["samples"])
    prior = Enum.at(c["samples"], -2)
    assert last["x"] > prior["x"] && last["y"] < prior["y"]
    {:ok, r} = A.operate(m, {:material, "ordinary-stringing-0"})
    {:ok, r} = A.operate(r, {:inspect, "sc-pivot"})
    assert r.standing == m.standing
    assert A.restore(r.standing).regarding.material == nil
  end

  test "compatible latent Zeroeth substrate is held, not re-furnished by the semantic course" do
    m = A.rehearsal()
    assert A.furnished?(m, "cob-standing")
    assert A.furnished?(m, "center-square-standing")
    assert A.furnished?(m, "needle-available")
    assert m.standing["spindle_extent"] == 0
    refute A.furnished?(m, "pointingable-standing")
    assert m.standing["zipperings"]["cob-course"]["event"] == nil
    assert m.standing["relations"]["cob-chain-standing"]["provenance"] == "cob-already-standing"
    assert Enum.map(m.standing["material"], & &1["glyph"]) |> Enum.join() == "JANUSITE→XT"
    assert A.next(m).action == nil
    assert List.last(m.standing["events"])["actor"] == "already-ready public construction"
    assert m.standing["from"]["basis"] == "human-standing"
  end
end
