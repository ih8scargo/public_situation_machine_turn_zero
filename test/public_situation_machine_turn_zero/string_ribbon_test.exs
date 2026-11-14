defmodule PublicSituationMachineTurnZero.Workshop.StringRibbonTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    StringRibbon,
    StringRibbonGeometry,
    ComingAboardMachine
  }

  defp act(s, c), do: StringRibbon.operate(s, s.revision, c)

  defp provided do
    {:ok, s} = act(StringRibbon.new(), :register)
    {:ok, s} = act(s, {:provide, "FROM HERE"})
    s
  end

  test "one provided source is taken in rehearsal with original provenance and no acquisition" do
    initial = StringRibbon.new()
    assert {:error, :unavailable} = act(initial, :take)
    assert {:error, :unavailable} = act(initial, {:provide, "mark"})
    s = provided()
    [turn] = s.source["turns"]
    [record] = s.source["body"]["material"]
    assert s.material.id == record["id"]
    assert turn["material"] == record["id"]
    assert s.material.office == s.source["offices"]["xt"]["id"]
    assert s.material.from != s.material.toward
    refute s.material.acquired?
    refute s.material.pinned?
    assert {:error, :unavailable} = act(s, {:provide, "duplicate"})
    assert {:error, :stale} = StringRibbon.operate(s, 0, :take)
    {:ok, taken} = act(s, :take)
    assert taken.source["active"]["material"] == s.material.id
    assert taken.source["active"]["office"] == s.source["offices"]["yt"]["id"]
    assert taken.source["active"]["mode"] == "rehearsal"
    {:ok, taken} = act(taken, :advance)
    {:ok, taken} = act(taken, :advance)
    assert {:error, :appointed_motion} = act(taken, :advance)
    assert taken.source["footings"] == []
    assert taken.source["completions"] == []

    for operation <- [:complete, :re_step, :pin, :re_zipper, :acquire],
        do: assert({:error, :unavailable} == act(taken, operation))
  end

  test "Regarding and prefix inspection preserve exact world geometry, material and acquired status" do
    s = provided()
    path = StringRibbon.material_course(s)
    r = ComingAboardMachine.registration()

    for view <- ~w(flat tunneling top roundabout) do
      {:ok, changed} = act(s, {:inspect, view, "ribbon", 0.5, 0.0})
      assert changed.source == s.source
      assert changed.material == s.material
      assert StringRibbon.material_course(changed) == path
      objects = StringRibbonGeometry.objects(changed)
      ribbon = Enum.find(objects, &(&1.id == "material"))
      assert ribbon.points == path
      assert length(ribbon.trace) < length(path)
      assert ribbon.material == s.material.id
      assert Enum.find(objects, &(&1.id == "table")).points |> hd() == [r.table_radius, 0.0, 0.0]
    end

    {:ok, returned} = act(s, {:inspect, "flat", "ribbon", 1.0, 0.0})
    assert returned.material == s.material
    assert StringRibbon.material_course(returned) == path
  end

  test "distinct provisional courses retain HERE, SIX endpoint, seat return and two material sides" do
    s = provided()
    rise = StringRibbonGeometry.rising()
    assert hd(rise) == [0.0, 0.0, 2.0]
    assert [0.0, 0.0, 0.0] in rise
    assert List.last(rise) == [0.0, 6.0, 0.0]
    pocket = StringRibbonGeometry.pocketing()
    assert hd(pocket) == [0.0, 6.0, 0.0]
    assert List.last(pocket) == [0.0, 0.0, 2.0]
    refute hd(pocket) == List.last(pocket)

    # The inherited helix goes around 1.5 times, with distinct samples on both sides of its second turn.
    assert Enum.count(pocket, fn [x, _, _] -> x < -2.9 end) > 1

    for course <- ~w(square-lock rising pocketing triangles) do
      {:ok, changed} = act(s, {:inspect, "roundabout", course, 1.0, 1.0})
      objects = StringRibbonGeometry.objects(changed)

      assert Enum.find(objects, &(&1.id == "here")).points ==
               ComingAboardMachine.registration().here ++
                 [hd(ComingAboardMachine.registration().here)]

      for o <- objects,
          face <- StringRibbonGeometry.faces(o, "roundabout"),
          do: assert(face.back_world == Enum.reverse(face.world))

      assert changed.source["footings"] == []
    end
  end
end
