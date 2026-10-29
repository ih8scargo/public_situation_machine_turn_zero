defmodule PublicSituationMachineTurnZero.Architecture.Extent do
  @moduledoc "Authored CUBICAL and course geometry, with stable material identity and situated projections. Rehearsal units are not physical measures."
  def geometry do
    %{
      "landinging" => %{
        "id" => "landinging",
        "kind" => "cylinder",
        "relation" => "landinging-standing",
        "radius" => 4.5,
        "bottom" => -2.5,
        "top" => 0,
        "bounds" => %{"x" => [-4.5, 4.5], "y" => [-2.5, 0], "z" => [-4.5, 4.5]},
        "readiness" => "READYINGMENTING TOWARD EN-FURNISHINGMENTING"
      },
      "center-square" => %{
        "id" => "center-square",
        "kind" => "square",
        "relation" => "center-square-standing",
        "position" => [0, 0.025, 0],
        "size" => 1.8
      },
      "regarding-square" => %{
        "id" => "regarding-square",
        "kind" => "regarding-square",
        "relation" => "regarding-square-available",
        "position" => [0, 1, 5.5],
        "size" => 1.8
      },
      "fountaining" => %{
        "id" => "fountaining",
        "kind" => "source",
        "relation" => "fountaining-standing",
        "position" => [-7, -2.5, 1]
      },
      "underlying-track" => %{
        "id" => "underlying-track",
        "kind" => "infrastructural-course",
        "relation" => "track-standing",
        "points" => course()
      },
      "xt-course" => %{
        "id" => "xt-course",
        "kind" => "course",
        "relation" => "xt-standing",
        "upon" => "track-standing",
        "points" => Enum.map(course(), fn [x, y, z] -> [x, y, z + 0.12] end),
        "bends" => [
          %{
            "at" => [-2, -1, 1],
            "relation" => "xt-opening-standing",
            "reason" =>
              "underlying piping turns into upstanding ALONG THROUGH XT at the Human-relative opening"
          }
        ]
      },
      "cob-appliance" => %{
        "id" => "cob-appliance",
        "kind" => "cob",
        "relation" => "cob-standing",
        "position" => [0, 1.2, -0.3]
      },
      "cob-chain" => %{
        "id" => "cob-chain",
        "kind" => "cob-course",
        "relation" => "cob-chain-standing",
        "source" => [0, -2.5, -0.3],
        "head" => [0, 1.2, -0.3]
      }
    }
  end

  def course do
    inlet = for i <- 0..6, do: [-7 + i * 3.5 / 6, -2.5, 1]

    bend =
      for i <- 1..12 do
        a = i * :math.pi() / 24
        [-3.5 + 1.5 * :math.sin(a), -1 - 1.5 * :math.cos(a), 1]
      end

    rise = for i <- 1..14, do: [-2, -1 + i * 6 / 14, 1]
    inlet ++ bend ++ rise
  end

  def material do
    "JANUSITE→XT"
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {glyph, i} ->
      %{
        "id" => "fountaining-character-#{i}",
        "glyph" => glyph,
        "course" => "xt-course",
        "relation" => "material-standing",
        "purchase" => i / 11
      }
    end)
  end

  def spindle(n),
    do: %{
      "id" => "spindle",
      "kind" => "spindle",
      "relation" => "spindle-#{n}",
      "square" => "center-square",
      "extent" => n,
      "limit" => 6,
      "position" => [0, 0, 0]
    }

  def projection(m) do
    h = m.standing["spindle_extent"]

    objects =
      m.standing["geometry"]
      |> put_in(["cob-appliance", "resolved_position"], [0, 1.2 + h, -0.3])
      |> put_in(["cob-chain", "resolved_points"], [
        [0, -2.5, -0.3],
        [0, 0, -0.3],
        [0, h + 0.3, -0.3],
        [0, h + 1.2, -0.3]
      ])

    %{
      "objects" => objects,
      "material" => m.standing["material"],
      "extent" => h,
      "bearing" => m.regarding.bearing,
      "opened" => PublicSituationMachineTurnZero.Architecture.opened?(m),
      "tool" => m.regarding.tool,
      "selected_material" => m.regarding.material,
      "cob_embedding_relation" => if(h > 0, do: "cob-lift-#{h}"),
      "view" =>
        if(m.regarding.bearing == "end-on",
          do: %{"tilt" => -88, "turn" => 0},
          else: %{"tilt" => -28, "turn" => -18}
        )
    }
  end
end
