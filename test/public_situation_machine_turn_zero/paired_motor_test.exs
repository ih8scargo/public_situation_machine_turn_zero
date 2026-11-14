defmodule PublicSituationMachineTurnZero.Workshop.PairedMotorTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Workshop.PairedMotor, as: M

  defp act(s, action) do
    {:ok, next} = M.operate(s, s.revision, action)
    next
  end

  test "paired fold preserves hinge and triangle edge lengths at all inspection stations" do
    for q <- [0.0, 0.5, 1.0] do
      model = M.new() |> act({:progress, q}) |> M.model()
      assert Enum.map(model.members, & &1.q) == [q, q, q, q]
      assert Enum.uniq(model.hinges) |> length() == 1

      for i <- [1, 3] do
        [a, t, b, _] = Enum.at(model.members, i).points

        distance = fn u, v ->
          Enum.zip(u, v)
          |> Enum.map(fn {x, y} -> (x - y) * (x - y) end)
          |> Enum.sum()
          |> :math.sqrt()
        end

        assert_in_delta distance.(a, t), 6, 1.0e-8
        assert_in_delta distance.(t, b), 6, 1.0e-8
      end
    end
  end

  test "two trial Footings append in one plane; return is inherited and index never advances" do
    first = M.new() |> act(:ground)
    assert {:error, :prerequisite} = M.operate(first, first.revision, :furnish_return)
    extent = first |> act(:pending_un_buttoning) |> act({:progress, 1.0}) |> act(:furnish_return)
    second = extent |> act(:next) |> act(:ground)
    assert hd(second.footings) == hd(first.footings)

    s =
      second
      |> act(:pending_un_buttoning)
      |> act({:progress, 1.0})
      |> act(:furnish_return)
      |> act(:return_first)

    assert length(s.footings) == 2
    assert Enum.all?(s.footings, &(M.on_plane?(&1.entrance) and &1.cob_ground == &1.craft_ground))
    assert s.return_path == [M.point(1), M.point(0)]
    assert Enum.all?(s.return_path, &M.on_plane?/1)
    assert Enum.all?(s.footings, &(&1.orientation == [1, 0, 1]))
    assert s.index == 0
    assert {:error, :stale} = M.operate(s, 0, :ground)
    assert M.model(s).next_outgoing |> hd() == List.last(M.model(s).course)
  end

  test "identities, canonical cubes, shared world geometry and visible failures" do
    assert M.identities("authored") |> Map.values() |> Enum.uniq() |> length() == 7
    m = M.model(M.new())

    for edges <- [m.here, m.next] do
      assert length(edges) == 12

      for axis <- 0..2 do
        # coordinate extents checked below from vertices
        values = edges |> List.flatten()
        assert length(values) > 0
        coordinates = Enum.flat_map(edges, & &1) |> Enum.map(&Enum.at(&1, axis))
        assert Enum.max(coordinates) - Enum.min(coordinates) == 6
      end
    end

    world = m.members
    assert M.project(m.course, :side) != M.project(m.course, :within)
    assert M.model(M.new()).members == world
    assert length(m.failures) >= 5
  end
end
