defmodule PublicSituationMachineTurnZero.SurfacingTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop, as: W
  alias W.{Surfacing, Calibration, Inspection}

  defp step(s, c) do
    {:ok, n} = Surfacing.operate(s, s["revision"], c)
    n
  end

  test "HERE, offices and BY-WAY-OF are appointed without invented coordinates" do
    r = Surfacing.registrations()
    assert r["consoling"]["FROM_WITHIN"] == r["surfacing"]["id"]
    assert r["consoling"]["FROM_OUT_OF"] == r["here"]["id"]
    assert r["inquiry_route"]["BY_WAY_OF"] == r["by_way_of"]["id"]
    assert r["surfacing"]["placement"]["coordinates"] == nil
    assert r["consoling"]["placement"]["coordinates"] == nil
    assert r["consoling"]["office"] != r["surfacing"]["office"]
  end

  test "authored revision and distinct routes retain immutable provenance without performing operations" do
    s = Surfacing.new() |> step({:quill, "First marking\nUPON?"}) |> step({:route, "staging"})
    [first] = s["records"]

    s =
      s
      |> step({:revise, first["id"]})
      |> step({:quill, "Revised inquiry <b>literal</b>"})
      |> step({:route, "inquiry"})

    assert hd(s["records"]) == first
    [_, second] = s["records"]
    assert second["supersedes"] == first["id"]
    assert first["route"] == "staging"
    assert second["route"] == "inquiry"
    assert second["destination"]["BY_WAY_OF"] == Surfacing.registrations()["by_way_of"]["id"]

    for r <- s["records"] do
      assert r["author"] == "Constitutioning Human"
      assert r["HERE_provenance"] == "THIS HERE APPROACHING LANDINGING"
      refute r["operation_performed"]
      assert r["material_status"] == "STAGING FOR STANDING"
      refute Map.has_key?(r, "answer")
    end

    assert Surfacing.valid?(s)
    assert {:error, :stale} = Surfacing.operate(s, 0, {:quill, "lost"})

    assert {:error, :invalid} =
             Surfacing.operate(s, s["revision"], {:quill, String.duplicate("é", 6001)})

    refute Surfacing.valid?(Map.put(s, "revision", s["revision"] * 1.0))
    fresh = Surfacing.new()
    assert {:error, :empty} = Surfacing.operate(fresh, 0, {:route, "inquiry"})
  end

  test "schema-6 replay preserves construction, all optional extensions and LOCK; corrupt witnesses reject" do
    m = W.new()
    {:ok, m} = W.rehearse(m, 0, {:collect, 13})
    {:ok, m} = W.operate(m, 0, :lock)
    s = Surfacing.new() |> step({:quill, "Where does this stand?"}) |> step({:route, "inquiry"})

    for c <- [nil, Calibration.new()], i <- [nil, Inspection.new(m)] do
      json = W.export(m, "front", 0, "both", c, i, s)
      assert {:ok, ^m, view} = W.import(json)
      assert view["surfacing_v1"] == s
      assert view["calibration_v1"] == c
      assert view["inspection_v1"] == i
      envelope = Jason.decode!(json)
      assert envelope["schema_version"] == 6

      bad =
        put_in(envelope, ["extensions", "surfacing_v1", "records", Access.at(0), "author"], "COB")

      assert {:error, :invalid_witness} = W.import(Jason.encode!(bad))
    end

    refute Surfacing.valid?(put_in(s, ["events", Access.at(0), "text"], "rewritten"))
    assert {:ok, ^m, _} = W.import(W.export(m, "front"))

    assert {:ok, ^m, _} =
             W.import(W.export(m, "front", 0, "both", Calibration.new(), Inspection.new(m)))
  end
end
