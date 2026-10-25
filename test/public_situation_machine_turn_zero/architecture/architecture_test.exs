defmodule PublicSituationMachineTurnZero.ArchitectureTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: Lab
  alias PublicSituationMachineTurnZero.Architecture.{Projection, Seed}

  defp drive(lab, operations) do
    Enum.reduce(operations, lab, fn op, state ->
      assert {:ok, next} = Lab.operate(state, op)
      next
    end)
  end

  test "identities are registered without manufacturing Human standing or seven workflow stages" do
    lab = Lab.new()
    assert Enum.sort(Map.keys(lab.standing["localities"])) == Enum.sort(Seed.localities())
    assert map_size(lab.standing["tunnels"]) == 6
    assert lab.standing["relations"]["human-ground"]["kind"] == "standing relation"
    assert lab.standing["entities"]["human"]["kind"] == "given"
    assert lab.standing["entities"]["actual-tc"]["kind"] == "given"

    assert Enum.uniq(
             Enum.map(
               ~w(human-place-square inner-aperture four-pin-square slate-base-square),
               &lab.standing["entities"][&1]["job"]
             )
           )
           |> length() == 4

    assert Lab.next(lab) == nil
    assert {:error, :step_required} = Lab.operate(lab, {:nav, 1})
    assert {:error, :first_relation_required} = Lab.operate(lab, :step)
    assert {:error, :unavailable_here} = Lab.operate(lab, :appoint)
  end

  test "ZEROETH labor completes enclosing relation and first STEP alone furnishes passage ancestry" do
    initial = Lab.new()
    lab = drive(initial, [:calibrate, :position, :appoint])
    assert lab.standing["from"] == "ZEROETH"
    assert lab.standing["passages"] == []
    assert Lab.zeroeth_complete?(lab)
    assert lab.standing["relations"]["tc-appointed"]["object"] == "actual-tc"
    assert lab.standing["relations"]["tc-positioned"]["object"] == "little-square-chair"
    assert Lab.next(lab)["toward"] == "ONE"
    assert lab.standing["entities"] == initial.standing["entities"]
    lab = drive(lab, [:step])
    assert lab.standing["from"] == "ONE-APPROACH"
    assert [passage] = lab.standing["passages"]
    assert passage["operation"] == "STEP"
    assert passage["inherited"] == Enum.sort(Map.keys(lab.standing["relations"]))
    assert Lab.next(lab) == nil
    refute Lab.quiet_complete?(lab)
    assert {:error, :first_relation_required} = Lab.operate(lab, :step)
    assert {:error, :unavailable_here} = Lab.operate(lab, :appoint)
    assert {:error, :unavailable} = Lab.operate(lab, :re_step)
  end

  test "NAV, Pivot, flat Regard and Projectioning-er extinction cannot change Standing" do
    lab = drive(Lab.new(), [:calibrate, :position, :appoint, :step])
    advanced = drive(lab, List.duplicate({:nav, 1}, 9) ++ [{:pivot, "groundward"}, :flat])
    assert advanced.nav == 6
    assert advanced.standing == lab.standing
    assert drive(advanced, List.duplicate({:nav, -1}, 9)).nav == 0
    off = drive(advanced, [:projection])
    refute off.projection?
    assert off.nav == 0
    assert off.bearing == "approach"
    refute off.flat?
    assert off.standing == lab.standing
    assert {:error, :step_required} = Lab.operate(off, {:nav, 1})
    assert {:error, :unavailable} = Lab.operate(off, {:pivot, "groundward"})
    on = drive(off, [:projection])
    assert on == Lab.restore(lab.standing)
    assert drive(on, List.duplicate({:nav, 1}, 6)).standing == lab.standing
    refute Lab.quiet_complete?(on)
  end

  test "flat and curved presentations resolve identical material and retain dependency provenance" do
    lab =
      drive(Lab.new(), [
        :calibrate,
        :position,
        :appoint,
        :step,
        {:nav, 1},
        {:nav, 1},
        {:nav, 1},
        {:nav, 1}
      ])

    curved = Projection.materials(lab)
    flat = Projection.materials(drive(lab, [:flat]))
    assert Enum.map(curved, &Map.delete(&1, "style")) == Enum.map(flat, &Map.delete(&1, "style"))
    toward = Enum.find(curved, &(&1["id"] == "toward-one"))
    refute toward["usingable"]
    assert toward["missing"] == ["quiet-enclosure"]
    assert {:ok, full} = Lab.fixture_enclosure(lab, true)
    assert full.standing["relations"]["quiet-enclosure"]["origin"] == "ONE"
    assert full.standing["relations"]["quiet-enclosure"]["kind"] == "development fixture"
    assert Lab.quiet_complete?(full)
    assert {:ok, half} = Lab.fixture_enclosure(full, false)
    assert half.standing == lab.standing
    assert half.standing["relations"]["tc-appointed"] == lab.standing["relations"]["tc-appointed"]
  end

  test "composed Tunnel material requires a furnishing locality and cannot repair dependencies" do
    lab = Lab.new()

    attrs = %{
      "title" => "Recovered material",
      "text" => "Still prospective",
      "origin" => "ZEROETH",
      "location" => "ZEROETH-ONE",
      "region" => "continuing-toward",
      "bearing" => "wallward",
      "course" => "3",
      "categories" => ["Readyingmenting", "Relationing + Provenance"],
      "dependencies" => ["quiet-enclosure"]
    }

    assert {:ok, composed} = Lab.compose(lab, "recovered", attrs)
    item = composed.standing["materials"]["recovered"]
    assert item["origin"] == "ZEROETH"
    assert item["toward"] == "ONE"

    assert item["provenance"] == [
             %{"origin" => "ZEROETH", "action" => "composement", "revision" => 1}
           ]

    assert composed.standing["relations"] == lab.standing["relations"]

    assert {:error, %Ecto.Changeset{valid?: false}} =
             Lab.compose(lab, "bad", Map.put(attrs, "origin", "ONE"))

    assert {:error, %Ecto.Changeset{valid?: false}} =
             Lab.compose(lab, "bad", Map.put(attrs, "dependencies", ["invented-by-label"]))

    assert {:ok, revised} =
             Lab.compose(composed, "recovered", %{
               "text" => "Revised inscription",
               "dependencies" => [""]
             })

    assert revised.standing["materials"]["recovered"]["revision"] == 2
    assert revised.standing["materials"]["recovered"]["dependencies"] == []
    assert length(revised.standing["materials"]["recovered"]["provenance"]) == 2
  end

  test "one canonical Toy Box distinguishes inspectability, Pretendingability and Usingability" do
    lab = Lab.new()
    assert map_size(lab.standing["toys"]) == 17
    stand = lab.standing["toys"]["dispensationaling"]
    assert stand["aim"] == "RUGGING"
    refute lab.standing["toys"]["airplane"]["pretendingable"]

    assert {:ok, revised} =
             Lab.compose_toy(lab, "dispensationaling", %{
               "encounter" => "ONE",
               "aim" => "Rehearsed new furnishing",
               "dependencies" => ["quiet-enclosure"],
               "usingable" => "true"
             })

    assert map_size(revised.standing["toys"]) == 17

    refute Lab.dependencies_hold?(
             revised,
             revised.standing["toys"]["dispensationaling"]["dependencies"]
           )

    assert {:error, :unknown_toy} = Lab.compose_toy(lab, "copy", %{})
  end
end
