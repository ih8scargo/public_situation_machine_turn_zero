defmodule PublicSituationMachineTurnZero.Workshop.CommonMaterialRegistration do
  @moduledoc "Read-only paired material registration candidate. Never furnishes or acquires standing."
  alias PublicSituationMachineTurnZero.Architecture.CrossingRehearsal

  def model(state, geometry) do
    diagonal = hd(geometry.emergence.diagonals.flat)
    [a, b] = diagonal.points
    midpoint = mid(a, b)
    [upper_right, upper_left, lower_left, lower_right] = geometry.near_monitor.flat.plane.points
    extent = [mid(upper_left, lower_left), mid(upper_right, lower_right)]

    [xt_a, xt_b] =
      Enum.find(geometry.emergence.presentation.lines, &(&1.id == "XT-TO-XT-zero-to-one")).points

    material = geometry.near_monitor.flat.material
    ground = CrossingRehearsal.operating_reference()["ground"]

    %{
      version: "common-material-registration-v1",
      frame: "Snail inspection frame; common physical transform UNREGISTERED",
      source:
        if(material,
          do: %{
            material: material,
            turn: geometry.near_monitor.flat.turn,
            ancestry: state["tool_ancestry"],
            grapheme_count: String.length(material["text"]),
            role: "existing monitor-stage registration; no new String"
          }
        ),
      diagonal: %{
        id: diagonal.id,
        endpoints: [a, b],
        midpoint: midpoint,
        length_model_units: distance(a, b),
        status: "IMPLEMENTED WITNESS",
        constitutional_standing: "UNREGISTERED"
      },
      eye: geometry.emergence.registration.revised_eye,
      eye_registration:
        "IMPLEMENTED WITNESS of a provisional inspection eye; physical seated registration UNREGISTERED",
      incoming: %{
        from: midpoint,
        toward: geometry.emergence.registration.revised_eye,
        status: "GEOMETRIC HYPOTHESIS",
        meaning: "midpoint-to-eye bearing; no material transport"
      },
      xt: %{
        id: "XT-TO-XT-zero-to-one",
        endpoints: [xt_a, xt_b],
        from: xt_a,
        toward: xt_b,
        length_model_units: distance(xt_a, xt_b),
        status: "IMPLEMENTED WITNESS"
      },
      mapping: %{
        id: "midpoint-transverse-candidate",
        status: "GEOMETRIC HYPOTHESIS",
        endpoints: extent,
        span_model_units: distance(hd(extent), List.last(extent)),
        parameter_meaning: "normalized display address, not furnishing chronology",
        midpoint: midpoint,
        parameter: [0, 1],
        anchor_parameter: 0.5,
        formula: "Q(t) = A + t(B - A); Q(1/2) = diagonal midpoint",
        extent_source:
          "monitor left/right edge midpoints; trial display span, not a physical YT measure",
        physical_transform: nil,
        yt_metric: nil,
        physical_status: "UNREGISTERED — a midpoint anchors the extent; it is not the extent"
      },
      samples: if(material, do: samples(material, extent), else: []),
      registration: %{
        ground: %{
          status: "UNREGISTERED",
          source_frame: "ground-monitor-head-v1",
          source: ground,
          up: [0, 1, 0],
          to_snail: nil,
          meaning: "independent Ground; HERE Y=0 and old Table Y=-0.1 do not define it"
        },
        here: %{
          status: "CONFIRMED CANON",
          extents: [6, 6, 6],
          source: "SnailBody.fixed.here",
          points: geometry.fixed.here,
          center: [0, 0, 0],
          planar_reference_to_here: geometry.emergence.registration.reference_to_here,
          volumetric_transform: nil
        },
        next: %{
          status: "CONFIRMED CANON",
          source: geometry.landinging_registration.next,
          frame_motion: false,
          upper_from_ground: 6,
          upper_boundary: nil,
          floor: nil,
          center_to_ground: nil,
          horizontal_separation: nil
        },
        upper_check: upper_boundary_check(nil, [0, 1, 0], nil, nil),
        issuing_post: %{
          status: "CONFIRMED CANON",
          extents: 6,
          endpoints: nil,
          world_transform: nil,
          implementation: "UNREGISTERED; no spindle/helix/diagonal substitution"
        },
        source_transform: %{
          status: "IMPLEMENTED WITNESS",
          matrix: identity(),
          meaning: "both views project exactly the same Snail-frame Q(t) points"
        }
      },
      sequence:
        Enum.map(["STAND UP", "STAND DOWN", "STAND UP UPON"], fn name ->
          %{
            name: name,
            status: "UNREGISTERED",
            meaning: "required furnishing order; no physical transition performed"
          }
        end),
      inheritance_hypothesis: [
        "Successive triangular standings alternate through DOWN folding.",
        "Each DOWN fold follows the newly inherited YT TO YT line.",
        "YT TO YT measures Craft UP OVER relative to preceding XT TO XT roadway.",
        "Apparent posts belong to one XT reference line, curved between local RE-ZIPPERINGS.",
        "Joining Regarding triangles accommodate curvature; local squares and triangles remain flat."
      ],
      limits:
        "No physical YT extent, canonical diagonal standing, Ground transform or issuing-post correspondence is furnished. No acquisition or completed UN-FOLDING/PITTONING/RE-STEP."
    }
  end

  @doc "Check signed UP distance in a registered frame; never infer a center, floor or horizontal separation."
  def upper_boundary_check(nil, _, _, _), do: %{status: "UNREGISTERED", residual: nil}
  def upper_boundary_check(_, _, nil, _), do: %{status: "UNREGISTERED", residual: nil}
  def upper_boundary_check(_, _, _, nil), do: %{status: "UNREGISTERED", residual: nil}

  def upper_boundary_check(ground, up, boundary, unit) when unit > 0 do
    norm = :math.sqrt(Enum.sum(Enum.map(up, &(&1 * &1))))

    if norm < 1.0e-12 do
      %{status: "UNREGISTERED", residual: nil}
    else
      height =
        Enum.zip_with(boundary, ground, &(&1 - &2))
        |> Enum.zip_with(up, &(&1 * &2 / norm / unit))
        |> Enum.sum()

      residual = height - 6

      %{
        status: if(abs(residual) < 1.0e-9, do: "CONSISTENT", else: "INCONSISTENT"),
        residual: residual,
        height_extents: height
      }
    end
  end

  defp samples(material, [a, b]) do
    letters = String.graphemes(material["text"])
    count = length(letters)

    letters
    |> Enum.with_index()
    |> then(fn indexed ->
      if count > 80, do: Enum.take(indexed, 40) ++ Enum.take(indexed, -40), else: indexed
    end)
    |> Enum.map(fn {text, i} ->
      t = (i + 0.5) / max(count, 1)

      %{
        material: material["id"],
        index: i,
        text: text,
        t: t,
        point: Enum.zip_with(a, b, fn x, y -> x + t * (y - x) end)
      }
    end)
  end

  defp distance(a, b),
    do: :math.sqrt(Enum.zip_with(a, b, fn x, y -> (y - x) * (y - x) end) |> Enum.sum())

  defp mid(a, b), do: Enum.zip_with(a, b, &((&1 + &2) / 2))
  defp identity, do: [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
end
