defmodule PublicSituationMachineTurnZero.Workshop.CoBuildingGeometry do
  @moduledoc "Finite co-building meshes, explicit section frames and bounded intersection diagnostics. No operation authority."
  alias PublicSituationMachineTurnZero.Workshop.MaterialRibbon, as: M

  def box([x, y, z], [u, v, w]) do
    vertices = for(a <- [x, u], b <- [y, v], c <- [z, w], do: [a, b, c])

    faces =
      for ids <- [
            [0, 2, 6, 4],
            [1, 5, 7, 3],
            [0, 4, 5, 1],
            [2, 3, 7, 6],
            [0, 1, 3, 2],
            [4, 6, 7, 5]
          ],
          do: Enum.map(ids, &Enum.at(vertices, &1))

    mesh(faces)
  end

  def prism(points, thickness),
    do:
      M.prism("co-building-specimen", points, thickness)
      |> Map.take([:vertices, :faces, :normal, :thickness, :area])

  def strap(a, b, width, thickness, normal) do
    t = M.unit(M.sub(b, a))
    u = M.unit(M.cross(normal, t))

    sections =
      for p <- [a, b] do
        for {x, y} <- [
              {-width / 2, -thickness / 2},
              {width / 2, -thickness / 2},
              {width / 2, thickness / 2},
              {-width / 2, thickness / 2}
            ],
            do: M.add(p, M.add(M.scale(u, x), M.scale(normal, y)))
      end

    [first, last] = sections
    verts = first ++ last

    mesh(
      for ids <- [
            [0, 3, 2, 1],
            [4, 5, 6, 7],
            [0, 1, 5, 4],
            [1, 2, 6, 5],
            [2, 3, 7, 6],
            [3, 0, 4, 7]
          ],
          do: Enum.map(ids, &Enum.at(verts, &1))
    )
  end

  def mesh(faces),
    do: %{vertices: faces |> List.flatten() |> Enum.chunk_every(3) |> Enum.uniq(), faces: faces}

  def transform(mesh, f) do
    result = %{
      mesh
      | vertices: Enum.map(mesh.vertices, f),
        faces: Enum.map(mesh.faces, &Enum.map(&1, f))
    }

    result =
      if Map.has_key?(mesh, :cells),
        do: Map.put(result, :cells, Enum.map(mesh.cells, &transform(&1, f))),
        else: result

    if Map.has_key?(mesh, :sections),
      do: Map.put(result, :sections, Enum.map(mesh.sections, &Enum.map(&1, f))),
      else: result
  end

  def translate(mesh, offset), do: transform(mesh, &M.add(&1, offset))

  def rotate_y([x, y, z], [cx, cy, cz], degrees) do
    a = degrees * :math.pi() / 180

    [
      cx + (x - cx) * :math.cos(a) - (z - cz) * :math.sin(a),
      cy + (y - cy),
      cz + (x - cx) * :math.sin(a) + (z - cz) * :math.cos(a)
    ]
  end

  def rotate_z([x, y, z], [cx, cy, cz], degrees) do
    a = degrees * :math.pi() / 180

    [
      cx + (x - cx) * :math.cos(a) - (y - cy) * :math.sin(a),
      cy + (x - cx) * :math.sin(a) + (y - cy) * :math.cos(a),
      cz + (z - cz)
    ]
  end

  # Convex clipping preserves a finite cap, rather than hiding overlapping stock.
  def clip(mesh, normal, offset) do
    clipped =
      Enum.map(mesh.faces, fn face ->
        face
        |> Enum.zip(tl(face) ++ [hd(face)])
        |> Enum.flat_map(fn {a, b} ->
          da = M.dot(a, normal) - offset
          db = M.dot(b, normal) - offset

          cond do
            da >= -1.0e-10 and db >= -1.0e-10 -> [b]
            da >= -1.0e-10 -> [M.add(a, M.scale(M.sub(b, a), da / (da - db)))]
            db >= -1.0e-10 -> [M.add(a, M.scale(M.sub(b, a), da / (da - db))), b]
            true -> []
          end
        end)
        |> Enum.uniq()
      end)
      |> Enum.filter(&(length(&1) >= 3))

    cap =
      clipped
      |> Enum.flat_map(& &1)
      |> Enum.filter(&(abs(M.dot(&1, normal) - offset) < 1.0e-8))
      |> Enum.uniq()

    if length(cap) >= 3 do
      center = centroid(cap)
      axis = M.unit(normal)
      u = perpendicular(axis)
      v = M.cross(axis, u)

      cap =
        Enum.sort_by(cap, fn p ->
          q = M.sub(p, center)
          :math.atan2(M.dot(q, v), M.dot(q, u))
        end)
        |> Enum.reverse()

      mesh(clipped ++ [cap])
    else
      mesh(clipped)
    end
  end

  def sweep(path, width, thickness, roll \\ 0) do
    sections =
      frames(path)
      |> Enum.with_index()
      |> Enum.map(fn {f, i} ->
        a = roll * i / max(1, length(path) - 1) * :math.pi() / 180
        u = M.add(M.scale(f.u, :math.cos(a)), M.scale(f.v, :math.sin(a)))
        v = M.add(M.scale(f.v, :math.cos(a)), M.scale(f.u, -:math.sin(a)))

        for {x, y} <- [
              {-width / 2, -thickness / 2},
              {width / 2, -thickness / 2},
              {width / 2, thickness / 2},
              {-width / 2, thickness / 2}
            ],
            do: M.add(f.point, M.add(M.scale(u, x), M.scale(v, y)))
      end)

    cells =
      Enum.chunk_every(sections, 2, 1, :discard)
      |> Enum.map(fn [a, b] ->
        verts = a ++ b

        for ids <- [
              [0, 3, 2, 1],
              [4, 5, 6, 7],
              [0, 1, 5, 4],
              [1, 2, 6, 5],
              [2, 3, 7, 6],
              [3, 0, 4, 7]
            ],
            do: Enum.map(ids, &Enum.at(verts, &1))
      end)
      |> Enum.map(&mesh/1)

    %{
      vertices: Enum.flat_map(sections, & &1),
      faces: boundary_faces(cells),
      cells: cells,
      sections: sections
    }
  end

  def pipe(path, outer, inner, segments \\ 12) do
    sections =
      Enum.map(frames(path), fn f ->
        for radius <- [outer, inner], i <- 0..(segments - 1) do
          a = i * 2 * :math.pi() / segments

          M.add(
            f.point,
            M.add(M.scale(f.u, radius * :math.cos(a)), M.scale(f.v, radius * :math.sin(a)))
          )
        end
      end)

    cells =
      for [a, b] <- Enum.chunk_every(sections, 2, 1, :discard), i <- 0..(segments - 1) do
        j = rem(i + 1, segments)

        verts =
          Enum.map([i, j, j + segments, i + segments], &Enum.at(a, &1)) ++
            Enum.map([i, j, j + segments, i + segments], &Enum.at(b, &1))

        faces =
          for ids <- [
                [0, 3, 2, 1],
                [4, 5, 6, 7],
                [0, 1, 5, 4],
                [1, 2, 6, 5],
                [2, 3, 7, 6],
                [3, 0, 4, 7]
              ],
              do: Enum.map(ids, &Enum.at(verts, &1))

        mesh(faces)
      end

    %{
      vertices: Enum.flat_map(sections, & &1),
      faces: boundary_faces(cells),
      cells: cells,
      sections: sections,
      outer_radius: outer,
      inner_radius: inner
    }
  end

  def sphere_belt(center, outer, inner) do
    sections =
      for j <- 0..8 do
        a = (-60 + j * 15) * :math.pi() / 180

        for r <- [outer, inner], i <- 0..15 do
          b = i * 2 * :math.pi() / 16

          M.add(center, [
            r * :math.cos(a) * :math.cos(b),
            r * :math.sin(a),
            r * :math.cos(a) * :math.sin(b)
          ])
        end
      end

    cells =
      for [a, b] <- Enum.chunk_every(sections, 2, 1, :discard), i <- 0..15 do
        j = rem(i + 1, 16)

        vs =
          Enum.map([i, j, j + 16, i + 16], &Enum.at(a, &1)) ++
            Enum.map([i, j, j + 16, i + 16], &Enum.at(b, &1))

        mesh(
          for ids <- [
                [0, 3, 2, 1],
                [4, 5, 6, 7],
                [0, 1, 5, 4],
                [1, 2, 6, 5],
                [2, 3, 7, 6],
                [3, 0, 4, 7]
              ],
              do: Enum.map(ids, &Enum.at(vs, &1))
        )
      end

    %{vertices: Enum.flat_map(sections, & &1), faces: boundary_faces(cells), cells: cells}
  end

  def globe_adapter([x, y, z], top_y) do
    angle = :math.pi() / 3

    bottom =
      for {r, h} <- [
            {0.32 * :math.cos(angle), y + 0.32 * :math.sin(angle)},
            {0.28 * :math.cos(angle), y + 0.28 * :math.sin(angle)}
          ],
          i <- 0..15 do
        a = i * 2 * :math.pi() / 16
        [x + r * :math.cos(a), h, z + r * :math.sin(a)]
      end

    top =
      for r <- [0.32, 0.18], i <- 0..15 do
        a = i * 2 * :math.pi() / 16
        [x + r * :math.cos(a), top_y, z + r * :math.sin(a)]
      end

    middle =
      for r <- [0.32 * :math.cos(angle), 0.28 * :math.cos(angle)], i <- 0..15 do
        a = i * 2 * :math.pi() / 16
        [x + r * :math.cos(a), (y + 0.32 * :math.sin(angle) + top_y) / 2, z + r * :math.sin(a)]
      end

    cells =
      for [a, b] <- Enum.chunk_every([bottom, middle, top], 2, 1, :discard), i <- 0..15 do
        j = rem(i + 1, 16)

        vs =
          Enum.map([i, j, j + 16, i + 16], &Enum.at(a, &1)) ++
            Enum.map([i, j, j + 16, i + 16], &Enum.at(b, &1))

        mesh(
          for ids <- [
                [0, 3, 2, 1],
                [4, 5, 6, 7],
                [0, 1, 5, 4],
                [1, 2, 6, 5],
                [2, 3, 7, 6],
                [3, 0, 4, 7]
              ],
              do: Enum.map(ids, &Enum.at(vs, &1))
        )
      end

    %{vertices: bottom ++ middle ++ top, faces: boundary_faces(cells), cells: cells}
  end

  def frames(path) do
    last = length(path) - 1
    closed? = M.distance(hd(path), List.last(path)) < 1.0e-9

    Enum.with_index(path)
    |> Enum.map(fn {p, i} ->
      prev = Enum.at(path, if(closed? and i in [0, last], do: last - 1, else: max(0, i - 1)))
      next = Enum.at(path, if(closed? and i in [0, last], do: 1, else: min(last, i + 1)))
      t = M.unit(M.sub(next, prev))
      u = perpendicular(t)
      v = M.cross(t, u)
      %{point: p, tangent: t, u: u, v: v}
    end)
  end

  def perpendicular(t),
    do: M.unit(M.cross(t, if(abs(M.dot(t, [0, 1, 0])) < 0.95, do: [0, 1, 0], else: [1, 0, 0])))

  defp boundary_faces(cells),
    do:
      cells
      |> Enum.flat_map(& &1.faces)
      |> Enum.group_by(&Enum.sort/1)
      |> Enum.flat_map(fn {_, fs} -> if length(fs) == 1, do: fs, else: [] end)

  def centroid(points),
    do: M.scale(Enum.reduce(points, [0, 0, 0], &M.add/2), 1 / max(1, length(points)))

  def cap_area(mesh, normal, offset) do
    mesh.faces
    |> Enum.filter(fn face -> Enum.all?(face, &(abs(M.dot(&1, normal) - offset) < 1.0e-8)) end)
    |> Enum.reduce(0.0, fn [a | rest], sum ->
      sum +
        Enum.reduce(Enum.chunk_every(rest, 2, 1, :discard), 0.0, fn [b, c], area ->
          area + M.norm(M.cross(M.sub(b, a), M.sub(c, a))) / 2
        end)
    end)
  end

  def normal([a, b, c | _]) do
    v = M.cross(M.sub(b, a), M.sub(c, a))
    if M.norm(v) > 1.0e-10, do: M.unit(v), else: [0, 0, 0]
  end

  def collision?(a, b) do
    # Broad phase keeps compound hollow meshes out of inappropriate convex SAT.
    if bounds_overlap?(a.vertices, b.vertices) do
      Enum.any?(Map.get(a, :cells, [a]), fn x ->
        Enum.any?(Map.get(b, :cells, [b]), fn y ->
          bounds_overlap?(x.vertices, y.vertices) and M.collision?(x, y)
        end)
      end)
    else
      false
    end
  end

  defp bounds_overlap?(a, b),
    do:
      Enum.all?(0..2, fn i ->
        {l, h} = a |> Enum.map(&Enum.at(&1, i)) |> Enum.min_max()
        {u, v} = b |> Enum.map(&Enum.at(&1, i)) |> Enum.min_max()
        min(h, v) - max(l, u) > 1.0e-9
      end)

  def ray(origin, dir, faces) do
    for face <- faces, [a, b, c] <- triangles(face), reduce: nil do
      nearest ->
        e1 = M.sub(b, a)
        e2 = M.sub(c, a)
        h = M.cross(dir, e2)
        det = M.dot(e1, h)

        if abs(det) < 1.0e-10 do
          nearest
        else
          s = M.sub(origin, a)
          u = M.dot(s, h) / det
          q = M.cross(s, e1)
          v = M.dot(dir, q) / det
          t = M.dot(e2, q) / det

          if u >= 0 and v >= 0 and u + v <= 1 and t > 1.0e-7 and (is_nil(nearest) or t < nearest),
            do: t,
            else: nearest
        end
    end
  end

  defp triangles([a | rest]),
    do: Enum.chunk_every(rest, 2, 1, :discard) |> Enum.map(fn [b, c] -> [a, b, c] end)
end
