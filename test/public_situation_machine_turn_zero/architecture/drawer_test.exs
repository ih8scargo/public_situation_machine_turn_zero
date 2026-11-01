defmodule PublicSituationMachineTurnZero.DrawerTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Diorama, as: D

  defp appointed do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 10, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => 24, "pitch" => -12, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    m
  end

  defp op(m, params),
    do:
      A.operate(m, {:diorama_operation, Map.put(params, "revision", D.mechanical(m)["revision"])})

  test "second PUFFING is gated, distinct, inherited and preserves original geometry and events" do
    assert {:error, :unavailable} = A.operate(A.new(), :second_puff)
    m = appointed()
    assert {:error, :unavailable} = op(m, %{"action" => "compose", "side" => "ch", "slot" => 1})
    {:ok, puffed} = A.operate(m, :second_puff)
    assert Enum.take(puffed.standing["events"], 3) == m.standing["events"]
    assert List.last(puffed.standing["events"])["id"] == "second-puffing"
    assert puffed.standing["from"] == m.standing["from"]

    assert Map.delete(puffed.standing["opening_geometry"], "drawer_extent") ==
             m.standing["opening_geometry"]

    assert D.mechanical(puffed)["progress"] == 0
    assert D.mechanical(puffed)["ch_slot"] == nil
    refute D.mechanical(puffed)["detent"]
    extent = puffed.standing["opening_geometry"]["drawer_extent"]
    globe = m.standing["opening_geometry"]["janusite"]

    assert Enum.zip(extent["radii"], globe["radii"])
           |> Enum.all?(fn {outer, inner} -> outer > inner end)

    assert Enum.any?(
             A.ancestry(puffed, "drawer-extent-standing"),
             &(&1["id"] == "pointingable-standing")
           )

    [cx, cy, cz] = extent["center"]
    [ex, ey, ez] = extent["radii"]

    for x <- extent["rail"]["x_slots"], i <- 0..100 do
      angle = i / 100 * :math.pi()
      y = -extent["rail"]["height"] * :math.cos(angle)
      z = extent["rail"]["depth"] * :math.sin(angle)

      x = x - extent["rail"]["inward"] * (1 - :math.cos(angle)) / 2

      inside =
        :math.pow((x - cx) / ex, 2) + :math.pow((y - cy) / ey, 2) + :math.pow((z - cz) / ez, 2)

      assert inside < 1
    end

    assert {:error, :unavailable} = A.operate(puffed, :second_puff)
  end

  test "composed purchases, completed return and deliberate release are mechanical, with unchanged FROM and event ancestry" do
    {:ok, m} = A.operate(appointed(), :second_puff)
    standing = m.standing
    assert {:error, :unavailable} = op(m, %{"action" => "travel", "progress" => 1})

    for slot <- [-1, 3, "1"],
        do:
          assert(
            {:error, :unavailable} =
              op(m, %{"action" => "compose", "side" => "ch", "slot" => slot})
          )

    {:ok, m} = op(m, %{"action" => "compose", "side" => "ch", "slot" => 0})
    {:ok, m} = op(m, %{"action" => "compose", "side" => "cob", "slot" => 2})
    {:ok, half} = op(m, %{"action" => "travel", "progress" => 0.5})
    refute D.mechanical(half)["detent"]

    assert {:error, :unavailable} =
             op(half, %{"action" => "compose", "side" => "ch", "slot" => 1})

    {:ok, locked} = op(half, %{"action" => "travel", "progress" => 1})
    assert D.mechanical(locked)["detent"]
    assert {:error, :unavailable} = op(locked, %{"action" => "travel", "progress" => 0})
    assert D.mechanical(A.restore(locked.standing)) == D.mechanical(locked)
    {:ok, released} = op(locked, %{"action" => "release"})
    refute D.mechanical(released)["detent"]
    {:ok, closed} = op(released, %{"action" => "travel", "progress" => 0})
    assert Map.delete(closed.standing, "diorama_operation") == standing
    assert closed.standing["localities"] == standing["localities"]
    assert closed.standing["from"] == standing["from"]

    assert {:error, :unavailable} =
             D.operate(closed, %{"revision" => 0, "action" => "travel", "progress" => 1})
  end
end
