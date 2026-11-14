defmodule PublicSituationMachineTurnZero.Workshop.HereWedging do
  @moduledoc "HERE wedging/SIX registration trials. See docs/architecture/geometry/here-wedging-snail-six.md."
  alias PublicSituationMachineTurnZero.Workshop.{MaterialRibbon, SnailBody, ComingAboardMachine}
  alias MaterialRibbon, as: M

  def model do
    unit = [[3, 0, -4], [3, 1, -4]]
    seat = [3, 1, -3]

    wedge =
      M.prism("here-unit-wedging", unit ++ [seat], 0.04)
      |> Map.merge(%{
        material_id: "here:wedging-specimen",
        source: "existing xt-to-xt-from-here + Seat ONE candidate incidence",
        width: 1,
        hinge: %{endpoints: unit, ordering: "ZERO TOWARD ONE"}
      })

    arc = SnailBody.reference_arc()
    six = List.last(arc.purchases)
    target = [3, 6, 3]
    offset = M.sub(target, ComingAboardMachine.snail_point(six.point))
    transform = fn p -> M.add(ComingAboardMachine.snail_point(p), offset) end

    sections =
      for i <- 0..24 do
        f = SnailBody.arc_frame(i / 24)

        for {w, t} <- [{-0.04, -0.01}, {0.04, -0.01}, {0.04, 0.01}, {-0.04, 0.01}],
            do: transform.(M.add(f.point, M.add(M.scale(f.radial, w), M.scale(f.binormal, t))))
      end

    faces =
      sections
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.flat_map(fn [a, b] ->
        vertices = a ++ b

        for ids <- [
              [0, 3, 2, 1],
              [4, 5, 6, 7],
              [0, 1, 5, 4],
              [1, 2, 6, 5],
              [2, 3, 7, 6],
              [3, 0, 4, 7]
            ],
            do: Enum.map(ids, &Enum.at(vertices, &1))
      end)

    points = Enum.map(arc.samples, &transform.(&1.point))
    {low, high} = points |> Enum.map(&Enum.at(&1, 1)) |> Enum.min_max()

    %{
      wedge: wedge,
      unit: %{id: "xt-to-xt-from-here", points: unit, length: 1},
      seat_point: seat,
      table: [3, 3, 0],
      seat_toward_table: [seat, [3, 3, 0]],
      pillar: [[3, 0, -4], [3, 6, -4]],
      inherited_return: MaterialRibbon.return_register(),
      current_measure: %{id: "current-turn:xt-toward-yt-measure", points: [[0, 6, 0], [6, 0, 0]]},
      return_trial: %{
        status: :blocked_missing_correspondence,
        previous_acquisition: :not_attested,
        inherited_frame: "steeling-xy-v1",
        current_frame: "exploration-six-v1",
        physical_transform: nil,
        current_return_line: :unappointed,
        intersection: :not_computable,
        occupied_wedge: nil
      },
      snail: %{
        id: "here-snail-registration",
        source: arc.version,
        source_points: Enum.map(arc.samples, & &1.point),
        points: points,
        faces: faces,
        scale: 6 / 1.4,
        offset: offset,
        unit: "source units scaled by existing common-machine extent registration",
        sixth_purchase: %{
          source: six.point,
          t: 5 / 6,
          target: target,
          status: :candidate_anchor_not_mechanical_seam
        },
        height_range: [low, high],
        fits_six_height: low >= 0 and high <= 6,
        source_relation: "one complete Tuple Ship scale retained; no Public Field enlargement",
        occupied_carrier: :candidate
      },
      seam: %{
        relation: "HERE wedging THROUGH WITH Snail House BY WAY OF Segmentationing SIX",
        status: :required_relationship_unproved_join,
        points: [seat, target],
        occupied_join: nil
      },
      index: 0
    }
  end

  def project(points, side) do
    Enum.map_join(points, " ", fn [x, y, z] ->
      u = 100 + (0.8 * x - 0.6 * z) * 32
      "#{if(side == "right", do: 480 - u, else: u)},#{330 - (0.3 * x + y + 0.4 * z) * 30}"
    end)
  end
end
