defmodule PublicSituationMachineTurnZero.SnailGalleryRegistrationTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    SnailWeave,
    SnailWeaveGeometry,
    SnailEmergence,
    SnailNearMonitor,
    SnailGalleryRegistration,
    WedgingGeometry
  }

  defp source do
    {:ok, s} =
      SnailWeave.import(File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json"))

    s
  end

  defp geometry(s) do
    b = SnailWeaveGeometry.model(s)
    g = Map.put(b, :emergence, SnailEmergence.model(s, b))
    Map.put(g, :near_monitor, SnailNearMonitor.model(s, g))
  end

  defp boundary, do: Enum.map(WedgingGeometry.outline(), fn {x, z} -> [x, 0, z] end)

  test "measures actual nonregular Gallery, existing HERE and round annulus without adopting a volume" do
    s = source()
    g = geometry(s)
    m = SnailGalleryRegistration.model(s, g)
    assert m.observed.gallery.boundary == boundary()

    study =
      WedgingGeometry.room(%{
        "confirmed" => [],
        "proposal" => nil,
        "active" => nil,
        "founding" => nil
      })

    assert study.here == m.observed.here.points
    [sx, _, sz] = hd(study.landinging)
    assert_in_delta :math.sqrt(sx * sx + sz * sz), m.observed.standing.radius, 1.0e-10
    assert_in_delta Enum.at(m.observed.gallery.side_lengths, 0), 2, 1.0e-10
    assert_in_delta Enum.at(m.observed.gallery.side_lengths, 1), :math.sqrt(2), 1.0e-10
    refute m.observed.gallery.regular
    assert m.observed.here.reference_extent == [6, 6, 6]
    assert_in_delta m.provisional.scale * 6, 1.4, 1.0e-10
    assert m.provisional.normal_scale_in_existing_planar_matrix == 1
    assert m.observed.here.points == g.fixed.here
    assert_in_delta m.observed.table.radius, 1.4, 1.0e-10
    assert_in_delta m.observed.table.inner_radius, 0.24, 1.0e-10
    refute m.computed.unscaled_six_in_gallery_units.admissible
    assert_in_delta m.computed.selected.boundary_margin, 1.131370849898476, 1.0e-10
  end

  test "orbit and local spin are independent, with explicit comparison coupling and unchanged Rooming direction" do
    s = source()
    g = geometry(s)
    saved = SnailWeave.export(s)
    params = %{"radius" => "1", "orbit" => "90", "spin" => "15", "coupling" => "independent"}
    a = SnailGalleryRegistration.model(s, g, params)
    b = SnailGalleryRegistration.model(s, g, %{params | "coupling" => "co"})
    c = SnailGalleryRegistration.model(s, g, %{params | "coupling" => "counter"})
    assert_in_delta hd(a.provisional.ghost.center), 0, 1.0e-10
    assert_in_delta Enum.at(a.provisional.ghost.center, 2), 1, 1.0e-10
    assert a.provisional.ghost.world_yaw == 15
    assert b.provisional.ghost.world_yaw == 105
    assert c.provisional.ghost.world_yaw == -75
    assert a.computed.approach.from == [0, 0, 0]
    assert a.computed.approach.toward == g.landinging_registration.next.center
    assert a.observed.standing.id != a.observed.here.id
    assert SnailWeave.export(s) == saved
  end

  test "static fits at both endpoints do not establish a collision-free middle course" do
    c = SnailGalleryRegistration.course(boundary(), 1.2, 0.7, 0, "independent")
    assert hd(c.samples).margin > 0
    assert List.last(c.samples).margin > 0
    assert Enum.at(c.samples, 45).margin < 0
    refute c.continuous_boundary_certified
    assert c.continuous_physical_clearance == nil
    refute c.traversaling_authorized
    safe = SnailGalleryRegistration.course(boundary(), 0.6, 0.7, 0, "co")
    assert safe.continuous_boundary_certified
    # Independent intermediate samples test the conservative whole-interval bound.
    for i <- 0..180 do
      phi = i / 2
      a = phi * :math.pi() / 180

      fit =
        SnailGalleryRegistration.static_fit(
          boundary(),
          [0.6 * :math.cos(a), 0, 0.6 * :math.sin(a)],
          0.7,
          phi
        )

      assert fit.boundary_margin >= safe.continuous_boundary_lower_bound
    end
  end

  test "triangle versus volume detects a crossing even with every triangle vertex outside the box" do
    crossing = %{id: "crossing", points: [[-2, 0.7, -2], [2, 0.7, -2], [0, 0.7, 2]]}
    above = %{id: "above", points: [[-2, 2, -2], [2, 2, -2], [0, 2, 2]]}
    assert SnailGalleryRegistration.wall_contacts([crossing], [0, 0, 0], 0.7, 0) == ["crossing"]
    assert SnailGalleryRegistration.wall_contacts([above], [0, 0, 0], 0.7, 0) == []

    assert_in_delta SnailGalleryRegistration.wall_distance_lower_bound(
                      [above],
                      [0, 0, 0],
                      0.7,
                      0
                    ),
                    0.6,
                    1.0e-10
  end

  test "Table work preview uses an actual annular face and retains source material and acquired placement" do
    s = source()
    saved = SnailWeave.export(s)
    m = SnailGalleryRegistration.model(s, geometry(s))
    w = m.provisional.material_work
    assert w.material["id"] == hd(s["body"]["material"])["id"]
    assert length(w.source_footings) == 2
    assert Enum.any?(m.observed.table.mesh, &(&1.id == w.proposed_host))
    [x, y, z] = w.proposed_destination
    assert y == -0.1
    assert :math.sqrt(x * x + z * z) > m.observed.table.inner_radius
    assert :math.sqrt(x * x + z * z) < m.observed.table.radius
    assert length(m.computed.inherited_nav_intervals) == 2
    assert SnailWeave.export(s) == saved
  end

  test "same walls and successive points underlie both projections; reach is not bounded to HERE" do
    s = source()
    g = geometry(s)
    m = SnailGalleryRegistration.model(s, g)
    assert m.provisional.craft.normal == [0, 1, 0]
    assert m.provisional.craft.physical_envelope == nil
    assert m.provisional.craft.toward_axle_bearing == nil
    assert m.provisional.cob.eye_delta_y == 0
    assert_in_delta m.provisional.cob.angle_from_current_human_regard, 90, 1.0e-10
    assert m.provisional.cob.reach_limit == nil

    assert Enum.any?(
             m.computed.cob_targets,
             &(&1.outside_here_footprint and &1.required_distance > 1.4)
           )

    assert length(m.computed.curvature.observations) == 25
    assert m.computed.curvature.analytic_curvature > 0

    expected =
      Enum.filter(
        g.emergence.presentation.surfaces,
        &(&1.kind in ~w(corkscrew janusite-wall wedging tunnel pittoning))
      )
      |> Enum.map(& &1.id)

    assert Enum.map(m.observed.walls, & &1.id) == expected
    assert m.computed.wall_test == g.emergence.wall_test
  end

  test "invalid inspection controls are rejected and initial witness invents no material" do
    assert {:error, _} =
             SnailGalleryRegistration.parse(%{
               "radius" => "NaN",
               "orbit" => "0",
               "spin" => "0",
               "coupling" => "independent"
             })

    assert {:error, _} =
             SnailGalleryRegistration.parse(%{
               "radius" => "4",
               "orbit" => "0",
               "spin" => "0",
               "coupling" => "co"
             })

    assert {:ok, _} = SnailGalleryRegistration.parse(SnailGalleryRegistration.defaults())
    s = SnailWeave.new()
    m = SnailGalleryRegistration.model(s, geometry(s))
    assert m.provisional.material_work.material == nil
    assert m.computed.inherited_nav_intervals == []
  end

  test "three-extent proposed Table preserves six-unit HERE and does not appoint height, thickness or pathway" do
    s = source()
    g = geometry(s)
    before = SnailWeave.export(s)
    m = SnailGalleryRegistration.model(s, g)
    t = m.provisional.table
    assert t.nominal_diameter_extents == 3
    assert m.observed.here.reference_extent == [6, 6, 6]
    assert_in_delta 2 * t.comparison_radius, 0.7, 1.0e-10
    assert_in_delta t.centered_side_inset_extents, 1.5, 1.0e-10
    assert_in_delta t.ghost_rim_containment_margin, 0.35, 1.0e-10
    assert_in_delta t.gallery_plan_margin, 1.65, 1.0e-10
    assert t.height == nil and t.thickness == nil and t.inner_profile == nil
    assert t.volumetric_reach == nil and t.physical_fit == nil
    refute t.inset_is_pathway
    assert m.provisional.material_work.proposed_three_extent_table_destination == nil
    assert_in_delta m.observed.table.radius, 1.4, 1.0e-10
    assert SnailWeave.export(s) == before
  end

  test "proposed rim is tested through compound motion and reach remains horizontal only" do
    s = source()
    g = geometry(s)
    p = Map.merge(SnailGalleryRegistration.defaults(), %{"radius" => "1", "coupling" => "co"})
    m = SnailGalleryRegistration.model(s, g, p)
    assert_in_delta m.provisional.table.ghost_rim_containment_margin, -0.65, 1.0e-10

    for c <- m.computed.courses do
      assert_in_delta c.proposed_table_minimum_rim_containment_margin, -0.65, 1.0e-10
      assert c.proposed_table_height == nil
      assert c.proposed_table_physical_clearance == nil
      refute c.traversaling_authorized
    end

    assert_in_delta m.provisional.table.cob_nearest_plan_rim_distance, 0.15, 1.0e-10
    assert_in_delta m.provisional.table.cob_farthest_plan_rim_distance, 0.55, 1.0e-10
    assert m.provisional.table.seat_point_inside_outer_envelope
    assert m.provisional.table.cob_base_inside_outer_envelope
  end
end
