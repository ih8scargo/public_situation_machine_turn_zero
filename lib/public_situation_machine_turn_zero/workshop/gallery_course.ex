defmodule PublicSituationMachineTurnZero.Workshop.GalleryCourse do
  @moduledoc "Versioned prospective material course; shared finite sections, no acquired Footing."
  alias PublicSituationMachineTurnZero.Workshop.{CoBuildingGeometry, MaterialRibbon}
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  def model do
    entrance = [1.4, -0.35, -3]

    under =
      for i <- 0..16 do
        a = i * :math.pi() / 16
        [3, 0.15 - 0.5 * :math.cos(a), -3 - 0.6 * :math.sin(a)]
      end

    gallery = [3, 2.4, -1.015]
    upper = [4.2, 3.6, -1.015]

    loop =
      for i <- 0..24 do
        a = i * 2 * :math.pi() / 24
        [4.2 + 0.3 * :math.sin(a), 3.6, -1.315 + 0.3 * :math.cos(a)]
      end

    # Exact repeated endpoint gives the loop one source seam.
    loop = List.replace_at(loop, -1, hd(loop))

    ring =
      for i <- 0..32 do
        a = i * 2 * :math.pi() / 32
        [3 + 1.3 * :math.sin(a), 3.6, -3 + 1.3 * :math.cos(a)]
      end

    ring = List.replace_at(ring, -1, hd(ring))
    pin = [[6.5, 4, -2], [7.5, 4, -2]]

    segments = [
      %{
        id: "under-curve",
        label: "Groundward wedge · FROM DOWN UNDER beneath Seat",
        points: [entrance | under],
        yellow: [:lower_xt_join, :under_seat_fold]
      },
      %{
        id: "gallery-through",
        label: "THROUGH Gallery Door · staging for standing",
        points: [List.last(under), [3, 1.5, -1.015], gallery],
        yellow: [:gallery_membrane_exchange, :door_motion_feed]
      },
      %{
        id: "gallery-departure",
        label: "Gallery departure · UP OVER 45°",
        points: [gallery, upper],
        yellow: [:departure_attachment]
      },
      %{
        id: "upper-loop",
        label: "Upper XT TOWARD YT loop · OVER ACROSS",
        points: loop,
        yellow: [:loop_attachment, :transverse_pinning, :finite_fold]
      },
      %{
        id: "around-course",
        label: "AROUND ABOUT Seat · reciprocal return TOWARD next PINNING",
        points:
          [upper, hd(ring)] ++
            tl(ring) ++
            [[1.5, 3.6, -3], [1.5, 0.6, -6], [1.5, 0.12, -5.52], [5.5, 3, -4], hd(pin)],
        yellow: [:reciprocal_twist, :return_clearance, :connector_fold]
      }
    ]

    {points, ranges} =
      Enum.reduce(segments, {[], []}, fn seg, {ps, rs} ->
        first = max(length(ps) - 1, 0)
        addition = if ps == [], do: seg.points, else: tl(seg.points)
        {ps ++ addition, rs ++ [Map.merge(seg, %{first: first, count: length(seg.points) - 1})]}
      end)

    mesh = G.sweep(points, 0.18, 0.02)

    sections =
      Enum.map(ranges, fn seg ->
        cells = Enum.slice(mesh.cells, seg.first, seg.count)
        geometry = G.mesh(Enum.flat_map(cells, & &1.faces))

        geometry =
          Map.merge(geometry, %{
            cells: cells,
            sections: Enum.slice(mesh.sections, seg.first, seg.count + 1)
          })

        Map.put(seg, :geometry, geometry)
      end)

    %{
      id: "gallery-course:1",
      version: "gallery-course-v1",
      points: points,
      geometry: mesh,
      segments: sections,
      pin: pin,
      pin_center: [7, 4, -2],
      departure: [gallery, upper],
      upper_loop: %{
        center: [4.2, 3.6, -1.315],
        radius: 0.3,
        samples: 24,
        plane_normal: [0, 1, 0],
        tangent_at_entry: [1, 0, 0],
        transverse_reference: [0, 0, 1],
        attachment: :yellow
      },
      undercurve: %{
        center: [3, 0.15, -3],
        radii_yz: [0.5, 0.6],
        plane_normal: [1, 0, 0],
        points: under
      },
      provenance: %{
        entrance: "lower-left XT TO XT",
        inherited: "geometry-table-2026-11-15.v7",
        acquired_receipt: nil
      },
      endpoint_gap: M.distance(List.last(points), hd(pin)),
      actual_join: false
    }
  end
end
