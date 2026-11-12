defmodule PublicSituationMachineTurnZero.CommonMaterialRegistrationTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    SnailWeave,
    SnailWeaveGeometry,
    SnailEmergence,
    SnailNearMonitor,
    CommonMaterialRegistration
  }

  defp model(s) do
    base = SnailWeaveGeometry.model(s)
    g = Map.put(base, :emergence, SnailEmergence.model(s, base))
    g = Map.put(g, :near_monitor, SnailNearMonitor.model(s, g))
    CommonMaterialRegistration.model(s, g)
  end

  test "a draft or retained material without explicit staging supplies no second String" do
    assert model(SnailWeave.new()).source == nil

    {:ok, s} =
      SnailWeave.import(File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json"))

    assert model(%{s | "turns" => []}).samples == []
    assert model(%{s | "turns" => []}).source == nil
    original_id = model(s).source.material["id"]

    {:ok, with_new_words} =
      SnailWeave.operate(s, s["revision"], {:quill, "Unregistered later words"})

    assert model(with_new_words).source.material["id"] == original_id
  end

  test "one staged source has an anchored finite extent, not a midpoint promoted into a String" do
    {:ok, s} =
      SnailWeave.import(File.read!("docs/visual-witnesses/snail-weave/two-woven-turns.json"))

    before = SnailWeave.export(s)
    m = model(s)

    assert Jason.decode!(File.read!("test/fixtures/common_material_contract.json")) ==
             m |> Jason.encode!() |> Jason.decode!()

    [a, b] = m.mapping.endpoints
    assert m.diagonal.midpoint == Enum.zip_with(a, b, &((&1 + &2) / 2))
    assert a != b
    assert m.mapping.anchor_parameter == 0.5
    assert m.mapping.physical_transform == nil
    assert m.mapping.yt_metric == nil
    assert m.source.material["id"] == List.last(s["turns"])["material"]
    assert m.source.ancestry == s["tool_ancestry"]

    for sample <- m.samples do
      assert sample.material == m.source.material["id"]
      assert sample.point == Enum.zip_with(a, b, fn x, y -> x + sample.t * (y - x) end)
    end

    assert Enum.map(m.sequence, & &1.name) == ["STAND UP", "STAND DOWN", "STAND UP UPON"]
    assert Enum.all?(m.sequence, &(&1.status == "UNREGISTERED"))
    assert m.registration.ground.to_snail == nil
    assert m.registration.next.upper_boundary == nil
    assert m.registration.next.horizontal_separation == nil
    assert m.registration.upper_check.status == "UNREGISTERED"
    assert m.registration.issuing_post.endpoints == nil
    assert SnailWeave.export(s) == before
  end

  test "SIX is signed distance UP from independent Ground, not center distance or horizontal separation" do
    check = &CommonMaterialRegistration.upper_boundary_check/4
    assert check.([10, 3, -2], [0, 2, 0], [82, 15, 123], 2).status == "CONSISTENT"
    assert check.([10, 3, -2], [0, 1, 0], [16, 3, -2], 1).status == "INCONSISTENT"
    assert check.([0, 0, 0], [0, 0, 1], [3, 8, 6], 1).status == "CONSISTENT"
    assert check.([0, 0, 0], [0, 0, 0], [3, 8, 6], 1).status == "UNREGISTERED"
    assert check.(nil, [0, 1, 0], nil, nil).status == "UNREGISTERED"
  end
end
