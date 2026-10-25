defmodule PublicSituationMachineTurnZero.MotorTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Motor

  defp op(m, operation) do
    assert {:ok, next} = Motor.operate(m, operation)
    next
  end

  test "singular PUFF next is not occupancy, Regarding or passage" do
    m = op(Motor.new(), :puff)
    assert m.standing["from"] == "A"
    assert m.standing["next"] == %{"from" => "A", "toward" => "B", "by_way_of" => "PUFF"}
    assert map_size(m.standing["extents"]) == 2
    assert {:error, _} = Motor.operate(m, :puff)
    refute Motor.projectable?(m, "B")
    assert {:error, _} = Motor.operate(m, {:pivot, "B"})
    assert {:error, _} = Motor.operate(m, :point)
    assert {:error, _} = Motor.operate(m, :select)
    assert {:error, _} = Motor.operate(m, :re_seat)
    assert {:error, _} = Motor.operate(m, {:nav_step, 1})
    assert {:error, _} = Motor.operate(m, {:in_string, "B", "b"})
    assert Motor.availability(m)["re-step"]
    m = op(m, :re_step)
    assert m.standing["from"] == "B"
    assert m.standing["next"] == nil
    assert {:error, _} = Motor.operate(m, :re_step)
    refute Motor.projectable?(m, "B")
    assert {:error, _} = Motor.operate(m, {:in_string, "A", "a"})
    assert {:error, _} = Motor.operate(m, {:in_string, "B", " "})
    m = op(m, {:in_string, "B", "字"})
    assert Motor.projectable?(m, "B")
    assert m.standing["from"] == "B"
  end

  test "primitive circuit persists coherent A B C D ancestry without occupancy" do
    m =
      Enum.reduce([{"A", "B"}, {"B", "C"}, {"C", "D"}], Motor.new(), fn {from, toward}, acc ->
        next = op(acc, :puff)
        assert next.standing["from"] == from
        assert next.standing["next"]["toward"] == toward
        next = next.standing |> Motor.restore() |> op(:re_step)
        assert next.standing["from"] == toward
        assert next.standing["extents"][toward]["parent"] == from
        next
      end)

    assert Enum.map(m.standing["passages"], &{&1["from"], &1["toward"], &1["by_way_of"]}) ==
             [{"A", "B", "PUFF"}, {"B", "C", "PUFF"}, {"C", "D", "PUFF"}]

    m = op(m, {:in_string, "D", "d"}) |> op({:pivot, "A"})
    assert m.standing["from"] == "D"
    refute Motor.projectable?(m, "B")
  end

  defp reseated do
    Motor.new()
    |> op(:fixture)
    |> op({:pivot, "LAB-Y"})
    |> op(:point)
    |> op(:select)
    |> op(:re_seat)
  end

  test "differentiated fixture requires distinct pointing selection and reseating" do
    m = Motor.new() |> op(:fixture) |> op({:pivot, "LAB-Y"})
    assert m.pointed == nil && m.selected == nil
    assert {:error, _} = Motor.operate(m, :select)
    assert {:error, _} = Motor.operate(m, :re_step)
    m = op(m, :point)
    assert m.selected == nil
    assert {:error, _} = Motor.operate(m, :re_seat)
    m = op(m, :select)
    assert m.standing["from"] == "A"
    assert {:error, _} = Motor.operate(m, :re_step)
    m = op(m, :re_seat)
    standing = m.standing

    m =
      Enum.reduce(1..3, m, fn _, acc ->
        next = op(acc, {:nav_step, 1.0})
        assert next.standing == standing
        next
      end)

    assert m.progress == 15.0
    assert Motor.projection(m).passed_markers == [10.0]
    m = op(m, {:pivot, "A"})
    assert m.selected == nil
    assert m.standing == standing
    assert {:error, _} = Motor.operate(m, :re_step)
    m = m |> op({:pivot, "LAB-Y"}) |> op(:point) |> op(:select) |> op(:re_step)
    assert m.standing["from"] == "LAB-Y"
    assert List.last(m.standing["passages"])["by_way_of"] == "RE-SEATING"
    assert m.standing["landings"] == standing["landings"]
  end

  test "pace affects only normalized progression and not Standing" do
    m = reseated()
    slow = m |> op({:rate, 0.05}) |> op({:nav_step, 1.0})
    fast = m |> op({:rate, 100.0}) |> op({:nav_step, 1.0})
    assert slow.progress == 0.05 && fast.progress == 100.0
    assert slow.standing == m.standing && fast.standing == m.standing
  end

  test "THIS NEXT takes priority over optional differentiated passage" do
    m = reseated() |> op(:puff) |> op(:re_step)
    assert m.standing["from"] == "B"
    assert Map.has_key?(m.standing["landings"], "A:LAB-Y")
  end

  test "legacy restore does not invent pending next or expose uninhabited possibilities" do
    legacy = %{
      "from" => "B",
      "extents" => %{
        "A" => %{"what_for" => "a"},
        "B" => %{"what_for" => nil},
        "C" => %{"what_for" => "old inscription"}
      },
      "landings" => %{},
      "passages" => [%{"from" => "A", "toward" => "B"}]
    }

    m = Motor.restore(legacy)
    assert m.standing["next"] == nil
    assert m.standing["extents"]["B"]["kind"] == "standing"
    refute Motor.projectable?(m, "C")
    assert m.standing["extents"]["C"]["what_for"] == "old inscription"
  end
end
