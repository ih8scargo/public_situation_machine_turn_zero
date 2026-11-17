defmodule PublicSituationMachineTurnZero.ThreeFourStudyTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.{ThreeFourStudy, CoBuilding, MaterialRibbon}
  alias ThreeFourStudy, as: S
  alias CoBuilding, as: C
  alias MaterialRibbon, as: M

  test "offset references retain arc provenance and independently measured encounter order" do
    study = S.model(0, false, false, 0)
    [ceiling, tunnel] = study.references

    assert study.offset.vector == [2.5999999999999996, 1, 0] or
             M.distance(study.offset.vector, [2.6, 1, 0]) < 1.0e-9

    assert_in_delta S.parameter(ceiling.point), 90, 1.0e-9
    assert_in_delta S.parameter(tunnel.point), 270, 1.0e-9
    assert study.offset.parameter_separation_degrees == 180

    for {cursor, reached} <- [
          {0, []},
          {89, []},
          {90, ["prospective-ceiling"]},
          {180, ["prospective-ceiling"]},
          {269, ["prospective-ceiling"]},
          {270, ["prospective-ceiling", "current-tunnel"]},
          {360, ["prospective-ceiling", "current-tunnel"]}
        ] do
      s = S.model(0, false, false, cursor)
      assert Enum.filter(s.circuit.events, & &1.reached) |> Enum.map(& &1.reference) == reached

      assert Enum.all?(
               s.circuit.events,
               &(&1.reference_gap > 0 and not &1.actual_cob_traversaling)
             )

      assert s.circuit.acquired_turns == 0
    end
  end

  test "material refashioning retains endpoints and protected previous source geometry" do
    base = C.model(C.new())
    protected = ~w(cb:zero cb:seat cb:wedge-A cb:wedge-B cb:standing-material cb:next-fold)

    # The stable aperture is identified by its source listing rather than an assumed generic cylinder ID.
    protected = Enum.filter(base.parts, &(&1.id in protected or &1.group == "aperture"))

    for bend <- [0.0, 0.5, 1.0] do
      state = %{C.new() | interpolation: bend}
      model = C.model(state)
      for p <- protected, do: assert(C.selected(model, p.id).source_geometry == p.source_geometry)
      assert model.three_four.working_band_y == [3, 4]
      assert Enum.all?(model.three_four.points, fn [_, y, _] -> y >= 3 and y <= 4 end)
      assert model.interpolation_clearance.aperture_interference == false
      assert model.interpolation_clearance.previous_wedge_interference == false
      assert model.interpolation_clearance.inherited_material_interference == false
      assert model.acquisition == base.acquisition
    end

    a = S.model(0, false, false, 0)
    b = S.model(1, false, false, 0)
    assert a.material != b.material
    assert hd(a.points) == hd(b.points) and List.last(a.points) == List.last(b.points)
    refute b.physical_join
  end

  test "conditional proposal and Projectioning do not change material or grant passage" do
    a = C.model(C.new())
    b = C.model(%{C.new() | passage_appointment?: true, interpolation_projection?: true})

    assert C.selected(a, "cb:interpolation").geometry ==
             C.selected(b, "cb:interpolation").geometry

    assert C.source_digest(a) == C.source_digest(b)

    assert C.selected(b, "cb:interpolation").display_geometry !=
             C.selected(b, "cb:interpolation").geometry

    assert b.three_four.appointment.status == :proposed
    refute b.three_four.appointment.accepted
    refute b.three_four.appointment.lawful_passage
    assert b.acquisition == a.acquisition
    assert b.three_four.actual_next_footing == nil
  end

  test "revision guard and unsupported operations preserve isolated experiment boundary" do
    s = C.new()
    assert {:ok, n} = C.change(s, 0, {:interpolation, 0.5})
    assert {:error, :stale} = C.change(n, 0, :passage_appointment)
    assert {:error, _} = C.change(n, n.revision, {:interpolation, 1.1})

    for op <- [:acquire_next, :re_step, :accept_passage, :fulfill_condition] do
      assert {:error, _} = C.change(n, n.revision, op)
    end

    assert Enum.all?(n.trace, &(&1.acquired_delta == 0))
  end
end
