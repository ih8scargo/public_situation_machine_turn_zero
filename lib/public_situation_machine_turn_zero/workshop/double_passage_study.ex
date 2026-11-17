defmodule PublicSituationMachineTurnZero.Workshop.DoublePassageStudy do
  @moduledoc "Finite prospective double passage. Incidence is measured; four-point furnishing is not inferred."
  alias PublicSituationMachineTurnZero.Workshop.{CoBuildingGeometry, MaterialRibbon}
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  def door do
    %{
      id: "gallery-door:1",
      part: "cb:slate",
      plane_z: -1.035,
      x: [2.1, 3.9],
      y: [1.65, 3.15],
      frame_points: [
        [2.1, 1.65, -1.035],
        [3.9, 1.65, -1.035],
        [3.9, 3.15, -1.035],
        [2.1, 3.15, -1.035],
        [2.1, 1.65, -1.035]
      ]
    }
  end

  def model do
    door = door()

    ring =
      for i <- 0..32 do
        a = i * 2 * :math.pi() / 32
        [3 + 1.3 * :math.sin(a), 3.6, -3 + 1.3 * :math.cos(a)]
      end

    ring = List.replace_at(ring, -1, hd(ring))

    segments = [
      %{
        id: "double-outward",
        office: "BY WAY OF Gallery THROUGH INTO Situationing Stage TOWARD STANDING FOR STAGING",
        points: [
          [2.45, 2.65, -1.7],
          [2.45, 2.65, -0.55],
          [3.65, 3.85, -0.55],
          [4.4, 3.85, -0.55],
          [4.4, 3.85, -1.7],
          hd(ring)
        ]
      },
      %{
        id: "double-around",
        office: "AROUND ABOUT Seat; prospective STAGING FOR STANDING material",
        points: ring
      },
      %{
        id: "double-return",
        office: "FROM STAGING FOR STANDING TOWARD STANDING FOR STAGING; THROUGH SAME Gallery",
        points: [
          List.last(ring),
          [4.6, 3.4, -1.7],
          [4.6, 3.4, -0.55],
          [3.55, 1.95, -0.55],
          [3.55, 1.95, -1.7]
        ]
      }
    ]

    {points, ranges} =
      Enum.reduce(segments, {[], []}, fn seg, {ps, rs} ->
        first = max(length(ps) - 1, 0)

        {ps ++ if(ps == [], do: seg.points, else: tl(seg.points)),
         rs ++ [Map.merge(seg, %{first: first, count: length(seg.points) - 1})]}
      end)

    mesh = G.sweep(points, 0.10, 0.02)

    sections =
      Enum.map(ranges, fn seg ->
        cells = Enum.slice(mesh.cells, seg.first, seg.count)

        geometry =
          G.mesh(Enum.flat_map(cells, & &1.faces))
          |> Map.merge(%{
            cells: cells,
            sections: Enum.slice(mesh.sections, seg.first, seg.count + 1)
          })

        Map.merge(seg, %{
          geometry: geometry,
          course_id: "yt-double-passage-string:trial-1",
          door_id: door.id
        })
      end)

    incidence =
      Enum.map(sections, fn seg ->
        hits = plane_incidence(seg.geometry, door.plane_z)
        inside = Enum.filter(hits, &inside_opening?(&1, door))

        %{
          source: seg.id,
          door_id: door.id,
          plane_z: door.plane_z,
          inside_opening: inside,
          outside_opening: hits -- inside,
          interpretation: :measured_stock_boundary_not_appointed_contact
        }
      end)

    measured = incidence |> Enum.flat_map(& &1.inside_opening) |> unique_points()
    # A finite central corridor, not just a projected empty pixel or a single sight ray.
    corridor = G.box([2.82, 2.22, -12], [3.18, 2.58, 12])

    %{
      id: "yt-double-passage-string:trial-1",
      algorithm: "double-passage-v1",
      scope: :prospective_material_rehearsal,
      door: door,
      points: points,
      geometry: mesh,
      segments: sections,
      width: 0.10,
      thickness: 0.02,
      incidence: incidence,
      quadranglementing: %{
        status: :yellow,
        measured_boundary_points: measured,
        measured_count: length(measured),
        required_four_point_incidence: :unproved,
        appointed_four_points: nil,
        inaugural_to_recurring_relation: :yellow
      },
      sightline: %{
        corridor: corridor,
        course_interference: G.collision?(mesh, corridor),
        central_ray_hit: G.ray([3, 2.4, -12], [0, 0, 1], mesh.faces),
        scope: :new_course_in_central_gallery_corridor,
        whole_apparatus_optics: :yellow
      },
      relation: %{
        string_source: "prospective Human-furnished YT String; no detected Groundward object",
        final_semantical_appointment: :unappointed,
        outward_office: "STANDING FOR STAGING",
        return_from: "STAGING FOR STANDING",
        return_toward: "STANDING FOR STAGING"
      },
      lifecycle: %{
        return_passage: :prospective,
        subsequent_twist: :yellow_unfurnished,
        flat_pinning: "cb:next-fold",
        pittoning_conversion: :unperformed,
        acquired_next_footing: nil,
        completed_re_step: false
      },
      yellow: [
        :four_point_incidence,
        :passage_incidence,
        :material_clearance,
        :physical_joins,
        :inaugural_to_recurring_quadranglementing
      ]
    }
  end

  def inside_opening?([x, y, _], door),
    do: x > hd(door.x) and x < List.last(door.x) and y > hd(door.y) and y < List.last(door.y)

  def plane_incidence(mesh, z) do
    mesh.faces
    |> Enum.flat_map(fn face ->
      Enum.chunk_every(face ++ [hd(face)], 2, 1, :discard)
      |> Enum.flat_map(fn [[x, y, a], [u, v, b]] ->
        cond do
          abs(a - z) < 1.0e-9 and abs(b - z) < 1.0e-9 ->
            [[x, y, z], [u, v, z]]

          abs(a - b) < 1.0e-12 ->
            []

          (a - z) * (b - z) > 0 ->
            []

          true ->
            t = (z - a) / (b - a)
            [[x + t * (u - x), y + t * (v - y), z]]
        end
      end)
    end)
    |> unique_points()
  end

  defp unique_points(points),
    do:
      Enum.reduce(points, [], fn p, ps ->
        if Enum.any?(ps, &(M.distance(&1, p) < 1.0e-8)), do: ps, else: ps ++ [p]
      end)
end
