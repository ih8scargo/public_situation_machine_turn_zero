defmodule PublicSituationMachineTurnZero.GeometryExplorationTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.GeometryExploration, as: G
  alias PublicSituationMachineTurnZero.Workshop.MaterialRibbon, as: M

  defp step(s, c) do
    {:ok, next} = G.operate(s, s.revision, c)
    next
  end

  test "Diagonal B furnishes the current preview-turn measure inherited FROM HERE, not vertical SIX" do
    m = G.current_turn_measure()
    assert m.status == :current_turn_line_furnished
    assert m.points == [[0, 6, 0], [6, 0, 0]]
    assert m.center == [3.0, 3.0, 0.0]
    assert m.turn_id == "current-turn-preview"
    assert m.source_reference == "diagonal-B"
    assert_in_delta m.actual_length, 6 * :math.sqrt(2), 1.0e-10
    refute m.actual_length == G.frame().measure
    assert m.inherited_from.relation == "XT TO XT FROM HERE"

    assert_in_delta M.distance(hd(m.inherited_from.points), List.last(m.inherited_from.points)),
                    1,
                    1.0e-10
  end

  test "the next extent is not automatically furnished, projected as material or acquired" do
    m = G.model(G.new()).turn_measure
    assert m.prospective_join.next_extent_status == :not_furnished
    assert m.prospective_join.material_points == []
    assert m.prospective_join.physical_join_point == nil
    refute m.prospective_join.acquired
    assert G.new().continuation_overlay? == false
  end

  test "prospective overlay preserves source, frame and current-turn measure while recording separate Regarding" do
    s = G.new() |> step(:furnish_frame) |> step(:propose_coil)
    model = G.model(s)
    next = step(s, :toggle_continuation_overlay)
    assert next.continuation_overlay?
    assert next.coils == s.coils
    assert G.model(next) == model
    assert List.last(next.events).kind == :prospective_regarding
    assert List.last(next.events).inherited_xt_to_xt == model.turn_measure.inherited_from.id
    assert List.last(next.events).current_turn == model.turn_measure.turn_id
    assert next.index == 0

    for action <- [:furnish_continuation, :acquire_continuation] do
      blocked = step(next, action)
      assert List.last(blocked.events).kind == :blocked
      assert blocked.coils == s.coils
      assert blocked.index == 0
      assert G.model(blocked).turn_measure == model.turn_measure
    end

    refute step(next, :toggle_continuation_overlay).continuation_overlay?
  end

  test "SIX, continuous pillar, ONE/THREE and minimum capacity precede particular Footings" do
    s = G.new()
    assert s.coils == []
    assert G.frame().minimum_capacity == 2
    assert G.frame().actual_footings == []
    assert G.frame().maximum == [6, 6, 6]
    assert length(G.frame_edges()) == 12
    refs = G.references()
    assert Enum.find(refs, &(&1.id == "pillar")).points == [[3, 0, -4], [3, 6, -4]]
    assert Enum.find(refs, &(&1.id == "seat")).points |> Enum.all?(&(Enum.at(&1, 1) == 1))
    assert Enum.find(refs, &(&1.id == "table")).points |> Enum.all?(&(Enum.at(&1, 1) == 3))
    next = step(s, :furnish_frame)
    assert next.frame_status == :furnished_unacquired
    assert next.coils == []
    assert G.model(next).references == refs
    assert G.frame() == G.model(next).frame
  end

  test "both diagonal offices have SIX rise/run but SIX sqrt TWO actual length" do
    for id <- ["diagonal-A", "diagonal-B"] do
      [a, b] = Enum.find(G.references(), &(&1.id == id)).points
      assert abs(hd(b) - hd(a)) == 6
      assert abs(Enum.at(b, 1) - Enum.at(a, 1)) == 6
      assert_in_delta M.distance(a, b), 6 * :math.sqrt(2), 1.0e-10
      assert Enum.zip_with(a, b, &((&1 + &2) / 2)) == [3.0, 3.0, 0.0]
    end
  end

  test "constant-radius finite coils have continuous seams, addresses and ordered underfold depth" do
    a = G.coil(1)
    b = G.coil(2)
    assert a.radius == b.radius
    assert a.entrance == b.entrance
    assert hd(a.points) == a.entrance
    assert List.last(a.points) == a.entrance
    assert b.minimum_center_height < a.minimum_center_height
    assert a.width == 0.16 and a.thickness == 0.04

    for c <- [a, b] do
      assert length(c.segments) == 32
      assert Enum.all?(c.segments, &(length(&1.faces) == 6 and length(&1.vertices) == 8))

      for [x, y] <- Enum.chunk_every(c.segments, 2, 1, :discard),
          do: assert(Enum.drop(x.vertices, 4) == Enum.take(y.vertices, 4))

      assert Enum.drop(List.last(c.segments).vertices, 4) == Enum.take(hd(c.segments).vertices, 4)
      assert Enum.map(c.sections, & &1.address) == Enum.map(0..31, &(&1 / 32))
      assert c.status == :candidate_unacquired
    end

    assert G.coil(16).minimum_center_height > 0
    # Actual finite thickness can defeat the mathematical limit; never certify packing.
    assert G.coil(16).segments |> Enum.flat_map(& &1.vertices) |> Enum.any?(&(Enum.at(&1, 1) < 0))
  end

  test "second common-aperture specimen is inspectably blocked and preserves accepted material" do
    s = G.new() |> step(:furnish_frame) |> step(:propose_coil)
    assert length(s.coils) == 1
    next = step(s, :propose_coil)
    assert next.coils == s.coils
    assert next.proposal.id == "coil-candidate-2"
    assert next.proposal.interference.material_a == "coil-candidate-1"
    assert next.proposal.interference.segment_a
    assert List.last(next.events).kind == :geometry_rejected
    assert next.index == 0
    assert next.from == "ZERO"
    assert G.model(next).acquired_localities == []
    assert Enum.any?(G.model(next).coils, &(&1.id == "coil-candidate-2"))
  end

  test "view and map changes preserve material source and framing; half only changes projection" do
    s = G.new() |> step(:furnish_frame) |> step(:propose_coil)
    world = G.model(s)

    for view <- G.views() do
      next = step(s, {:view, view}) |> step({:select, "coil-candidate-1"})
      assert next.coils == s.coils
      assert G.model(next) == world
      assert next.index == 0
    end

    refute G.project(hd(s.coils).points, "half", false) ==
             G.project(hd(s.coils).points, "half", true)

    assert {:error, :unknown_locality} =
             G.operate(s, s.revision, {:select, "invented-gallery-room"})
  end

  test "working, traversal, protected acquisition and actual ceiling arrival remain blocked" do
    s = G.new() |> step(:furnish_frame) |> step({:select, "table"})

    for command <- [:acquire_frame, :traverse, :ceiling_arrival] do
      next = step(s, command)
      assert List.last(next.events).kind == :blocked
      assert next.index == 0
      assert next.from == "ZERO"
      assert next.frame_status == :furnished_unacquired
      assert G.model(next).actual_working_cob == nil
    end

    inspected = step(s, :inspect_ceiling)
    assert inspected.ceiling.height == 6
    refute inspected.ceiling.actual_arrival
    assert inspected.index == s.index
    assert {:error, :unsupported_operation} = G.operate(s, s.revision, {:acquired, true})
    assert {:error, :stale_or_session_limit} = G.operate(s, 0, :traverse)
  end

  test "fixture presence alone cannot make buttoning ready, and full fixture cannot authorize real work" do
    s = G.new()
    lab = G.fixture_new()
    refute G.eligible?(lab)
    assert {:error, :button_not_eligible} = G.fixture(lab, :button_encounter)
    assert {:error, :fixture_prerequisite} = G.fixture(lab, :local_receipt)
    {:ok, lab} = G.fixture(lab, :encounter)
    {:ok, lab} = G.fixture(lab, :appoint_presence)
    {:ok, lab} = G.fixture(lab, :presence)
    refute G.eligible?(lab)

    full =
      Enum.reduce(
        [
          :encounter,
          :local_receipt,
          :appoint_presence,
          :presence,
          :exit,
          :restomp,
          :state_ready,
          :rezip,
          :next_furnished
        ],
        s,
        fn action, state -> step(state, {:lab, action}) end
      )

    assert G.eligible?(full.condition_lab)
    assert full.coils == []
    assert full.frame_status == :unfurnished
    assert step(full, :traverse).index == 0
    assert List.last(step(full, :traverse).events).kind == :blocked
    assert full.condition_lab.from == "ZERO"
  end

  test "new triangle metadata identifies its actual stock and invariant candidate hinge" do
    for placement <- ~w(seat crossing) do
      a = G.specimen(placement, 0)
      b = G.specimen(placement, 45)
      assert a.hinge == b.hinge
      assert a.width == 1.5
      assert a.material_id == "geometry-table:janusite-specimen"
      assert a.material_id == b.material_id
      assert_in_delta a.area, 1.125, 1.0e-10
    end
  end

  test "Y pivot proposes outward AROUND ABOUT extent without rotating HERE or inventing curvature" do
    s = G.new() |> step({:axis, "y"}) |> step({:angle, 90})
    assert s.angle == 90
    specimen = G.model(s).specimen
    assert Enum.any?(specimen.points, fn [_, _, z] -> z < 0 end)
    assert specimen.pivot_axis == "y"
    assert specimen.hinge.attached_edge == :unproved
    assert G.model(s).references == G.references()
    assert_in_delta specimen.area, 1.125, 1.0e-10
    assert s.index == 0
    assert step(s, {:axis, "x"}).angle == 0
  end

  test "under-seat occupied swing cannot cross Ground or carry an unsafe angle between pivots" do
    s = G.new() |> step({:hinge, "seat"}) |> step({:angle, 90})
    assert s.angle == 0
    assert List.last(s.events).result == :frame_vertical_boundary
    assert G.outside_vertical_frame?(G.specimen("seat", 90).vertices)
    moved = G.new() |> step({:angle, 45}) |> step({:hinge, "seat"})
    assert moved.angle == 0
    refute G.outside_vertical_frame?(G.model(moved).specimen.vertices)
    assert moved.index == 0
  end

  test "rigid swing stop blocks occupied full fold instead of changing retained angle" do
    s = G.new()
    assert M.collision?(G.specimen("crossing", 90), G.stop())
    next = step(s, {:angle, 90})
    assert next.angle == s.angle
    assert List.last(next.events).result == :swing_stop
    assert {:error, :unsupported_operation} = G.operate(s, 0, {:hinge, "free-world"})
  end
end
