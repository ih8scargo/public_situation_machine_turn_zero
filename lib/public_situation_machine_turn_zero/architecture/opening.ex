defmodule PublicSituationMachineTurnZero.Architecture.Opening do
  @moduledoc "Bounded elementary opening. Only completed PULL, PUFF and appointment furnish standing."
  alias PublicSituationMachineTurnZero.Architecture, as: A

  def new do
    relations =
      Map.new(
        [
          {"human-standing", "human", "ALREADY STANDING FROM", "here"},
          {"computer-with-human", "ordinary computering", "WITH", "human"},
          {"opening-circle-available", "opening-circle", "PLANAR FURNISHING TOWARD",
           "place-for-human"}
        ],
        fn {id, subject, predicate, object} ->
          {id,
           %{
             "subject" => subject,
             "relation" => predicate,
             "object" => object,
             "provenance" => "opening given",
             "dependencies" => [],
             "for_human" => "human"
           }}
        end
      )

    %A{
      standing: %{
        "version" => A.version(),
        "from" => %{"human" => "human", "here" => "here", "basis" => "human-standing"},
        "relations" => relations,
        "events" => [],
        "zipperings" => %{},
        "localities" => %{},
        "opening_geometry" => %{
          "sheet" => %{"half_width" => 2.8, "half_height" => 2.8, "z" => 0},
          "circle" => %{"center" => [0, 0, 0], "radius" => 1.15},
          "purchase" => %{
            "anchor" => [0, 0, 0],
            "length" => 0.9,
            "anchor_radius" => 0.045,
            "tab_half" => 0.16,
            "hollow_half" => 0.085
          }
        }
      }
    }
  end

  def operate(m, {:opening_pull, witness}) do
    if !A.legacy?(m) && !A.opened?(m) && valid_pull?(witness) do
      m =
        A.furnish(
          m,
          "first-pull",
          "human",
          "PULL FROM HERE",
          "STAND UP THE TOY BOX FROM HERE",
          ["human-standing", "opening-circle-available"],
          "opening-pull-course",
          [
            node(
              "opening-accomplished",
              "toy-box",
              "WIREFRAME STANDING TOWARD",
              "place-for-human",
              "opening-circle-available"
            ),
            node(
              "cob-square-standing",
              "cob",
              "INITIAL SQUARE WITHIN",
              "toy-box",
              "opening-accomplished"
            ),
            node(
              "puffer-available",
              "big-bellowing-thing",
              "AVAILABLE FOR",
              "inaugural PUFFING",
              "cob-square-standing"
            )
          ]
        )

      geometry =
        m.standing["opening_geometry"]
        |> Map.put("wireframe", %{
          "min" => [-1.2, -1.2, 0],
          "max" => [1.2, 1.2, 2.4],
          "relation" => "opening-accomplished"
        })
        |> Map.put("cob", %{
          "kind" => "square",
          "center" => [0, 0, 1.1],
          "half_size" => 0.24,
          "relation" => "cob-square-standing"
        })

      {:ok, with_geometry(m, geometry)}
    else
      {:error, :unavailable}
    end
  end

  def operate(m, :puff) do
    if !A.legacy?(m) && A.opened?(m) && !A.puffed?(m) do
      m =
        A.furnish(
          m,
          "first-puffing",
          "human",
          "SQUEEZE THIS ONE BIG BELLOWING THING",
          "JANUSITE extent FOR possibility",
          ["opening-accomplished", "cob-square-standing", "human-standing"],
          "opening-puff-course",
          [
            node(
              "first-puffing-accomplished",
              "human",
              "PUFFING THROUGH",
              "big-bellowing-thing",
              "puffer-available"
            ),
            node(
              "janusite-extent-standing",
              "janusite",
              "EXTENT FOR POSSIBILITY TOWARD OVER ACROSS",
              "place-for-human",
              "first-puffing-accomplished"
            ),
            node(
              "cob-standing",
              "cob",
              "ROUNDED BOBBINING OUTWARD FROM",
              "initial square wireframe",
              "janusite-extent-standing"
            ),
            node(
              "cob-for",
              "cob",
              "ALONGSIDE WITH",
              "human",
              "cob-standing"
            ),
            node("cob-current-local-moment", "cob", "THROUGH", "current-local-moment", "cob-for"),
            node(
              "aperture-available",
              "square-aperture",
              "AVAILABLE PURCHASE IN",
              "inherited square reference",
              "cob-square-standing"
            ),
            node(
              "stick-available",
              "stick",
              "PRETENDING FOR POINTING THROUGH",
              "monitor plane into JANUSITE extent",
              "cob-current-local-moment"
            )
          ]
        )

      geometry =
        m.standing["opening_geometry"]
        |> Map.put("janusite", %{
          "center" => [0, 0, 1.6],
          "radii" => [3.7, 2.8, 3.2],
          "relation" => "janusite-extent-standing"
        })
        |> Map.put("cob", %{
          "kind" => "rounded",
          "center" => [1.9, 0.5, 2.8],
          "radii" => [0.42, 0.28, 0.33],
          "relation" => "cob-standing"
        })

      geometry =
        Map.put(geometry, "aperture", %{
          "center" => [0, 0, 0],
          "half_size" => 0.35,
          "relation" => "aperture-available"
        })

      {:ok, with_geometry(m, geometry)}
    else
      {:error, :unavailable}
    end
  end

  def operate(m, {:opening_feed, params}) do
    with true <- !A.legacy?(m) && A.puffed?(m) && !A.complete?(m),
         {:ok, bearing} <- bearing(params) do
      receiver = %{
        "aperture" => m.standing["opening_geometry"]["aperture"],
        "cubical_reference" => m.standing["opening_geometry"]["wireframe"],
        "cylinder" => %{
          "origin" => bearing["origin"],
          "tip" => bearing["tip"],
          "axis" => bearing["direction"],
          "radius" => 0.16
        },
        "grasp" => %{
          "kind" => "four-point take-hold",
          "direction" => bearing["direction"],
          "center" => bearing["tip"]
        }
      }

      {:ok,
       %{
         m
         | opening_stage:
             bearing |> Map.put("receiver", receiver) |> Map.put("token", Ecto.UUID.generate())
       }}
    else
      _ -> {:error, :unavailable}
    end
  end

  def operate(%{opening_stage: %{"token" => _} = locked} = m, :opening_appoint) do
    if !A.legacy?(m) && A.puffed?(m) && !A.complete?(m) do
      m =
        A.furnish(
          m,
          "appoint-pointingable",
          "human WITH cob",
          "FURNISHING THIS ONE PRETENDING STICK TOWARD THIS ONE COB FROM HERE",
          "Pointing establishes the bearing THROUGH",
          [
            "stick-available",
            "cob-for",
            "human-standing",
            "aperture-available",
            "janusite-extent-standing"
          ],
          "opening-pointing-course",
          [
            node(
              "stick-through-standing",
              "stick",
              "FULL EXTENT LOCKED THROUGH",
              "monitor plane into JANUSITE extent",
              "stick-available"
            ),
            node(
              "receiving-cylinder-standing",
              "receiving-cylinder",
              "FURNISHED THROUGH",
              "available CUBICAL extent",
              "stick-through-standing"
            ),
            node(
              "cob-grasp-standing",
              "cob",
              "TAKES HOLD THROUGH",
              "receiving-cylinder",
              "receiving-cylinder-standing"
            ),
            node(
              "cob-up-over-stick",
              "cob",
              "UP OVER WITH APPOINTED BEARING",
              "stick",
              "cob-grasp-standing"
            ),
            node(
              "pointingable-standing",
              "pointingable",
              "APPOINTED THROUGH BY WAY OF",
              "cob",
              "cob-up-over-stick"
            )
          ]
        )

      relation =
        m.standing["relations"]["receiving-cylinder-standing"]
        |> Map.put("reference_geometry", "aperture-available")
        |> Map.update!("dependencies", &(&1 ++ ["aperture-available"]))

      m = %{
        m
        | standing: put_in(m.standing, ["relations", "receiving-cylinder-standing"], relation)
      }

      appointed = Map.delete(locked, "token")

      geometry =
        m.standing["opening_geometry"]
        |> Map.put("stick", appointed)
        |> put_in(["cob", "center"], appointed["cob_center"])
        |> put_in(["cob", "orientation"], appointed["direction"])

      event = List.last(m.standing["events"]) |> Map.put("furnished_geometry", appointed)

      standing =
        m.standing
        |> Map.put("opening_geometry", geometry)
        |> Map.update!("events", &(Enum.drop(&1, -1) ++ [event]))

      {:ok, %{m | standing: standing, opening_stage: nil}}
    else
      {:error, :unavailable}
    end
  end

  def operate(_, _), do: {:error, :unavailable}

  def bearing(%{"yaw" => yaw, "pitch" => pitch, "extension" => extension, "length" => length})
      when is_number(yaw) and yaw >= -60 and yaw <= 60 and
             is_number(pitch) and pitch >= -45 and pitch <= 45 and extension == 1 and
             is_number(length) and length >= 1 and length <= 3 do
    y = yaw * :math.pi() / 180
    p = pitch * :math.pi() / 180
    direction = [:math.sin(y) * :math.cos(p), :math.sin(p), :math.cos(y) * :math.cos(p)]
    tip = Enum.map(direction, &(&1 * length))
    [x, up, z] = tip

    {:ok,
     %{
       "origin" => [0, 0, 0],
       "tip" => tip,
       "direction" => direction,
       "yaw" => yaw,
       "pitch" => pitch,
       "length" => length,
       "extension" => 1,
       "cob_center" => [x, up + 0.32, z],
       "relation" => "pointingable-standing"
     }}
  end

  def bearing(_), do: {:error, :invalid_bearing}

  defp with_geometry(m, geometry) do
    event = List.last(m.standing["events"]) |> Map.put("furnished_geometry", geometry)

    standing =
      m.standing
      |> Map.put("opening_geometry", geometry)
      |> Map.update!("events", &(Enum.drop(&1, -1) ++ [event]))

    %{m | standing: standing}
  end

  defp valid_pull?(%{"dx" => dx, "dy" => dy}) when is_number(dx) and is_number(dy),
    do: abs(dx) <= 10000 && abs(dy) <= 10000 && (dx != 0 || dy != 0)

  defp valid_pull?(_), do: false

  defp node(id, s, r, o, through),
    do: %{id: id, subject: s, predicate: r, object: o, through: through, role: "furnishing"}
end
