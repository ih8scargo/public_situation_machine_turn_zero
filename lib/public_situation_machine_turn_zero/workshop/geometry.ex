defmodule PublicSituationMachineTurnZero.Workshop.Geometry do
  # Geometry reconciliation: Historical eighteen-extent reservations are not additional material beyond the revised SIX frame.
  # Current authority: docs/architecture/geometry/README.md; see impact-ledger.md.
  @moduledoc "Pure provisional workshop geometry. One extent is a model unit, not a physical measure."
  @basis [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
  def rail,
    do: %{"id" => "common-rail", "start" => [0, 0, 0], "end" => [18, 0, 0], "length" => 18}

  def regions(positions) do
    %{
      "tc" => cube("tc", "Terrestrial Computer", [positions["tc"], 0, -3]),
      "central" => cube("central", "Projectioning Crossing · architectural center", [12, 0, -3]),
      "ch" => cube("ch", "Constitutioning Human", [positions["ch"], 0, -3]),
      "lower" => cube("lower", "Ground–monitor relational region", [12, -6, -3])
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
           "25-letter structural index furnished as a provisional course; final CUBICAL lettering members unappointed"},
          {"descent",
           "Reserved counterclockwise unwinding: initial one revolution, adjustable winding count, four quadrant references; no descent curve"},
          {"regarding-appointments",
           "Potential stands around all four CUBICAL volumes; Camera A descending toward U/Fieldside, Camera B OVER ACROSS, A rising and reciprocal Regarding; frames unappointed"},
          {"footings-regard",
           "Future Regarding THROUGH next Little ROUNDING Footings TOWARD RE-STEPPING FROM HERE; no transitions"},
          {"cob-alongside",
           "COB available alongside WITH CH before formal seating; companionable/consoling surfacing reserved, no interface or storybooking"},
          {"nav-tunnel-treadmill",
           "Future NAV-STEPPING tunnel and mouse treadmill; no navigation implemented"},
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
    ranges = [{"tc", positions["tc"]}, {"central", 12}, {"ch", positions["ch"]}]

    for {a, x} <- ranges,
        {b, y} <- ranges,
        a < b,
        min(x + 6, y + 6) > max(x, y),
        do:
          "#{String.upcase(a)} / #{String.upcase(b)}: #{Float.round((min(x + 6, y + 6) - max(x, y)) * 1.0, 2)} extents"
  end
end
