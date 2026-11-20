defmodule PublicSituationMachineTurnZero.LayeringZeroTest do
  use ExUnit.Case, async: true

  alias PublicSituationMachineTurnZero.Workshop.{
    CoBuilding,
    CoBuildingGeometry,
    LayeringZero,
    MaterialRibbon
  }

  setup do
    model = LayeringZero.model()
    %{model: model, pieces: Map.new(model.pieces, &{&1.id, &1})}
  end

  test "the finite transverse specimen has a 45-degree rise and crosses the inherited monitor",
       %{model: model, pieces: pieces} do
    [[[x, y, z], [u, v, w]]] = pieces["transverse:axis"].paths
    inherited = CoBuilding.model(CoBuilding.new())
    assert model.seat == inherited.one
    assert model.table == inherited.three

    assert pieces["cb:monitor"].faces ==
             CoBuilding.selected(inherited, "cb:monitor").source_geometry.faces

    assert_in_delta v - y, :math.sqrt((u - x) ** 2 + (w - z) ** 2), 1.0e-10
    assert z < model.monitor_z and w > model.monitor_z
    [cx, cy, cz] = model.crossing
    assert cx > 1.8 and cx < 4.2
    assert cy > 1.5 and cy < 3.3
    assert_in_delta cz, model.monitor_z, 1.0e-10

    [left, _, right, _] = for i <- 1..4, do: pieces["transverse:letter:#{i}"]
    assert Enum.all?(Enum.concat(left.faces), fn [_, _, z] -> z < cz end)
    assert Enum.all?(Enum.concat(right.faces), fn [_, _, z] -> z > cz end)
  end

  test "section edges belong to the finite first Footing and the complete coil stays independent",
       %{model: model, pieces: pieces} do
    [coil] = pieces["snail:coil"].paths
    assert length(coil) == 145
    assert length(Enum.uniq(coil)) == 145
    assert length(model.pieces) == map_size(pieces)

    vertices = for face <- pieces["footing:first"].faces, p <- face, into: MapSet.new(), do: p

    for edge <- pieces["footing:opening"].paths do
      assert hd(edge) == List.last(edge)
      assert Enum.all?(edge, &MapSet.member?(vertices, &1))
    end

    assert pieces["footing:alongside"].faces != pieces["footing:stacked"].faces
    assert Enum.count(model.pieces, &(&1.kind == "door")) == 8

    for side <- ~w(upper lower) do
      faces = model.pieces |> Enum.filter(&(&1.kind == side)) |> Enum.flat_map(& &1.faces)
      assert length(faces) == 40

      refute Enum.any?(faces, fn face ->
               [x, _, z] =
                 Enum.map(0..2, fn axis -> Enum.sum(Enum.map(face, &Enum.at(&1, axis))) / 4 end)

               angle = :math.atan2(z + 3, x - 3)

               (angle > :math.pi() / 2 and angle < :math.pi()) or
                 (angle > -:math.pi() / 2 and angle < -:math.pi() / 4)
             end)
    end
  end

  test "the comparison records the obstructed aperture and static second-Footing clearance",
       %{pieces: pieces} do
    first = cells(pieces["footing:first"])
    [bar] = cells(pieces["transverse:bar"])

    contacts =
      for {cell, purchase} <- Enum.with_index(cells(pieces["footing:blocked"]), 1),
          CoBuildingGeometry.collision?(bar, cell),
          do: purchase

    assert contacts == [30]

    for id <- ~w(footing:alongside footing:stacked) do
      second = cells(pieces[id])

      refute Enum.any?(first, fn cell ->
               Enum.any?(second, &CoBuildingGeometry.collision?(cell, &1))
             end)
    end
  end

  test "the ceiling comes before the course and the current and return portions share coil joints",
       %{model: model, pieces: pieces} do
    [start | _] = approach = hd(pieces["cob:approach"].paths)
    [ceiling | _] = bank = hd(pieces["cob:bank"].paths)
    [coil] = pieces["snail:coil"].paths
    [around] = pieces["cob:roundabout"].paths
    [return] = pieces["cob:return"].paths

    assert start == model.seat
    assert ceiling == model.ceiling
    assert List.last(approach) == ceiling
    assert List.last(bank) == hd(coil)
    assert Enum.take(coil, length(around)) == around
    assert List.last(around) == hd(return)
    assert MaterialRibbon.distance(hd(coil), List.last(coil)) > 0
  end

  test "all eight opening slices retain four addresses and both resolutions share the furnished ends",
       %{model: model, pieces: pieces} do
    assert length(model.opening.doors) == 8
    assert model.opening.inscription.segments == [3, 6, 9, 7]

    assert model.opening.inscription.return_between ==
             ~w(inscription-letter-18 inscription-letter-19)

    assert Enum.count(model.pieces, &(&1.kind == "cage")) == 25
    assert Enum.count(model.pieces, &(&1.kind == "ground")) == 8

    for door <- model.opening.doors do
      assert length(Enum.uniq(door.endpoints)) == 4
      assert door.points.beginning != door.points.furnished_beginning
      assert door.points.end != door.points.furnished_end
      assert door.curves["positive"] != door.curves["negative"]

      for curve <- Map.values(door.curves) do
        assert MaterialRibbon.distance(hd(curve), door.points.furnished_beginning) < 1.0e-10
        assert MaterialRibbon.distance(List.last(curve), door.points.furnished_end) < 1.0e-10
      end

      assert hd(hd(pieces[door.id <> ":tf"].paths)) == List.last(door.curves["positive"])
      assert List.last(hd(pieces[door.id <> ":tf"].paths)) == door.points.furnished_beginning
    end
  end

  test "the repaired Footing uses the measured midpoint and clears a local static center probe",
       %{model: model, pieces: pieces} do
    [a, b] = model.opening.bearing
    midpoint = model.opening.midpoint
    assert midpoint == [3.0, 3.0, -3.0]

    assert_in_delta MaterialRibbon.distance(a, midpoint),
                    MaterialRibbon.distance(b, midpoint),
                    1.0e-10

    assert_in_delta MaterialRibbon.distance(
                      model.opening.bowstring.edge,
                      model.opening.bowstring.outward
                    ),
                    model.opening.bowstring.measure,
                    1.0e-10

    assert model.opening.bowstring.prior_completed_source == nil
    [bow] = pieces["bowstring:regarding"].paths
    assert hd(bow) == model.opening.bowstring.edge
    assert List.last(bow) == model.opening.bowstring.outward
    assert Enum.any?(bow, fn [_, _, z] -> abs(z + 3) > 0.01 end)
    assert pieces["gallery-door:1:ft-hold"].faces != []

    probe = CoBuildingGeometry.box([2.95, 2.90, -3.05], [3.05, 3.10, -2.95])

    refute Enum.any?(cells(pieces["footing:first"]), &CoBuildingGeometry.collision?(&1, probe))
    [upright] = cells(pieces["footing:upright"])
    refute CoBuildingGeometry.collision?(upright, probe)
  end

  defp cells(piece) do
    piece.faces
    |> Enum.chunk_every(6)
    |> Enum.map(&CoBuildingGeometry.mesh/1)
  end
end
