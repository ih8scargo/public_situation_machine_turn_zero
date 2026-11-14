defmodule PublicSituationMachineTurnZero.Workshop.BearingRegistrationStudy do
  @moduledoc "Local bearing registration and bounded finite stock comparisons."

  alias PublicSituationMachineTurnZero.Workshop.{AlongsideStaging, GeometryExploration}
  alias PublicSituationMachineTurnZero.Workshop.MaterialRibbon, as: M

  @blue %{origin: [0, 0, 0], maximum: [3, 3, 3]}
  @yellow %{origin: [0, 0, 3], maximum: [3, 3, 6]}
  @return [[3, 3, 3], [0, 0, 6]]
  @width 0.16
  @thickness 0.04

  def model do
    q = 3 / :math.sqrt(2)
    blue_face = face(@blue, List.last(@blue.maximum))
    yellow_face = face(@yellow, List.last(@yellow.origin))

    %{
      blue: @blue,
      yellow: @yellow,
      face: blue_face,
      face_match: blue_face == yellow_face,
      area: 9,
      trials: [
        trial("face", "A · 45° face elevation", [3, 3, 0], "[3, 3, 0]", "3√2"),
        trial("transverse", "B · 45° transverse", [q, 3, q], "[3/√2, 3, 3/√2]", "3√2"),
        trial("historical", "Historical · body diagonal", [3, 3, 3], "[3, 3, 3]", "3√3")
      ]
    }
  end

  defp face(box, z) do
    [x0, y0, _] = box.origin
    [x1, y1, _] = box.maximum
    [[x0, y0, z], [x1, y0, z], [x1, y1, z], [x0, y1, z]]
  end

  defp trial(id, label, [x, y, z] = endpoint, exact_endpoint, exact_length) do
    bearing = [[0, 0, 0], endpoint]
    [seam, _] = @return
    blue = bar(bearing)
    yellow = bar(@return)
    plane_hit = if z > 0, do: [3 * x / z, 3 * y / z, 3.0]
    face_hit = if plane_hit && z >= 3 && inside?(plane_hit, @blue), do: plane_hit
    opening = AlongsideStaging.aperture()
    trial_opening = %{center: seam, radius: opening.radius}
    hinge = hinge_samples(blue, yellow, seam)
    lowest = Enum.map([blue, yellow], &lowest_y/1)

    %{
      id: id,
      label: label,
      bearing: bearing,
      stock_edges: Enum.map([blue, yellow], & &1.faces),
      return: @return,
      exact_endpoint: exact_endpoint,
      exact_length: exact_length,
      run: M.norm([x, 0, z]),
      elevation: degrees(:math.atan2(y, M.norm([x, 0, z]))),
      azimuth: degrees(:math.atan2(z, x)),
      plane_hit: plane_hit,
      face_hit: face_hit,
      gap: M.distance(endpoint, seam),
      point_match: endpoint == seam,
      turn: degrees(:math.acos(M.dot(blue.tangent, yellow.tangent))),
      tangent_dot: M.dot(blue.tangent, yellow.tangent),
      normal_dot: M.dot(blue.normal, yellow.normal),
      end_match: blue.finish == yellow.start,
      blue_fits: fits?(blue, @blue),
      yellow_fits: fits?(yellow, @yellow),
      overlap: M.collision?(blue, yellow),
      hinge: hinge,
      footprints: Enum.map([blue, yellow], &fits?(&1, GeometryExploration.frame())),
      workshop_aperture: aperture(blue, opening),
      trial_aperture: Enum.map([blue, yellow], &aperture(&1, trial_opening)),
      trial_combined_aperture: combined_aperture(blue, yellow, trial_opening),
      floors: lowest,
      newest_nearest: lower?(List.last(lowest), hd(lowest)),
      stock_volume: @width * @thickness * (blue.length + yellow.length)
    }
  end

  defp bar([from, to]) do
    direction = M.sub(to, from)
    tangent = M.unit(direction)
    [x, _, z] = tangent
    across = M.unit([-z, 0, x])
    normal = M.cross(tangent, across)
    start = section(from, across, normal)
    finish = section(to, across, normal)

    Map.merge(solid(start, finish), %{
      tangent: tangent,
      normal: normal,
      start: start,
      finish: finish,
      length: M.norm(direction)
    })
  end

  defp section(center, across, normal) do
    for {w, t} <- [{-1, -1}, {1, -1}, {1, 1}, {-1, 1}] do
      M.add(center, M.add(M.scale(across, w * @width / 2), M.scale(normal, t * @thickness / 2)))
    end
  end

  defp solid(start, finish) do
    vertices = start ++ finish

    faces =
      for indices <- [
            [0, 3, 2, 1],
            [4, 5, 6, 7],
            [0, 1, 5, 4],
            [1, 2, 6, 5],
            [2, 3, 7, 6],
            [3, 0, 4, 7]
          ] do
        Enum.map(indices, &Enum.at(vertices, &1))
      end

    %{vertices: vertices, faces: faces}
  end

  defp hinge_samples(blue, yellow, pivot) do
    axis = M.unit(M.cross(yellow.tangent, blue.tangent))
    turn = :math.acos(M.dot(yellow.tangent, blue.tangent))
    parent = GeometryExploration.frame()

    for step <- 0..8 do
      angle = turn * step / 8

      rotate = fn point ->
        v = M.sub(point, pivot)

        M.add(
          pivot,
          M.add(
            M.scale(v, :math.cos(angle)),
            M.add(
              M.scale(M.cross(axis, v), :math.sin(angle)),
              M.scale(axis, M.dot(axis, v) * (1 - :math.cos(angle)))
            )
          )
        )
      end

      rotated = solid(Enum.map(yellow.start, rotate), Enum.map(yellow.finish, rotate))

      %{
        angle: degrees(angle),
        overlap: M.collision?(blue, rotated),
        both_fit_six: fits?(blue, parent) and fits?(rotated, parent),
        stock_floor: lowest_y(rotated),
        newest_nearest: lower?(lowest_y(rotated), lowest_y(blue)),
        seam_aperture: aperture(rotated, %{center: pivot, radius: 0.4}),
        length_error: abs(M.distance(rotate.(pivot), rotate.(List.last(@return))) - yellow.length)
      }
    end
  end

  defp combined_aperture(blue, yellow, opening) do
    a = aperture(blue, opening)
    b = aperture(yellow, opening)
    a == :clear and b == :clear and not M.collision?(blue, yellow) and blue.finish == yellow.start
  end

  defp aperture(solid, %{center: [_, _, z] = center, radius: radius}) do
    points =
      for face <- solid.faces,
          [a, b] <- Enum.chunk_every(face ++ [hd(face)], 2, 1, :discard),
          az = List.last(a),
          bz = List.last(b),
          point <- plane_edge(a, b, az - z, bz - z),
          do: point

    cond do
      points == [] -> :misses_plane
      Enum.any?(points, &(M.distance(&1, center) > radius)) -> :outside_radius
      true -> :clear
    end
  end

  defp plane_edge(a, b, da, db) do
    cond do
      da == 0 and db == 0 -> [a, b]
      da * db <= 0 -> [M.add(a, M.scale(M.sub(b, a), da / (da - db)))]
      true -> []
    end
  end

  defp fits?(stock, box), do: Enum.all?(stock.vertices, &inside?(&1, box))

  defp inside?(point, box) do
    Enum.zip([point, Map.get(box, :origin, Map.get(box, :minimum)), box.maximum])
    |> Enum.all?(fn {v, lo, hi} -> v >= lo - 1.0e-9 and v <= hi + 1.0e-9 end)
  end

  defp lowest_y(stock), do: stock.vertices |> Enum.map(&Enum.at(&1, 1)) |> Enum.min()
  defp lower?(a, b), do: b - a > 1.0e-9
  defp degrees(angle), do: angle * 180 / :math.pi()

  def project(points, view) do
    Enum.map_join(points, " ", fn point ->
      {x, y} = position(point, view)
      "#{x},#{y}"
    end)
  end

  def position([x, y, z], view) do
    {u, v} =
      case view do
        "Flat" -> {x, y}
        "Side" -> {z, y}
        "Top" -> {x, z}
        "Tunnel" -> {1.5 + (x - 1.5) * 8 / (8 + z), 1.5 + (y - 1.5) * 8 / (8 + z)}
        "Oblique" -> {x + 0.52 * z, y + 0.34 * z}
      end

    {15 + 24 * u, 160 - 24 * v}
  end
end
