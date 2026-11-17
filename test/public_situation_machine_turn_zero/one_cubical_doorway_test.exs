defmodule PublicSituationMachineTurnZero.OneCubicalDoorwayTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    RoomFromHere,
    OneCubicalDoorway,
    RoomToyBox,
    MaterialRibbon
  }

  alias OneCubicalDoorway, as: D

  setup_all do
    m = RoomFromHere.model(RoomFromHere.new())
    {:ok, m: m, v: D.measurements(m)}
  end

  test "canonical COB and all letters have exactly one CUBICAL extent; THREE does not define Table dimensions",
       %{m: m, v: v} do
    cob = Enum.find(m.doorway.pieces, &(&1.id == "doorway:cob"))
    for {a, b} <- RoomToyBox.bounds(cob.geometry), do: assert_in_delta(b - a, 1, 1.0e-10)
    assert m.doorway.table.locality == [6, 3, -2]
    assert m.doorway.table.principal_radius == 1.5
    assert m.doorway.table.principal_thickness == 0.04
    assert Map.fetch!(m.doorway.table, :COB_appointed_surface) == [6, 3.02, -3.6]

    for {_id, bounds} <- v.unit_letter_local_bounds,
        {a, b} <- bounds,
        do: assert_in_delta(b - a, 1, 1.0e-10)

    assert "room:ribbon" in Map.fetch!(v, :candidate_A_Table_intersections)
    assert "cb:monitor" in Map.fetch!(v, :candidate_A_Door_intersections)
    assert Map.fetch!(v, :selected_COB_fixed_intersections) == []
    assert v.new_stationary_outside_ROOM == []
    face = Map.fetch!(v.intended_material_contacts, :COB_Table_support_face)
    assert abs(face.gap) < 1.0e-10 and face.contact_area == 1.0
  end

  test "exact swept unit bodies clear both passage legs and every offload leg, including previously parked letters",
       %{v: v} do
    assert Enum.all?(v.route, &(&1.intersections == []))
    for {_id, rows} <- v.offloads, do: assert(Enum.all?(rows, &(&1.intersections == [])))
    assert v.aperture_clear_section == [1.2, 1.2]
    assert v.closed_leaf_blocks_unit
    assert v.leaf_swing.envelope_intersections == []
    refute v.leaf_swing.staging_letter_interference
    assert v.acquired_delta == 0
  end

  test "distinct computers preserve axle, leverage and fixed monitor; new ports retain the cleared M course",
       %{m: m, v: v} do
    refute v.paired_computers.pretend_axle_interference
    refute v.paired_computers.pretend_leverage_interference
    assert v.paired_computers.real_fixed_intersections == []
    assert_in_delta v.paired_computers.axle_side_clearance, 0.04, 1.0e-10
    assert Enum.all?(v.old_ribbon_new_ports, fn {_, collision} -> not collision end)
    assert v.old_ribbon_new_stationary_intersections == []

    for key <- [
          :R_carrier_to_head,
          :head_to_wall,
          :COB_to_brace,
          :brace_to_U,
          :rim_link_to_Table,
          :link_to_body_bearing
        ],
        do: assert(Map.fetch!(v.intended_material_contacts, key))

    for id <- ~w(doorway:inner-u doorway:outer-u) do
      p = Enum.find(m.pieces, &(&1.id == id))
      path = p.source_geometry.source_course
      assert Enum.all?(path, &(length(&1) == 3))
      assert Enum.at(hd(path), 1) == 3.02 and Enum.at(List.last(path), 1) == 3.02
      assert Enum.at(hd(path), 0) != Enum.at(List.last(path), 0)
    end

    newwall = Enum.find(m.pieces, &(&1.id == "doorway:r-wall"))
    assert Enum.at(RoomToyBox.bounds(newwall.geometry), 1) == [0, 6]

    assert Enum.find(m.pieces, &(&1.id == "room:body-bearing")).source_geometry ==
             Enum.find(RoomToyBox.model(RoomToyBox.new()).pieces, &(&1.id == "room:body-bearing")).source_geometry
  end

  test "one letter at a time requires trace, selection, placement, opening, passage and explicit Needle appointment",
       %{m: m} do
    final =
      Enum.reduce(D.letters(), D.new(), fn expected, s ->
        assert Enum.at(D.letters(), s.index) == expected
        assert {:error, :letter_predecessor_required} = D.change(s, :place)
        {:ok, a} = D.change(s, :trace)
        {:ok, b} = D.change(a, :select)
        {:ok, c} = D.change(b, :place)
        assert {:error, :letter_predecessor_required} = D.change(c, {:progress, 1.0})
        {:ok, d} = D.change(c, :open)
        {:ok, e} = D.change(d, {:progress, 0.5})
        assert {:error, :passage_progress_cannot_reverse} = D.change(e, {:progress, 0.25})
        {:ok, f} = D.change(e, {:progress, 1.0})
        assert {:error, :letter_predecessor_required} = D.change(f, :trace)
        {:ok, g} = D.change(f, :needle)
        {:ok, h} = D.change(g, {:progress, 1.0})
        h
      end)

    assert final.completed == D.letters() and final.index == 4
    assert {:error, :letters_complete} = D.change(final, :trace)
    assert Map.fetch!(m.doorway.protected, :RE_STEP) == :not_performed
    s = RoomFromHere.new()
    {:ok, a} = RoomFromHere.change(s, 0, {:pivot, "table"})

    assert {:error, :neutral_pivots_required_for_passage} =
             RoomFromHere.change(a, a.revision, {:doorway, :trace})

    assert {:error, :stale} = RoomFromHere.change(a, 0, {:doorway, :trace})
    d = Enum.find(m.pieces, &(&1.id == "doorway:transverse-u")).evidence
    assert_in_delta MaterialRibbon.dot(d.direction, d.course), :math.sqrt(0.5), 1.0e-10
  end
end
