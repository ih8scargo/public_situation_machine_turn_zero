defmodule PublicSituationMachineTurnZero.Workshop.Projection do
  @moduledoc "Shared lower source and two affine presentation candidates. All coordinates are provisional workshop units."
  @defaults %{"oblique_x" => 1.0, "oblique_z" => 1.5}
  def defaults, do: @defaults

  def parameters,
    do: [{"oblique_x", "Oblique X offset", -1, 1}, {"oblique_z", "Oblique Z offset", -2, 2}]

  def valid?(p) when is_map(p),
    do:
      Enum.sort(Map.keys(p)) == Enum.sort(Map.keys(@defaults)) and
        Enum.all?(parameters(), fn {id, _, low, high} ->
          is_number(p[id]) and p[id] >= low and p[id] <= high
        end)

  def valid?(_), do: false
  def source_point(sequence) when sequence in 1..5, do: [12 + sequence, -3, 0]

  def model(p) do
    origin = [15, -3, 0]
    vertical = bearing("vertical", origin, [0, 6, 0])
    oblique = bearing("oblique", origin, [p["oblique_x"], 6, p["oblique_z"]])

    %{
      "version" => 1,
      "parameters" => p,
      "source" => %{
        "id" => "lower-staging-source",
        "region" => "lower",
        "origin" => origin,
        "outline" => [[12.5, -3, -0.5], [17.5, -3, -0.5], [17.5, -3, 0.5], [12.5, -3, 0.5]],
        "slots" =>
          Enum.map(
            1..5,
            &%{"id" => "lower-slot-#{&1}", "sequence" => &1, "point" => source_point(&1)}
          ),
        "meaning" => "Slots encode acquisition order, never adjacency of original letter stations"
      },
      "vertical" => vertical,
      "oblique" => oblique,
      "course" => %{
        "id" => "crossing-reference-course",
        "region" => "central",
        "points" => [[12.75, 3, 1.5], [17.25, 3, 1.5]],
        "length" => 4.5,
        "parameter" =>
          "t in [0,1]: 4.5*t extents along +X; constant Y=3, independent of letter count"
      },
      "height_reference" => %{
        "id" => "crossing-six-extent-height",
        "points" => [[18.5, 0, 2.5], [18.5, 6, 2.5]],
        "extents" => 6
      },
      "status" =>
        "Provisional affine projection candidates; not final elbow, Glass or operational Gallery curvature",
      "attachment" =>
        "Indexed station to lower slot is an explicit provisional provenance association, not a physical member or final joint"
    }
  end

  defp bearing(id, origin, offset) do
    norm = :math.sqrt(Enum.reduce(offset, 0, &(&1 * &1 + &2)))

    %{
      "id" => "#{id}-projection",
      "source" => "lower-staging-source",
      "origin" => origin,
      "direction" => Enum.map(offset, &(&1 / norm)),
      "entry" => add(origin, scale(offset, 0.5)),
      "exit" => add(origin, scale(offset, 1.5)),
      "points" => [origin, add(origin, scale(offset, 0.5)), add(origin, scale(offset, 1.5))],
      "intersection" => %{
        "region" => "central",
        "from" => add(origin, scale(offset, 0.5)),
        "to" => add(origin, scale(offset, 1.5)),
        "length" => norm
      },
      "presentation_offset" => offset,
      "presentation_origin" => add(origin, offset),
      "matrix" => [
        [1, 0, 0, Enum.at(offset, 0)],
        [0, 1, 0, 6],
        [0, 0, 1, Enum.at(offset, 2)],
        [0, 0, 0, 1]
      ],
      "regarding_reference" => add(origin, scale(offset, 2)),
      "representation" =>
        "straight registered candidate and translation matrix; no invented curved passage"
    }
  end

  def material(projection, footing) do
    Map.new(~w(vertical oblique), fn id ->
      {id,
       %{
         "footing_id" => footing["id"],
         "station_id" => footing["station_id"],
         "source" => footing["source_point"],
         "point" => add(footing["source_point"], projection[id]["presentation_offset"]),
         "transform" => projection[id]["id"]
       }}
    end)
  end

  def cob(projection, progress) do
    [a, b] = projection["course"]["points"]

    %{
      "id" => "cob-progress-witness",
      "course" => projection["course"]["id"],
      "progress" => progress,
      "distance" => progress * projection["course"]["length"],
      "point" => Enum.zip_with(a, b, &(&1 + (&2 - &1) * progress))
    }
  end

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp scale(a, amount), do: Enum.map(a, &(&1 * amount))
end
