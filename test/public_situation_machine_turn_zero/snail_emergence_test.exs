defmodule PublicSituationMachineTurnZero.SnailEmergenceTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    SnailWeave,
    SnailWeaveGeometry,
    SnailEmergence,
    SnailBody,
    WedgingGeometry
  }

  defp source do
    {:ok, s} =
      SnailWeave.import(File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json"))

    s
  end

  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()
  defp delta(a, b), do: Enum.zip_with(a, b, &(&1 - &2))

  test "revised Seat is at HERE midpoint, eye and COB share level, aperture bearing is 45 degrees, canonical source remains intact" do
    s = source()
    saved = SnailWeave.export(s)
    base = SnailWeaveGeometry.model(s)
    e = SnailEmergence.model(s, base)
    r = e.registration
    assert r.fixed_seat == [0, 0, 0]
    assert Enum.at(r.revised_eye, 1) > 0
    assert Enum.at(r[:COB_eye], 1) == Enum.at(r.revised_eye, 1)
    d = delta(r.fixed_seat, r.revised_aperture)
    assert_in_delta :math.atan2(Enum.at(d, 1), hd(d)) * 180 / :math.pi(), 45, 1.0e-10
    mapped = Enum.take(r.reference_to_here, 3) |> Enum.map(&dot(&1, [3, 3, 0, 1]))
    assert Enum.all?(mapped, &(abs(&1) < 1.0e-10))
    assert r.reference_midpoint == [3, 3]
    assert r.native_aperture_source["relation"] == "aperture-available"

    mapped_aperture =
      Enum.take(r.native_aperture_to_revised, 3) |> Enum.map(&dot(&1, [0, 0, 0, 1]))

    assert mapped_aperture == r.revised_aperture
    assert r.source_seat["id"] == s["seat"]["id"]
    refute r.seat_motion
    assert SnailWeave.export(s) == saved
  end

  test "registered emergence joins aperture, acquired HERE and unchanged helix; inherited addresses and vertices are not translated" do
    s = source()
    b = SnailWeaveGeometry.model(s)
    e = SnailEmergence.model(s, b)
    assert hd(e.binding.prefix) == e.registration.revised_aperture
    assert Enum.at(e.binding.prefix, 32) == [0.0, 0.0, 0.0]
    assert WedgingGeometry.distance(List.last(e.binding.prefix), SnailBody.arc_point(0)) < 1.0e-10
    assert hd(e.binding.prefix_addresses) < 0 && List.last(e.binding.prefix_addresses) == 0
    old = Enum.find(b.surfaces, &(&1.id == "corkscrew-ribbon-0"))
    seam = e.binding.seam

    assert Enum.all?(seam, fn p ->
             Enum.any?(Enum.take(old.points, 2), &(WedgingGeometry.distance(p, &1) < 1.0e-10))
           end)

    for old <- Enum.filter(b.surfaces, &(&1.kind == "corkscrew")) do
      assert Enum.find(e.presentation.surfaces, &(&1.id == old.id)) == old
    end

    assert e.binding.unchanged_helix == SnailBody.reference_arc()
    assert e.binding.source_footing == List.last(s["footings"])["id"]
    assert Enum.all?(e.binding.prefix, fn [_, y, _] -> y <= 1.0e-10 end)
  end

  test "fresh zero extent is independent of arbitrary later fashioning and inherited material; no unfurnished next frame is made available" do
    s = source()
    b = SnailWeaveGeometry.model(s)
    saved = SnailWeave.export(s)

    for amount <- [0.0, 1.0, 10000.0, 1.0e30] do
      e = SnailEmergence.model(s, b, amount)
      assert e.fresh.local_fashioning_extent == 0
      assert e.fresh.inspected_later_extent == amount
      assert e.fresh.accretion_limit == nil
      assert e.fresh.inherited_material_ids == Enum.map(s["body"]["material"], & &1["id"])
      assert e.fresh.inherited_footing_ids == Enum.map(s["footings"], & &1["id"])
      refute e.fresh.next_frame_available
      assert SnailWeave.export(s) == saved
    end

    {:ok, pending} =
      SnailWeave.operate(s, s["revision"], {:quill, "New raw material, not yet acquired"})

    later = SnailEmergence.model(pending, SnailWeaveGeometry.model(pending))
    assert length(later.fresh.retained_authored_material_ids) == 2
    assert length(later.fresh.inherited_material_ids) == 1
    assert pending["footings"] == s["footings"]
    empty = SnailWeave.new()
    e = SnailEmergence.model(empty, SnailWeaveGeometry.model(empty))
    assert e.fresh.acquired_source == nil
    assert e.binding.source_footing == nil
  end

  test "one material registers onto actual existing wall quads; earlier wall occlusion and prior relay findings are distinguished" do
    s = source()
    b = SnailWeaveGeometry.model(s)
    e = SnailEmergence.model(s, b)
    id = List.last(s["body"]["material"])["id"]
    assert Enum.all?(e.wall_test.marks, &(&1.material == id))
    assert e.wall_test.source_line_area == 0
    assert e.wall_test.visible_count > 0
    assert e.wall_test.early_wall_probe.obstructions != []

    for m <- e.wall_test.marks do
      assert Enum.any?(b.surfaces, &(&1.id == m.host))
      assert m.incidence >= 0 && m.incidence <= 1
      assert length(m.quad) == 4
    end

    refute Enum.any?(
             e.presentation.lines,
             &(&1.id == "bellows-UP-reading" || &1.id == "long-directed-FRONT")
           )

    assert_in_delta e.history.long_run_margin, 0.29, 1.0e-10
    assert Enum.at(e.history.cabinet_lead_conflict.point, 2) == 1.45
    refute e.wall_test.optical_motor
  end

  test "candidate origins are in the existing wedge; arrival and standing directions remain ineligible and selection is not PUFFING" do
    s = source()
    b = SnailWeaveGeometry.model(s)
    saved = SnailWeave.export(s)

    for selection <- ~w(through arrival standing) do
      e = SnailEmergence.model(s, b, 0.0, 90, selection)
      assert Enum.all?(e.opportunities, & &1.inside_actual_wedge)
      assert Enum.find(e.opportunities, &(&1.id == "through")).eligible
      refute Enum.find(e.opportunities, &(&1.id == "arrival")).eligible
      refute Enum.find(e.opportunities, &(&1.id == "standing")).eligible
      assert e.diagonals[:PITTONING] =~ "unresolved"
      assert e.diagonals.volume_return != Enum.at(e.diagonals.flat, 1).points
      assert SnailWeave.export(s) == saved
    end
  end
end
