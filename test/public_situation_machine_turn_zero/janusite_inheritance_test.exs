defmodule PublicSituationMachineTurnZero.JanusiteInheritanceTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.{JanusiteInheritance, HereWedging}
  alias JanusiteInheritance, as: J

  test "ROOM has two finite Toe registrations per letter and distinct loop/head/tail" do
    m = J.model(J.new())
    assert Enum.map(m.letters, & &1.letter) == ~w(R O O M)
    assert m.head != m.tail

    for l <- m.letters do
      assert length(l.toes) == 2
      refute l.loop.stitch
      assert Enum.all?(l.toes, &(length(&1.solid.faces) == 6))
    end
  end

  test "additional authored supply retains top-to-bottom measure and same curve for COB" do
    a = J.model(J.new())
    b = J.model(%{J.new() | text: "ROOMROOM"})
    assert a.road.top_to_bottom == b.road.top_to_bottom
    assert_in_delta b.road.length, 2 * a.road.length, 1.0e-10
    assert a.source_line.points == a.cob_course.points
    assert a.source_line.id == a.cob_course.source_line_id
    refute a.id == b.id
  end

  test "inspection and hypothetical origin never create finite next length or acquisition" do
    s = J.new()
    m = J.model(s)
    assert m.inheritance.next_xt_origin == nil
    {:ok, s} = J.change(s, {:footing, "two"})
    {:ok, s} = J.change(s, {:toggle, :hypothetical?})
    next = J.model(s)
    assert next.inheritance.next_xt_origin.point == m.source_line.points |> List.last()
    assert next.inheritance.next_material_points == []
    refute next.inheritance.cursor_furnishes_length
    assert next.acquired_index == 0

    for view <- ~w(flat longhouse tunneling) do
      {:ok, v} = J.change(s, {:view, view})
      assert J.model(v) == next
    end

    assert {:error, :inspection_only} = J.change(s, :re_step)
    assert m.preserved_fit == HereWedging.model().snail.height_range
    assert m.table.exchange == :blocked_no_physical_transform
  end
end
