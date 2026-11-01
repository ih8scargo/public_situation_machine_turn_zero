defmodule PublicSituationMachineTurnZero.Architecture.ProjectionBody do
  @moduledoc "Versioned provisional three-square/three-circle correspondence. Rehearsal is not calibration or a new turn."
  alias PublicSituationMachineTurnZero.Architecture, as: A

  @planes [
    {"xy", [1, 0, 0], [0, 1, 0], [0, 0, 1]},
    {"xz", [1, 0, 0], [0, 0, 1], [0, 1, 0]},
    {"yz", [0, 1, 0], [0, 0, 1], [1, 0, 0]}
  ]

  def seed do
    %{
      "version" => "paired-sections-v1",
      "course" => %{
        "version" => "paired-xz-tunnel-v1",
        "radius_fraction" => 0.65,
        "tube_radius" => 0.22,
        "sample_intervals" => 96
      },
      "status" => "PROVISIONAL — CH review required",
      "interpretation" =>
        "three paired normalized section frames; six resolutioning possibilities, not six turns",
      "planes" =>
        Enum.map(@planes, fn {id, u, v, normal} ->
          %{"id" => id, "u" => u, "v" => v, "normal" => normal}
        end)
    }
  end

  def model(m) do
    g = m.standing["opening_geometry"]
    cube = g["wireframe"] || %{"min" => [-1.2, -1.2, 0], "max" => [1.2, 1.2, 2.4]}
    globe = g["janusite"] || %{"center" => [0, 0, 1.6], "radii" => [3.7, 2.8, 3.2]}
    center = Enum.zip_with(cube["min"], cube["max"], &((&1 + &2) / 2))
    half = Enum.zip_with(cube["min"], cube["max"], &((&2 - &1) / 2))
    foundation = m.standing["projection_foundation"] || seed()

    extents =
      Enum.flat_map(foundation["planes"], fn plane ->
        u = plane["u"]
        v = plane["v"]

        square =
          Enum.map([{-1, -1}, {1, -1}, {1, 1}, {-1, 1}], fn {x, y} ->
            embed(add(scale(u, x), scale(v, y)), center, half)
          end)

        circle =
          for i <- 0..64 do
            a = i * :math.pi() / 32

            embed(
              add(scale(u, :math.cos(a)), scale(v, :math.sin(a))),
              globe["center"],
              globe["radii"]
            )
          end

        q = add(scale(u, 0.7), scale(v, 0.7))

        [
          %{
            "id" => "resolution-square-" <> plane["id"],
            "family" => "square",
            "plane" => plane["id"],
            "pair" => "resolution-circle-" <> plane["id"],
            "normal" => plane["normal"],
            "points" => square,
            "target" => embed(q, center, half),
            "source" => "opening-accomplished",
            "furnished" => A.opened?(m),
            "occupied" => false
          },
          %{
            "id" => "resolution-circle-" <> plane["id"],
            "family" => "circle",
            "plane" => plane["id"],
            "pair" => "resolution-square-" <> plane["id"],
            "normal" => plane["normal"],
            "points" => circle,
            "target" => embed(q, globe["center"], globe["radii"]),
            "source" => "janusite-extent-standing",
            "furnished" => A.puffed?(m),
            "occupied" => false
          }
        ]
      end)

    course =
      if A.complete?(m),
        do: tunnel(g["stick"], Enum.min(half), foundation["course"] || seed()["course"]),
        else: nil

    %{
      "version" => foundation["version"],
      "status" => foundation["status"],
      "foundation" => foundation,
      "ground" => %{
        "normal" => [0, 1, 0],
        "source" => "human-standing",
        "floor_source" => "opening-accomplished",
        "floor_furnished" => A.opened?(m)
      },
      "square_embedding" => %{"center" => center, "scale" => half},
      "circle_embedding" => globe,
      "extents" => extents,
      "floor" =>
        Enum.map([{0, 0}, {1, 0}, {1, 1}, {0, 1}], fn {x, z} ->
          [
            Enum.at(cube[if(x == 0, do: "min", else: "max")], 0),
            Enum.at(cube["min"], 1),
            Enum.at(cube[if(z == 0, do: "min", else: "max")], 2)
          ]
        end),
      "aperture" =>
        Map.merge(g["aperture"] || %{"center" => [0, 0, 0], "half_size" => 0.16}, %{
          "normal" => [0, 0, 1],
          "plane" => "xy",
          "furnished" => A.puffed?(m),
          "source" => "aperture-available"
        }),
      "tunnel" => course,
      "targets" =>
        Enum.map(extents, &Map.take(&1, ["id", "target", "family", "plane"])) ++
          [
            %{"id" => "aperture", "target" => [0, 0, 0]},
            %{
              "id" => "machine-floor",
              "target" => [0, Enum.at(cube["min"], 1), Enum.at(center, 2)]
            }
          ] ++
          [
            %{
              "id" => "tunnel-bend",
              "target" =>
                if(course,
                  do: Enum.at(course["samples"], div(length(course["samples"]) - 1, 2))["point"],
                  else: nil
                )
            }
          ]
    }
  end

  defp tunnel(stick, half, parameters) do
    forward = stick["direction"]
    [x, _, z] = forward
    right = unit([z, 0, -x])
    start = stick["cob_center"]
    radius = half * parameters["radius_fraction"]
    intervals = parameters["sample_intervals"]

    samples =
      for i <- 0..intervals do
        a = i * :math.pi() / intervals

        point =
          add(
            start,
            add(scale(forward, radius * :math.sin(a)), scale(right, radius * (1 - :math.cos(a))))
          )

        tangent = unit(add(scale(forward, :math.cos(a)), scale(right, :math.sin(a))))

        %{
          "id" => "tunnel-sample-#{i}",
          "progress" => i / intervals,
          "point" => point,
          "tangent" => tangent
        }
      end

    %{
      "id" => parameters["version"],
      "status" => "reversible affordmenting rehearsal",
      "source" => ["resolution-square-xz", "resolution-circle-xz", "pointingable-standing"],
      "frame" => %{
        "origin" => start,
        "circle_center" => add(start, scale(right, radius)),
        "normalized_inlet" => [-1, 0, 0],
        "forward" => forward,
        "right" => right,
        "scale" => radius
      },
      "radius" => radius,
      "tube_radius" => parameters["tube_radius"],
      "samples" => samples,
      "entrance" => hd(samples)["point"],
      "continuation" => List.last(samples)["point"],
      "markers" => [
        %{
          "id" => "test-in-stringing-a",
          "text" => "TEST A · staged",
          "course" => parameters["version"],
          "status" => "staged engineering fixture; not CH-authored accomplishment",
          "progress" => 0.2
        },
        %{
          "id" => "test-in-stringing-b",
          "text" => "TEST B · bend",
          "course" => parameters["version"],
          "status" => "staged engineering fixture; not CH-authored accomplishment",
          "progress" => 0.5
        },
        %{
          "id" => "test-in-stringing-c",
          "text" => "TEST C · retained",
          "course" => parameters["version"],
          "status" => "staged engineering fixture; not CH-authored accomplishment",
          "progress" => 0.8
        }
      ]
    }
  end

  defp embed(q, center, dimensions),
    do: Enum.zip_with(center, Enum.zip_with(q, dimensions, &(&1 * &2)), &(&1 + &2))

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp scale(a, n), do: Enum.map(a, &(&1 * n))
  defp unit(a), do: scale(a, 1 / :math.sqrt(Enum.reduce(a, 0, &(&2 + &1 * &1))))
end
