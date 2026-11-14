defmodule PublicSituationMachineTurnZero.HereWedgingTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    HereWedging,
    MaterialRibbon,
    SnailBody,
    ComingAboardMachine,
    GeometryExploration
  }

  test "occupied unit wedge includes ONE without replacing SIX or source returns" do
    m = HereWedging.model()
    assert m.wedge.points == m.unit.points ++ [m.seat_point]

    assert_in_delta MaterialRibbon.distance(hd(m.unit.points), List.last(m.unit.points)),
                    1,
                    1.0e-10

    assert m.pillar == [[3, 0, -4], [3, 6, -4]]
    assert length(m.wedge.faces) == 5
    assert m.inherited_return == MaterialRibbon.return_register()
    assert m.return_trial.physical_transform == nil
    assert m.return_trial.current_return_line == :unappointed
    assert m.return_trial.occupied_wedge == nil
  end

  test "Snail registration preserves source scale and exposes height conflict" do
    m = HereWedging.model()
    assert m.snail.source_points == Enum.map(SnailBody.reference_arc().samples, & &1.point)
    assert m.snail.sixth_purchase.t == 5 / 6
    assert m.snail.sixth_purchase.source == List.last(SnailBody.reference_arc().purchases).point

    for {a, b} <- Enum.zip(m.snail.source_points, m.snail.points) do
      expected = MaterialRibbon.add(ComingAboardMachine.snail_point(a), m.snail.offset)
      assert MaterialRibbon.distance(expected, b) < 1.0e-10
    end

    refute m.snail.fits_six_height
    assert List.last(m.snail.height_range) > 6
    assert m.seam.occupied_join == nil
  end

  test "mirrored Regarding and trial selection preserve one source and acquisition" do
    s = GeometryExploration.new()
    {:ok, next} = GeometryExploration.operate(s, 0, {:wedge_side, "right"})
    {:ok, next} = GeometryExploration.operate(next, 1, {:wedge_trial, "returns"})
    assert next.index == 0 and next.from == "ZERO"
    m = HereWedging.model()

    refute HereWedging.project(m.wedge.vertices, "left") ==
             HereWedging.project(m.wedge.vertices, "right")

    assert GeometryExploration.model(next).frame == GeometryExploration.model(s).frame

    assert {:error, :stale_or_session_limit} =
             GeometryExploration.operate(next, 0, {:wedge_side, "left"})
  end
end
