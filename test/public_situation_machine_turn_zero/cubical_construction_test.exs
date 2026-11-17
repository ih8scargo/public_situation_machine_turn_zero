defmodule PublicSituationMachineTurnZero.CubicalConstructionTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    CubicalConstruction,
    GeometryExploration,
    HereWedging,
    JanusiteInheritance,
    MaterialRibbon
  }

  alias CubicalConstruction, as: C

  test "whole frame keeps source SIX and fixed endpoint across every Regarding" do
    m = C.model()
    assert m.frame == GeometryExploration.frame()
    assert length(m.vertices) == 8
    assert length(m.edges) == 12
    assert m.fixed_endpoint == [6, 6, 0]

    for facet <- ~w(flat tunneling reciprocal return) do
      assert {:ok, s} = C.change(C.new(), 0, {:facet, facet})
      assert C.project(m.vertices, s) != ""
      assert C.model() == m
    end

    assert C.inscription(m, "stage-door").points == [[0, 0, 0]]
    assert C.inscription(m, "face-near").vertex_ids != C.inscription(m, "face-far").vertex_ids
  end

  test "UP approach and first bisection are distinct from transverse A" do
    m = C.model()
    assert m.halfway == [3.0, 3.0, 0.0]
    assert C.inscription(m, "ground-approach").points == [[3, 0, 0], m.halfway]
    assert C.inscription(m, "ground-approach").bearing == [0.0, 3.0, 0.0]
    assert C.inscription(m, "transverse-A").bearing == [6, 6, 0]
    assert C.inscription(m, "current-pittoning").points == HereWedging.model().unit.points
  end

  test "two bounded framing envelopes do not invent a second Landinging or cursor" do
    m = C.model()
    assert [one, two] = m.footings
    assert one.ceiling == two.floor
    assert two.ceiling == m.frame.ceiling

    for f <- m.footings, p <- C.corners(f.minimum, f.maximum) do
      assert Enum.all?(p, &(&1 >= 0 and &1 <= 6))
    end

    refute two.acquired
    assert two.actual_entrance == nil
    assert two.cursor == nil
    assert m.circuit.next_xt_origin == nil
    assert m.circuit.next_cursor == nil
    assert m.circuit.opening_condition == :pending
    assert m.circuit.closing_condition == :pending
    assert m.acquired_index == 0
    assert m.actual_footings == []
    refute C.inscription(m, "footing-one-ceiling").id == C.inscription(m, "face-ceiling").id
  end

  test "standing LEFT and staging RIGHT are distinct finite stock across source divider" do
    [left, right] = C.material_pair()
    refute left.material_id == right.material_id
    refute left.vertices == right.vertices
    assert length(left.faces) == 5
    assert left.thickness == 0.04
    assert Enum.all?(left.vertices, &(Enum.at(&1, 2) < 3))
    assert Enum.all?(right.vertices, &(Enum.at(&1, 2) > 3))
    refute MaterialRibbon.collision?(left, right)
    assert left.acquisition == :fixture_not_attested
    assert right.acquisition == :unacquired
    assert right.hinge == nil
  end

  test "FOUR measures existing source variation while SIX reference and transform limit persist" do
    fixed = C.gauge("SIX")
    a = C.gauge("FOUR")
    b = C.gauge("EIGHT")
    assert a.reference == fixed.reference
    assert b.reference == fixed.reference
    assert_in_delta a.signed_radius_difference, -0.5, 1.0e-10
    assert_in_delta b.maximum_separation, 0.5, 1.0e-10
    assert fixed.maximum_separation == 0.0
    assert a.source_to_cubical == nil
    assert a.interpolation_formula == nil
  end

  test "inscriptions resolve exact identity and preserved sources without operational effects" do
    m = C.model()

    assert C.inscription(m, "inherited-HERE").points ==
             Enum.find(GeometryExploration.references(), &(&1.id == "HERE")).points

    assert m.preserved_fit == HereWedging.model().snail.height_range
    assert Enum.at(m.preserved_fit, 1) > 6
    assert m.inherited_janusite.id == JanusiteInheritance.model(JanusiteInheritance.new()).id
    assert length(Enum.uniq(Enum.map(m.components, & &1.id))) == length(m.components)

    for c <- m.components do
      assert {:ok, s} = C.change(C.new(), 0, {:select, c.id})
      assert C.inscription(m, s.selected) == c
      assert c.acquired == false
    end

    assert {:error, :unknown_inscription} = C.change(C.new(), 0, {:select, "missing"})
    assert {:error, :stale_inspection} = C.change(C.new(), 1, {:orbit, 15})

    for operation <- [:re_step, :land, :pin, :open_ceiling, :interpolate] do
      assert {:error, :inspection_only} = C.change(C.new(), 0, operation)
    end
  end
end
