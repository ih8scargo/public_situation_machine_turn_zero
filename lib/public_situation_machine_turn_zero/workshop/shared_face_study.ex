defmodule PublicSituationMachineTurnZero.Workshop.SharedFaceStudy do
  @moduledoc "Bounded drawing registration and finite candidate stock tests. See three-footing-study.md."
  alias PublicSituationMachineTurnZero.Workshop.{
    AlongsideStaging,
    GeometryExploration,
    HereWedging
  }

  alias PublicSituationMachineTurnZero.Workshop.MaterialRibbon, as: M

  @version "three-footing-shared-face-v1"
  def version, do: @version

  def model do
    frame = GeometryExploration.frame()

    registrations = [
      registration("blue", [0, 0, 0], [0, 0], [3, 3], 1, frame),
      registration("yellow", [0, 0, 3], [3, 3], [0, 0], 2, frame),
      registration("third", [0, 0, 6], [0, 0], [3, 3], 3, frame)
    ]

    [blue, yellow, third] = registrations
    handoffs = [handoff(blue, yellow), handoff(yellow, third)]

    coils = Enum.map(registrations, & &1.coil)
    coil_pairs = [{blue, yellow}, {yellow, third}, {blue, third}]

    opening = AlongsideStaging.aperture()
    heights = Enum.map(coils, & &1.lowest_stock_y)

    %{
      version: @version,
      frame: frame.id,
      registrations: registrations,
      handoffs: handoffs,
      fold_order: heights,
      newest_nearest_floor:
        Enum.all?(Enum.chunk_every(heights, 2, 1, :discard), fn [a, b] -> b < a end),
      workshop_opening: Map.take(opening, [:id, :normal, :center]),
      coil_pairs:
        Enum.map(coil_pairs, fn {a, b} ->
          %{ids: [a.id, b.id], interference: GeometryExploration.interference(a.coil, b.coil)}
        end),
      common_aperture_control:
        GeometryExploration.interference(GeometryExploration.coil(1), GeometryExploration.coil(2)),
      minimum_capacity: frame.minimum_capacity,
      registered_inside: Enum.count(registrations, & &1.inside_parent),
      physical_capacity: frame.capacity_status,
      snail:
        Map.take(HereWedging.model().snail, [:height_range, :fits_six_height, :scale, :source]),
      aperture_status: :drawing_planes_unresolved,
      optics: :unproved
    }
  end

  defp registration(id, [0, 0, z] = origin, [sx, sy], [ex, ey], ordinal, frame) do
    maximum = M.add(origin, [3, 3, 3])
    from = [sx, sy, z]
    to = [ex, ey, z + 3]
    direction = M.sub(to, from)
    tangent = M.unit(direction)
    across = M.unit([ey - sy, sx - ex, 0])
    normal = M.unit(M.cross(tangent, across))
    start_boundary = boundary(from, across, normal)
    end_boundary = boundary(to, across, normal)
    coil = translate_coil(ordinal, [1.5, 2.8, z + 0.5], frame)

    %{
      id: id,
      origin: origin,
      maximum: maximum,
      inside_parent: inside?(origin, frame) and inside?(maximum, frame),
      bearing: [from, to],
      bearing_length: M.norm(direction),
      tangent: tangent,
      normal: normal,
      start_boundary: start_boundary,
      end_boundary: end_boundary,
      solid: solid(start_boundary, end_boundary),
      coil: coil
    }
  end

  defp translate_coil(ordinal, center, frame) do
    source = GeometryExploration.coil(ordinal)
    offset = M.sub(center, source.entrance)
    translate = &M.add(&1, offset)

    segments =
      Enum.map(source.segments, fn segment ->
        %{
          segment
          | vertices: Enum.map(segment.vertices, translate),
            faces: Enum.map(segment.faces, &Enum.map(&1, translate))
        }
      end)

    vertices = Enum.flat_map(segments, & &1.vertices)

    %{
      id: "shared-face:#{ordinal}",
      source: source.id,
      stock_source: source.source,
      segments: segments,
      points: Enum.map(source.points, translate),
      length: source.material_length,
      through_trial_plane: through_trial_plane?(source, translate, center),
      width: source.width,
      thickness: source.thickness,
      lowest_stock_y: vertices |> Enum.map(&Enum.at(&1, 1)) |> Enum.min(),
      inside_parent: Enum.all?(vertices, &inside?(&1, frame)),
      trial_aperture: %{
        id: "shared-face:trial-plane-#{ordinal}",
        center: center,
        normal: [1, 0, 0]
      }
    }
  end

  defp through_trial_plane?(source, translate, center) do
    [entrance, next | _] = source.points
    previous = Enum.at(source.points, -2)
    normal = [1, 0, 0]
    side = fn point -> M.dot(M.sub(translate.(point), center), normal) end
    translate.(entrance) == center and side.(previous) < 0 and side.(next) > 0
  end

  defp inside?(point, frame) do
    Enum.zip([point, frame.minimum, frame.maximum])
    |> Enum.all?(fn {p, lo, hi} -> lo <= p and p <= hi end)
  end

  defp handoff(a, b) do
    outgoing_face = face(a, Enum.at(a.maximum, 2))
    incoming_face = face(b, Enum.at(b.origin, 2))
    tangent_dot = M.dot(a.tangent, b.tangent)

    %{
      ids: [a.id, b.id],
      point_match: List.last(a.bearing) == hd(b.bearing),
      shared_face: outgoing_face,
      face_match: outgoing_face == incoming_face,
      face_area:
        M.distance(Enum.at(outgoing_face, 0), Enum.at(outgoing_face, 1)) *
          M.distance(Enum.at(outgoing_face, 0), Enum.at(outgoing_face, 2)),
      face_normals: [[0, 0, 1], [0, 0, -1]],
      tangent_match: a.tangent == b.tangent,
      tangent_dot: tangent_dot,
      turn_degrees: :math.acos(tangent_dot) * 180 / :math.pi(),
      normal_match: a.normal == b.normal,
      normal_dot: M.dot(a.normal, b.normal),
      material_boundary_match: Enum.sort(a.end_boundary) == Enum.sort(b.start_boundary),
      bearing_stock_overlap: M.collision?(a.solid, b.solid)
    }
  end

  defp face(%{origin: [x0, y0, _], maximum: [x1, y1, _]}, z) do
    for x <- [x0, x1], y <- [y0, y1], do: [x, y, z]
  end

  defp boundary(center, across, normal) do
    for {w, t} <- [{-0.08, -0.02}, {0.08, -0.02}, {0.08, 0.02}, {-0.08, 0.02}],
        do: M.add(center, M.add(M.scale(across, w), M.scale(normal, t)))
  end

  defp solid(start_boundary, end_boundary) do
    vertices = start_boundary ++ end_boundary

    faces =
      for indices <- [
            [0, 3, 2, 1],
            [4, 5, 6, 7],
            [0, 1, 5, 4],
            [1, 2, 6, 5],
            [2, 3, 7, 6],
            [3, 0, 4, 7]
          ],
          do: Enum.map(indices, &Enum.at(vertices, &1))

    %{vertices: vertices, faces: faces}
  end

  def edges(%{origin: origin, maximum: maximum}) do
    corners =
      for x <- [hd(origin), hd(maximum)],
          y <- [Enum.at(origin, 1), Enum.at(maximum, 1)],
          z <- [List.last(origin), List.last(maximum)],
          do: [x, y, z]

    for {a, i} <- Enum.with_index(corners),
        {b, j} <- Enum.with_index(corners),
        i < j,
        Enum.count(Enum.zip(a, b), fn {u, v} -> u != v end) == 1,
        do: [a, b]
  end

  def project(points, view) do
    Enum.map_join(points, " ", fn [x, y, z] ->
      case view do
        "transverse" -> "#{35 + 45 * z},#{250 - 43 * y}"
        _ -> "#{45 + 54 * x + 20 * z},#{250 - 54 * y - 13 * z}"
      end
    end)
  end
end
