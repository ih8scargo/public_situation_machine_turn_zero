defmodule PublicSituationMachineTurnZero.SnailFurnishingConstraintsTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    SnailWeave,
    SnailWeaveGeometry,
    SnailFurnishingConstraints
  }

  defp source do
    {:ok, s} =
      SnailWeave.import(File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json"))

    s
  end

  test "six-unit vertical relations require UN-FOLDING, not a scaled twelve-unit object" do
    s = source()
    m = SnailFurnishingConstraints.model(s, SnailWeaveGeometry.model(s))
    assert m.cubical.side_extents == 6
    refute m.cubical.visually_scaled_normal_authorized
    assert m.cubical.unfolding_transform == nil
    assert m.contraption.height_extents == 6
    assert Enum.map(m.contraption.unfolded_relations, & &1.extent) == [6, 6]
    assert Enum.map(m.contraption.unfolded_relations, & &1.direction) == ["UP OVER", "DOWN UNDER"]
    assert m.contraption.combined_object_height == nil
  end

  test "independent Ground and centered one-extent stand are constraints, not invented world coordinates" do
    s = source()
    m = SnailFurnishingConstraints.model(s, SnailWeaveGeometry.model(s))
    assert m.ground.world_plane == nil
    refute m.ground.levels_collapsed
    assert m.table.proposed_diameter_extents == 3
    assert m.table.plan_center == [0, 0]
    assert m.table.working_level == "G"
    assert m.table.world_height == nil
    refute m.table.landinging
    assert m.cob.stand_plan_center == [0, 0]
    assert m.cob.stand_height_extents == 1
    assert m.cob.local_cubical_extents == [1, 1, 1]
    assert m.cob.surrounding_cubical_extents == [6, 6, 6]
    assert m.cob.eye_registration == nil
  end

  test "axial line cannot certify a solid stand/cylinder interface or supply a bore" do
    s = source()
    m = SnailFurnishingConstraints.model(s, SnailWeaveGeometry.model(s))
    assert m.cylinder_interface.shared_central_axis
    assert m.cylinder_interface.observed_axial_reference.kind == "zero-width spindle line"
    assert m.cylinder_interface.cylinder_outer_radius == nil
    assert m.cylinder_interface.stand_solid_profile == nil
    assert m.cylinder_interface.clearance == nil
    assert Enum.any?(m.conflicts, &(&1.id == "cylinder"))
  end

  test "half-TOWARD Footings and Bug appointments do not rewrite actual acquisitions" do
    s = source()
    before = SnailWeave.export(s)
    m = SnailFurnishingConstraints.model(s, SnailWeaveGeometry.model(s))
    f = m.two_footing_room
    assert f.footing_count == 2
    assert f.each_toward_fraction == %{numerator: 1, denominator: 2}
    assert f.metric_footing_geometry == nil
    assert f.bugs_per_footing == %{default: 1, reconfigurable: [2, 3], actual_assignments: nil}
    assert f.growth_region.from == 0 and f.growth_region.to == 1
    assert f.subsequent_accretion_cap == nil
    assert Enum.map(f.source_records, & &1["id"]) == Enum.map(s["footings"], & &1["id"])
    assert SnailWeave.export(s) == before
  end
end
