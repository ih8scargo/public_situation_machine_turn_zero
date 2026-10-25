defmodule PublicSituationMachineTurnZero.InstrumentationTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Instrumentation, as: Lab

  defp drive(lab, operations),
    do:
      Enum.reduce(operations, lab, fn op, state ->
        assert {:ok, next} = Lab.operate(state, op)
        next
      end)

  test "every Regarding posture preserves all Standing until the downward stroke" do
    initial = Lab.new()

    before_stroke =
      Enum.reduce(
        [
          :tray,
          {:lift, "B"},
          :turn,
          :return,
          {:lift, "C"},
          :turn,
          :select,
          :align,
          :illuminate,
          :pivot,
          :over
        ],
        initial,
        fn op, state ->
          assert {:ok, next} = Lab.operate(state, op)
          assert next.standing == initial.standing
          next
        end
      )

    seated = drive(before_stroke, [:seat])
    assert seated.standing["seated"] == %{"station" => "C", "bearing" => "toward-place"}
    assert Map.delete(seated.standing, "seated") == Map.delete(initial.standing, "seated")
    assert seated.standing["next"] == nil
    assert seated.standing["passages"] == []
    assert seated.standing["from"] == "A"
    assert Lab.station(seated, "A") == Lab.station(initial, "A")
    back = drive(seated, [:tray, :tray, {:lift, "A"}, :select, :align, :over, :seat])
    assert back.standing == initial.standing
  end

  test "forged or premature operations cannot seat and turning invalidates alignment" do
    lab = Lab.new()

    for op <- [:select, :align, :over, :seat, :turn, :puff, :re_step, {:lift, "B"}] do
      assert {:error, :unavailable} = Lab.operate(lab, op)
    end

    lab = drive(lab, [:tray])
    assert {:error, :unknown_station} = Lab.operate(lab, {:lift, "unknown"})
    lab = drive(lab, [{:lift, "C"}, :select, :align, :over, :turn])
    refute Lab.available?(lab, :seat)
    assert lab.selected == nil
    assert {:error, :unavailable} = Lab.operate(lab, :seat)
  end

  test "abandoning inspection and restoring a saved snapshot resets projection only" do
    initial = Lab.new()

    lab =
      drive(initial, [:tray, {:lift, "C"}, :turn, :select, :align, :over, :pivot, :illuminate])

    restored = Lab.restore(lab.standing)
    assert restored == initial
    assert drive(lab, [:return]).standing == initial.standing
    assert drive(lab, [:tray]).standing == initial.standing
    assert Lab.rail(lab) == Lab.rail(initial)
    assert lab.standing["relations"] == initial.standing["relations"]
  end
end
