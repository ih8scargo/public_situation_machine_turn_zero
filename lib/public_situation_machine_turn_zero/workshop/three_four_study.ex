defmodule PublicSituationMachineTurnZero.Workshop.ThreeFourStudy do
  @moduledoc "Prospective THREE–FOUR material and offset incidence experiment. No passage or acquisition authority."
  alias PublicSituationMachineTurnZero.Workshop.{CoBuildingGeometry, MaterialRibbon}
  alias CoBuildingGeometry, as: G
  alias MaterialRibbon, as: M

  def arc_point(degrees) do
    a = degrees * :math.pi() / 180
    [3 + 1.3 * :math.sin(a), 3.6, -3 + 1.3 * :math.cos(a)]
  end

  # Parameter is measured from +Z, increasing toward +X, with the inherited circuit origin retained.
  def parameter([x, _, z]) do
    a = :math.atan2(x - 3, z + 3) * 180 / :math.pi()
    if a < 0, do: a + 360, else: a
  end

  def model(bend, appointment?, projection?, cursor) do
    ceiling = [4.3, 4, -3]
    tunnel = [1.7, 3, -3]

    references =
      [
        %{
          id: "prospective-ceiling",
          label: "Prospective next ceiling · offset reference",
          point: ceiling,
          source: "next flat PINNING Y=4; candidate arc incidence at 90 degrees",
          physical_incidence: :yellow
        },
        %{
          id: "current-tunnel",
          label: "Current Tunnel · offset reference (incidence unappointed)",
          point: tunnel,
          source: "current THREE Y=3; candidate arc incidence at 270 degrees",
          physical_incidence: :yellow
        }
      ]
      |> Enum.map(fn ref ->
        Map.merge(ref, %{
          parameter: parameter(ref.point),
          arc_point: arc_point(parameter(ref.point)),
          radial_incidence: :candidate_projection_only
        })
      end)

    encounters =
      references
      |> Enum.sort_by(& &1.parameter)
      |> Enum.map(fn ref ->
        %{
          reference: ref.id,
          parameter_degrees: ref.parameter,
          point: ref.arc_point,
          reference_gap: M.distance(ref.point, ref.arc_point),
          scope: :reference_encounter_only,
          reached: cursor >= ref.parameter,
          actual_cob_traversaling: false,
          passage: :unproved
        }
      end)

    points =
      for i <- 0..24 do
        t = i / 24
        a = (270 + 180 * t) * :math.pi() / 180
        radius = 1.3 + 0.3 * bend * :math.sin(:math.pi() * t)
        [3 + radius * :math.sin(a), 3 + t, -3 + radius * :math.cos(a)]
      end

    points = points |> List.replace_at(0, tunnel) |> List.replace_at(-1, ceiling)
    material = G.sweep(points, 0.16, 0.02)
    projected = G.transform(material, fn [x, y, _z] -> [x, y, -1.04] end)

    %{
      id: "three-four-offset:1",
      algorithm: "three-four-offset-v1",
      working_band_y: [3, 4],
      reserved_for: :human_fashioning_and_refashioning,
      bend: bend,
      material: material,
      points: points,
      projection: %{
        enabled: projection?,
        display_mesh: projected,
        matrix: [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, -1.04], [0, 0, 0, 1]],
        scope: :projection_only
      },
      references: references,
      reference_arc: for(i <- 0..64, do: arc_point(i * 360 / 64)),
      offset: %{
        from: "current-tunnel",
        toward: "prospective-ceiling",
        vector: M.sub(ceiling, tunnel),
        parameter_separation_degrees: parameter(tunnel) - parameter(ceiling),
        registration: :candidate_not_physical_correspondence
      },
      circuit: %{
        origin_degrees: 0,
        direction: :increasing_toward_positive_x,
        cursor_degrees: cursor,
        events: encounters,
        ceiling_before_tunnel: hd(encounters).reference == "prospective-ceiling",
        actual_cob_traversaling: false,
        acquired_turns: 0
      },
      appointment: %{
        status: if(appointment?, do: :proposed, else: :unappointed),
        subject: "three-four-offset:1",
        relation: "TOWARD conditional passage",
        object: "current-tunnel",
        opening_condition: :yellow,
        closing_condition: :yellow,
        accepted: false,
        lawful_passage: false
      },
      physical_join: false,
      actual_next_footing: nil,
      completed_re_step: false,
      yellow: [
        :ceiling_incidence,
        :tunnel_incidence,
        :reference_arc_mount,
        :finite_fold,
        :occupied_clearance,
        :conditional_passage
      ]
    }
  end
end
