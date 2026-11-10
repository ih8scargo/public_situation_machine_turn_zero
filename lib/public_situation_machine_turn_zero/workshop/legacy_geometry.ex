defmodule PublicSituationMachineTurnZero.Workshop.LegacyGeometry do
  @moduledoc "Pure provisional workshop geometry. One extent is a model unit, not a physical measure."
  @basis [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
  def rail,
    do: %{"id" => "common-rail", "start" => [0, 0, 0], "end" => [18, 0, 0], "length" => 18}

  def regions(positions) do
    %{
      "tc" => cube("tc", "Terrestrial Computer", [positions["tc"], 0, -3]),
      "central" => cube("central", "Central contraption / Projectioning Crossing", [6, 0, -3]),
      "ch" => cube("ch", "Constitutioning Human", [positions["ch"], 0, -3]),
      "lower" => cube("lower", "Ground–monitor relational region", [6, -6, -3])
    }
  end

  defp cube(id, name, origin) do
    vertices =
      for i <- 0..7,
          do:
            Enum.zip_with(
              origin,
              [
                if(Bitwise.band(i, 1) > 0, do: 6, else: 0),
                if(Bitwise.band(i, 2) > 0, do: 6, else: 0),
                if(Bitwise.band(i, 4) > 0, do: 6, else: 0)
              ],
              &(&1 + &2)
            )

    # Box-edge bit enumeration adapted from elementary_opening.js:wireframeEdges.
    edges =
      for i <- 0..7,
          bit <- [1, 2, 4],
          Bitwise.band(i, bit) == 0,
          do: %{"id" => "#{id}-edge-#{i}-#{bit}", "vertices" => [i, Bitwise.bor(i, bit)]}

    surfaces =
      for {side, indexes} <- [
            {"x-min", [0, 2, 6, 4]},
            {"x-max", [1, 3, 7, 5]},
            {"y-min", [0, 1, 5, 4]},
            {"y-max", [2, 3, 7, 6]},
            {"z-min", [0, 1, 3, 2]},
            {"z-max", [4, 5, 7, 6]}
          ] do
        role =
          case {id, side} do
            {"lower", "y-min"} -> "Ground-side reference / recurring zero-standing"
            {"lower", "y-max"} -> "Monitor-side reference"
            _ -> "inspection outline"
          end

        %{"id" => "#{id}-surface-#{side}", "vertices" => indexes, "role" => role}
      end

    %{
      "id" => id,
      "name" => name,
      "dimensions" => [6, 6, 6],
      "frame" => %{"origin" => origin, "basis" => @basis},
      "vertices" => vertices,
      "edges" => edges,
      "surfaces" => surfaces
    }
  end

  def relationships do
    [
      %{
        "id" => "lower-under-central",
        "subject" => "lower",
        "relation" => "UNDER",
        "object" => "central"
      },
      %{
        "id" => "ground-monitor-opposed",
        "subject" => "lower-surface-y-min",
        "relation" => "OPPOSITE",
        "object" => "lower-surface-y-max"
      }
    ]
  end

  def reservations do
    for {id, description} <- [
          {"central-upper-aperture",
           "Upper-circle center aperture OVER ACROSS Snail House; frame and dimensions unappointed"},
          {"ground-monitor-passage",
           "UP ACROSS DOWN; attachments refer to lower Ground/monitor surfaces; curve unappointed"},
          {"human-transverse-passage",
           "Separate Human Regarding THROUGH Doll-head aperture; frame and aperture unappointed"},
          {"xt-xt-lettering",
           "Future 25-letter CUBICAL rail and center U return; placement and curvature unappointed"},
          {"cab-side-regard", "CAB-side Regarding; frame unappointed"},
          {"within-cab-regard", "Within-CAB Regarding; frame unappointed"},
          {"human-transverse-regard",
           "Human transverse Regarding THROUGH Doll-head aperture; frame unappointed"}
        ],
        do: %{
          "id" => id,
          "status" => "reserved",
          "description" => description,
          "frame" => nil,
          "dimensions" => nil
        }
  end

  def overlaps(positions) do
    ranges = [{"tc", positions["tc"]}, {"central", 6}, {"ch", positions["ch"]}]

    for {a, x} <- ranges,
        {b, y} <- ranges,
        a < b,
        min(x + 6, y + 6) > max(x, y),
        do:
          "#{String.upcase(a)} / #{String.upcase(b)}: #{Float.round((min(x + 6, y + 6) - max(x, y)) * 1.0, 2)} extents"
  end
end
