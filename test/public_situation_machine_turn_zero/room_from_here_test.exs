defmodule PublicSituationMachineTurnZero.RoomFromHereTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    RoomFromHere,
    RoomToyBox,
    CoBuildingGeometry,
    MaterialRibbon,
    TupleExcursionInheritance
  }

  alias RoomFromHere, as: R
  alias MaterialRibbon, as: M

  setup_all do
    s = R.new()
    {:ok, s: s, m: R.model(s)}
  end

  test "eight sectors partition the inherited circle without changing radius, ROOM or source material",
       %{s: s, m: m} do
    old = RoomToyBox.model(s)

    for p <- old.pieces do
      q = Enum.find(m.pieces, &(&1.id == p.id))
      assert q.source_identity == p.source_identity
      assert q.source_geometry == p.source_geometry
      assert q.content_hash == p.content_hash
    end

    assert length(m.sectors) == 8
    original = Enum.find(old.pieces, &(&1.id == "cb:standing-circle")).lines |> hd()

    reconstructed =
      Enum.flat_map(Enum.with_index(m.sectors), fn {sector, i} ->
        if i == 0, do: hd(sector.lines), else: tl(hd(sector.lines))
      end)

    assert reconstructed == original ++ [hd(original)] or reconstructed == original
    assert Enum.all?(m.sectors, &(&1.evidence.radius == 1.5))
    assert m.frame == old.frame

    assert Enum.map(m.registration, & &1.point) == [
             [3, 0, -2],
             [3, 1, -3],
             [3, 1.63, -3],
             [6, 3, -2]
           ]

    assert m.material_assessment.table_to_body_bearing_distance > 0
    assert length(TupleExcursionInheritance.model(m).entries) == 5
  end

  test "every internal finite seam has both actual adjoining cap faces, opposite normals and course-relative views",
       %{m: m} do
    for i <- 1..m.seams do
      seam = R.seam(m.ribbon, i)
      a = seam.arriving.cell.faces |> Enum.at(1)
      b = seam.departing.cell.faces |> hd()
      assert MapSet.new(a) == MapSet.new(seam.arriving.face)
      assert MapSet.new(b) == MapSet.new(seam.departing.face)
      assert M.dot(seam.arriving.normal, seam.departing.normal) < -0.999999
      assert seam.arriving.section == [0.12, 0.02]
      assert seam.continuity.max_gap == 0
      refute seam.acquired
      assert M.dot(M.unit(M.sub(seam.fore.target, seam.fore.eye)), seam.tangent) > 0.999999
      assert M.dot(M.unit(M.sub(seam.aft.target, seam.aft.eye)), seam.tangent) < -0.999999
    end
  end

  test "only one source pivot may turn and source transforms are physically signed", %{s: s, m: m} do
    assert {:error, :select_permitted_pivot} = R.change(s, 0, {:turn, 5})
    {:ok, a} = R.change(s, 0, {:pivot, "seat"})

    assert {:error, :lock_active_pivot_before_switching} =
             R.change(a, a.revision, {:pivot, "table"})

    {:ok, b} = R.change(a, a.revision, {:turn, 30})
    assert b.seat_angle == 30 and b.table_angle == 0
    moved = R.model(b)

    for id <- ~w(cb:table cb:square-axle cb:monitor) do
      assert Enum.find(m.pieces, &(&1.id == id)).geometry ==
               Enum.find(moved.pieces, &(&1.id == id)).geometry
    end

    before = Enum.find(m.pieces, &(&1.id == "cb:seat-back"))
    after_pose = Enum.find(moved.pieces, &(&1.id == "cb:seat-back"))
    refute before.geometry == after_pose.geometry
    assert before.source_geometry == after_pose.source_geometry
    assert moved.source_digest == m.source_digest
    assert M.distance(R.rotate_y([1, 0, 0], [0, 0, 0], 90), [0, 0, -1]) < 1.0e-9
    {:ok, c} = R.change(b, b.revision, {:pivot, "locked"})
    {:ok, d} = R.change(c, c.revision, {:pivot, "table"})
    {:ok, e} = R.change(d, d.revision, :steer)
    assert e.table_angle == 5 and e.seat_angle == 30
    cam0 = R.camera(s, m)
    cam1 = R.camera(b, moved)
    refute cam0.eye == cam1.eye
    assert moved.acquisition.index_delta == 0
  end

  test "view changes preserve seam, scale, material pose and inherited source identity", %{
    s: s,
    m: m
  } do
    flat = %{s | opening: 1.0, view: "flat", door: 90.0}
    fm = R.model(flat)
    fcamera = R.camera(flat, fm)
    assert fcamera.forward == [0.0, 0.0, 1.0]
    r = Enum.find(fm.pieces, &(&1.id == "room:R"))
    xs = Enum.map(r.geometry.vertices, fn point -> R.project(point, fcamera) |> hd() end)
    assert Enum.max(xs) - Enum.min(xs) < 1.0
    {:ok, a} = R.change(s, 0, {:seam, 42})
    {:ok, b} = R.change(a, a.revision, {:view, "fore"})
    {:ok, c} = R.change(b, b.revision, {:view, "aft"})
    assert c.seam == 42
    bm = R.model(b)
    cm = R.model(c)
    assert bm.source_digest == cm.source_digest
    assert Enum.map(bm.pieces, & &1.geometry) == Enum.map(cm.pieces, & &1.geometry)
    fb = R.camera(b, bm)
    fc = R.camera(c, cm)
    assert M.dot(fb.forward, fc.forward) < -0.99999
    {:ok, d} = R.change(c, c.revision, {:select, "room:R"})
    {:ok, e} = R.change(d, d.revision, {:close, 1.0})
    em = R.model(e)
    assert em.source_digest == m.source_digest

    assert Enum.find(em.pieces, &(&1.id == "room:R")).geometry ==
             Enum.find(m.pieces, &(&1.id == "room:R")).geometry

    assert R.camera(e, em).perspective
    {:ok, returned} = R.change(e, e.revision, :return)
    assert returned.close == 0 and returned.seam == 42
  end

  test "physical directional witnesses distinguish viewpoint and source rotation", %{m: m} do
    [yt, xt] = m.gear_observations

    assert yt.source_degrees == 5 and yt.observer_angle_degrees > 0 and
             yt.appearance == :counterclockwise

    assert xt.source_degrees == -5 and xt.observer_angle_degrees < 0 and
             xt.appearance == :clockwise

    for w <- [yt, xt] do
      assert M.dot(M.cross(w.right, w.up), M.unit(M.sub(w.eye, w.target))) > 0.99999
      assert w.status == :candidate_direction_witness_not_gear_or_traction_proof
    end
  end

  test "selection requires explicit appointment and never supplies missing purchases or Footings",
       %{s: s, m: m} do
    assert {:error, :select_source_material_first} = R.change(s, 0, :appoint_stage)
    {:ok, a} = R.change(s, 0, {:selection, "O1"})
    {:ok, b} = R.change(a, a.revision, :appoint_stage)
    assert b.appointment.source == "O1" and b.appointment.attached == false
    assert {:error, :stale} = R.change(b, 0, :appoint_stage)
    assert {:error, :constitutional_means_not_furnished} = R.change(b, b.revision, :re_step)
    assert m.staircase.acquired_turns == 0 and m.staircase.footing_count == 0

    assert Enum.at(hd(m.staircase.references).origin, 1) <
             Enum.at(List.last(m.staircase.references).origin, 1)

    assert hd(m.staircase.references).source_parameter == 1
    assert List.last(m.staircase.references).source_parameter == 0

    for r <- m.staircase.references do
      assert_in_delta M.distance(hd(r.xt_to_xt), List.last(r.xt_to_xt)), 1, 1.0e-10
      assert r.offset_in_local_frame == [0, 0, 1]
      refute r.acquired
    end

    for w <- m.staircase.wedges do
      assert w.geometry.vertices != []

      [a, b] =
        w.source_endpoints
        |> Enum.map(fn id -> Enum.find(m.staircase.references, &(&1.id == id)).origin end)

      assert_in_delta M.distance(a, w.chord_midpoint), M.distance(b, w.chord_midpoint), 1.0e-10
    end

    assert Enum.all?(m.material_assessment.ports, &(&1.intersected_cells != []))
    assert Enum.all?(m.clearance, fn {_, collision} -> collision == false end)
    # Finite-source measurements cannot certify a new mechanical purchase.
    assert m.material_assessment.centre_purchase.status == :centre_purchase_unproved
    assert CoBuildingGeometry.centroid(m.selected_seam.arriving.face) == m.selected_seam.point
  end
end
