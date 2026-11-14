defmodule PublicSituationMachineTurnZero.Workshop.Steeling do
  # Geometry reconciliation: N18/U13 are permanent source registrations; never relocate them to fit the revised motor frame.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc "Provisional planar JANUSITE STEELING hypothesis. Indices, coordinates and carriage intervals are distinct."
  @defaults %{"approach_bend" => 3.0, "n_heading" => 135.0, "machine_reach" => 6.0}
  @bounds %{"approach_bend" => {1, 6}, "n_heading" => {105, 165}, "machine_reach" => {3, 8}}
  @parameters [
    {"approach_bend", "THE/PUBLIC control height", "extents", 1, 6},
    {"n_heading", "N outgoing heading from +X toward +Y", "degrees", 105, 165},
    {"machine_reach", "N → MACHINE staging reach", "extents", 3, 8}
  ]
  def defaults, do: @defaults
  def parameters, do: @parameters

  def valid?(p) when is_map(p) do
    Enum.sort(Map.keys(p)) == Enum.sort(Map.keys(@defaults)) and
      Enum.all?(@bounds, fn {key, {low, high}} ->
        is_number(p[key]) and p[key] >= low and p[key] <= high
      end)
  end

  def valid?(_), do: false

  def model(p) do
    # JSON consumers may serialize 3.0 as 3; keep identical floating-point arithmetic.
    p = Map.new(p, fn {key, value} -> {key, value * 1.0} end)

    controls = [[0, 0, 0], [1, p["approach_bend"], 0], [6, 6, 0], [9, 6, 0]]
    # Stations sample explicit, unequal parameters. Letter count is not spatial extent.
    approach_stations =
      Enum.map([0, 0.04, 0.12, 0.23, 0.36, 0.53, 0.69, 0.87, 1], &bezier(controls, &1))

    situation = [
      [10, 5.5, 0],
      [11.25, 5, 0],
      [13, 4, 0],
      [15, 3, 0],
      [16.2, 2.5, 0],
      [16.8, 1.8, 0],
      [17.4, 0.9, 0],
      [17.7, 0.4, 0],
      [18, 0, 0]
    ]

    n = List.last(situation)
    angle = p["n_heading"] * :math.pi() / 180
    direction = [:math.cos(angle), :math.sin(angle), 0]
    fractions = [0.06, 0.15, 0.26, 0.4, 0.58, 0.79, 1]
    machine = Enum.map(fractions, &along(n, direction, &1 * p["machine_reach"]))
    points = approach_stations ++ situation ++ machine

    words =
      Enum.flat_map([{"THE", 1}, {"PUBLIC", 4}, {"SITUATION", 10}, {"MACHINE", 19}], fn {word,
                                                                                         first} ->
        for {letter, i} <- Enum.with_index(String.graphemes(word)), do: {letter, word, first + i}
      end)

    stations =
      Enum.zip_with(words, points, fn {letter, group, index}, point ->
        refs =
          cond do
            index == 13 -> ["u-projection-return", "u-post-reference", "central-upper-aperture"]
            index == 18 -> ["n-ground-return", "machine-from-n"]
            index >= 19 -> ["machine-from-n", "n-ground-return"]
            index <= 9 -> ["the-public-curve"]
            group in ["PUBLIC", "SITUATION"] -> ["gallery-plane"]
            true -> ["the-public-curve"]
          end

        %{
          "id" => "steeling-letter-#{index}",
          "index" => index,
          "letter" => letter,
          "group" => group,
          "point" => point,
          "references" =>
            Enum.uniq(
              refs ++ if(group in ["PUBLIC", "SITUATION"], do: ["gallery-plane"], else: [])
            )
        }
      end)

    u = Enum.at(points, 12)
    return_end = along(n, direction, p["machine_reach"])

    %{
      "id" => "janusite-steeling",
      "version" => 1,
      "status" => "provisional structural hypothesis; not constitutional curvature",
      "parameters" => p,
      "stations" => stations,
      "segmentation" => [3, 6, 9, 7],
      "reference_origin" => [0, 0, 0],
      "the_public" => %{
        "id" => "the-public-curve",
        "representation" => "cubic Bezier",
        "control_points" => controls,
        "samples" => Enum.map(0..48, &bezier(controls, &1 / 48))
      },
      "situation" => %{
        "representation" => "registered polyline",
        "points" => [List.last(approach_stations) | situation]
      },
      "gallery" => %{
        "id" => "gallery-plane",
        "origin" => [0, 0, 0],
        "normal" => [0, 0, 1],
        "boundary" => [
          [Enum.at(approach_stations, 3) |> hd(), 0, 0],
          [18, 0, 0],
          [18, 6, 0],
          [Enum.at(approach_stations, 3) |> hd(), 6, 0]
        ],
        "members" => Enum.map(4..18, &"steeling-letter-#{&1}"),
        "status" => "XY planar transverse presentation hypothesis; no final members or joints"
      },
      "u_return" => %{
        "id" => "u-projection-return",
        "station" => "steeling-letter-13",
        "point" => u,
        "role" => "Projectioning center return",
        "post" => %{
          "id" => "u-post-reference",
          "points" => [[15, 0, 0], [15, 6, 0]],
          "status" => "provisional reference, not a mechanical post"
        },
        "upper_aperture" => %{
          "id" => "central-upper-aperture",
          "toward_reference" => [15, 6, 0],
          "frame" => nil,
          "dimensions" => nil,
          "status" => "reserved; reference endpoint does not appoint aperture geometry"
        }
      },
      "n_return" => %{
        "id" => "n-ground-return",
        "station" => "steeling-letter-18",
        "point" => n,
        "role" => "Ground reference sharp return TOWARD center / MACHINE approach",
        "incoming" => [1, 0, 0],
        "situation_incoming" => Enum.zip_with(n, Enum.at(situation, -2), &(&1 - &2)),
        "outgoing" => direction,
        "heading_degrees" => p["n_heading"],
        "points" => [[0, 0, 0], n, return_end]
      },
      "machine" => %{
        "id" => "machine-from-n",
        "inherited_from" => "n-ground-return",
        "origin" => n,
        "direction" => direction,
        "representation" => "straight staging hypothesis",
        "points" => [n | machine]
      },
      "attachments" => [
        %{
          "subject" => "n-ground-return",
          "relation" => "REFERENCE FOR",
          "object" => "lower-surface-y-min",
          "status" =>
            "unresolved attachment: indexed N return at Y=0 versus lower Ground-side at Y=-6; no connecting member invented"
        },
        %{
          "subject" => "u-projection-return",
          "relation" => "REFERENCED WITHIN",
          "object" => "central",
          "status" => "provisional spatial registration; not a joint"
        },
        %{
          "subject" => "u-post-reference",
          "relation" => "TOWARD",
          "object" => "central-upper-aperture",
          "status" => "reserved attachment"
        }
      ],
      "future_descent" => %{
        "status" => "reserved only",
        "direction" => "counterclockwise",
        "initial_winding_count" => 1,
        "winding_count_adjustment" => "reserved",
        "quadrants_degrees" => [0, 90, 180, 270],
        "stands" =>
          Enum.map(
            ["tc", "ch", "central", "lower"],
            &%{"id" => "candidate-stand-#{&1}", "region" => &1, "frame" => nil}
          ),
        "camera_a" => %{
          "id" => "future-camera-a",
          "toward" => "u-post-reference / Fieldside",
          "frame" => nil
        },
        "camera_b" => %{
          "id" => "future-camera-b",
          "relation" => "OVER ACROSS; reciprocal with A",
          "frame" => nil
        }
      },
      "unresolved" =>
        "Course lies in XY at Z=0. CUBICAL frames do not deform with it. No final connections, load paths, aperture dimensions or THE/PUBLIC corner angle are appointed."
    }
  end

  defp along(origin, direction, amount), do: Enum.zip_with(origin, direction, &(&1 + &2 * amount))

  defp bezier([a, b, c, d], t) do
    u = 1 - t

    for axis <- 0..2,
        do:
          :math.pow(u, 3) * Enum.at(a, axis) + 3 * u * u * t * Enum.at(b, axis) +
            3 * u * t * t * Enum.at(c, axis) + t * t * t * Enum.at(d, axis)
  end
end
