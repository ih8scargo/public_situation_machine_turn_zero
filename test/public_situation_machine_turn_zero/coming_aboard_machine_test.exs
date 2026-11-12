defmodule PublicSituationMachineTurnZero.Workshop.ComingAboardMachineTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.{ComingAboardMachine, ComingAboardAppliance}

  test "common extent registration preserves source square, central Table and distinct seats" do
    r = ComingAboardMachine.registration()

    mapped =
      Enum.map(
        [[-0.7, 0, -0.7], [0.7, 0, -0.7], [0.7, 0, 0.7], [-0.7, 0, 0.7]],
        &ComingAboardMachine.snail_point/1
      )

    for {expected, actual} <- Enum.zip(r.ground, mapped),
        {a, b} <- Enum.zip(expected, actual),
        do: assert_in_delta(a, b, 1.0e-9)

    assert r.table_center == r.place_center
    assert r.table_volume == 0
    assert r.cob == [[0, 0, 0], [0, 1, 0]]
    assert r.traversaling_seat == [0, 0, 2]
    assert r.craft_seat == [0, 6, 2]
    assert Enum.all?(r.monitor.points, &(abs(Enum.at(&1, 2) - 3) < 1.0e-9))
    assert length(r.tuple.rows) == 7

    for t <- [0.0, 0.5, 1.0] do
      [a, b] = ComingAboardMachine.bearing(t)
      mid = Enum.zip_with(a, b, &((&1 + &2) / 2))

      assert Enum.zip_with(mid, ComingAboardMachine.road(t), &(abs(&1 - &2) < 1.0e-9))
             |> Enum.all?()

      assert length(ComingAboardMachine.u(t)) == 4
    end

    assert ComingAboardMachine.tangent(1) == [
             :math.cos(:math.pi() / 4),
             0,
             :math.sin(:math.pi() / 4)
           ]
  end

  test "pull, Human Quilling, Doll Stitching and explicit relinquishment have separate consequences" do
    s = ComingAboardAppliance.new()
    assert ComingAboardAppliance.operate(s, "needle-take", %{}) == s
    assert ComingAboardAppliance.open(s, 0, 0) == s
    s = ComingAboardAppliance.open(s, 20, -15)
    assert s.machine_open?
    assert Enum.any?(ComingAboardMachine.scene(s), &(&1.id == "standing-string"))
    assert s.line_open? == false
    s = ComingAboardAppliance.operate(s, "needle-take", %{})
    s = ComingAboardAppliance.operate(s, "quill", %{"quill" => %{"text" => "FROM HERE"}})
    id = s.inscription
    assert is_binary(id)
    assert s.stitched == MapSet.new()
    s = ComingAboardAppliance.operate(s, "stitch", %{})
    assert MapSet.member?(s.stitched, id)

    for view <- ~w(flat dollside tunnel top back) do
      changed = ComingAboardAppliance.operate(s, "machine-view", %{"selection" => view})
      assert changed.inscription == id
      assert changed.needle == s.needle

      assert Enum.find(ComingAboardMachine.scene(changed), &(&1.id == "monitor")).points ==
               Enum.find(ComingAboardMachine.scene(s), &(&1.id == "monitor")).points

      glyphs = ComingAboardMachine.glyphs(changed)
      assert Enum.all?(glyphs, &(&1.material == id))
      assert Enum.all?(glyphs, &(&1.visible == view not in ~w(top back)))
    end

    s = ComingAboardAppliance.operate(s, "needle-withdraw", %{})
    s = ComingAboardAppliance.operate(s, "needle-return", %{})
    assert s.needle["held"] == nil
    assert s.needle["needle"] == "gathering"
    assert s.inscription == id
    s = ComingAboardAppliance.operate(s, "needle-gather", %{})
    assert s.needle["needle"] == "inkwell"
    assert s.needle["outstanding"] == 0
  end

  test "horn inspection, candidate and real PUFFING do not acquire or RE-STEP" do
    s = ComingAboardAppliance.new() |> ComingAboardAppliance.open(20, -15)
    assert ComingAboardAppliance.operate(s, "tunnel-puff", %{}) == s
    s = ComingAboardAppliance.operate(s, "view", %{"selection" => "within-cab"})
    s = ComingAboardAppliance.operate(s, "cab-puff", %{})
    refute s.puffed?
    s = ComingAboardAppliance.operate(s, "cab-select", %{})
    refute s.puffed?
    s = ComingAboardAppliance.operate(s, "tunnel-puff", %{})
    assert s.puffed?
    assert PublicSituationMachineTurnZero.Architecture.puffed?(s.opening)
    assert s.material == %{}
    assert s.approach == nil
    assert s.illuminations == 0
    assert ComingAboardAppliance.operate(s, "re-step", %{}) == s
  end
end
