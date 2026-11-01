defmodule PublicSituationMachineTurnZero.Architecture.Inscriptioning do
  @moduledoc "Retained XT-axle surfaces; event snapshots, not screen status, furnish inscription localities."
  @appointments [
    {"first-pull", "opening-accomplished", "FIRST PULL",
     "Inherited Toy Box standing TOWARD this one Place."},
    {"first-puffing", "janusite-extent-standing", "FIRST PUFFING THROUGH",
     "JANUSITE extent FOR possibility THROUGH the aperture."},
    {"appoint-pointingable", "pointingable-standing", "POINTING-ABLE APPOINTMENT",
     "The Human-furnished bearing stands THROUGH BY WAY OF COB."},
    {"second-puffing", "drawer-extent-standing", "SECOND PUFFING AROUND ABOUT",
     "The available drawer extent stands OVER ACROSS, AROUND ABOUT."}
  ]

  def locality(event_id), do: locality_v1(event_id)

  defp locality_v1(event_id) do
    Enum.with_index(@appointments)
    |> Enum.find_value(fn {{id, relation, title, inscription}, index} ->
      if id == event_id do
        x = -2.4 + index * 1.6

        %{
          "id" => "xt-axle-" <> id,
          "event" => id,
          "relation" => relation,
          "title" => title,
          "inscription" => inscription,
          "anchor" => [x, 0, 0],
          "surface" => [
            [x - 0.7, 0.1, 0],
            [x + 0.7, 0.1, 0],
            [x + 0.7, 0.95, 0],
            [x - 0.7, 0.95, 0]
          ],
          "ancestry" => ["human-standing", relation],
          "frame" => "grounded-xt-axle",
          "layout_version" => "xt-axle-v1",
          "status" => "experimental furnished convertible inscription surface"
        }
      end
    end)
  end

  def retained(standing) do
    Enum.flat_map(standing["events"] || [], fn event ->
      case event["inscription_locality"] || locality_v1(event["id"]) do
        nil -> []
        surface -> [Map.put(surface, "provenance", event["id"])]
      end
    end)
  end
end
