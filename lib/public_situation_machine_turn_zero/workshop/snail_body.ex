defmodule PublicSituationMachineTurnZero.Workshop.SnailBody do
  @moduledoc "Experimental body geometry and conservative Quilling/bobbin rehearsal. No constitutional turn or PINNING operation."
  alias PublicSituationMachineTurnZero.Workshop.{Projection, WedgingGeometry}

  def new, do: initial(Ecto.UUID.generate())

  defp initial(id),
    do: %{
      "id" => id,
      "revision" => 0,
      "needle" => "inkwell",
      "held" => nil,
      "pieces" => [],
      "material" => [],
      "outstanding" => 0,
      "withdrawn" => 0,
      "gathered" => 0,
      "ready_for_pinning" => false,
      "events" => []
    }

  def operate(%{"needle" => needle, "outstanding" => outstanding} = s, command) do
    if s["revision"] >= 160 do
      {:error, :limit}
    else
      case command do
        :take when needle == "inkwell" ->
          event(s, %{"action" => "take"})

        {:withdraw, n}
        when needle == "held" and is_integer(n) and n > 0 and n <= 3000 and
               outstanding + n <= 6000 ->
          event(s, %{"action" => "withdraw", "amount" => n})

        {:quill, text}
        when needle == "held" and is_binary(text) and byte_size(text) <= 2000 ->
          if String.trim(text) == "",
            do: {:error, :empty},
            else: event(s, %{"action" => "quill", "text" => text})

        :return when needle == "held" ->
          event(s, %{"action" => "return"})

        {:gather, n}
        when needle == "gathering" and is_integer(n) and n > 0 and n <= outstanding ->
          event(s, %{"action" => "gather", "amount" => n})

        _ ->
          {:error, :condition}
      end
    end
  end

  defp event(s, e) do
    revision = s["revision"] + 1

    next =
      case e do
        %{"action" => "take"} ->
          piece = %{
            "id" => "#{s["id"]}-piece-#{revision}",
            "provenance" => "Constitutioning Human / actual Terrestrial Computer · Pretending",
            "status" => "held",
            "withdrawn" => 0,
            "gathered" => 0,
            "acquired_standing" => "existing HERE; no new acquisition",
            "standing_anchor" => [0, 0, 0],
            "readying_point" => hd(line_path()),
            "line_trace" => []
          }

          %{
            s
            | "needle" => "held",
              "held" => piece["id"],
              "pieces" => s["pieces"] ++ [piece],
              "ready_for_pinning" => false
          }

        %{"action" => "withdraw", "amount" => n} ->
          s
          |> Map.put("outstanding", s["outstanding"] + n)
          |> Map.put("withdrawn", s["withdrawn"] + n)
          |> update_piece(fn p ->
            %{
              p
              | "withdrawn" => p["withdrawn"] + n,
                "line_trace" => prefix(line_path(), (p["withdrawn"] + n) / 1000)
            }
          end)

        %{"action" => "quill", "text" => text} ->
          record = %{
            "id" => "#{s["id"]}-material-#{revision}",
            "piece" => s["held"],
            "author" => "Constitutioning Human",
            "affordment" => "Quilling Stitching Needle",
            "text" => text,
            "standing" => "authored Pretending material; not Road Stitching"
          }

          %{s | "material" => s["material"] ++ [record]}

        %{"action" => "return"} ->
          ready = s["outstanding"] == 0

          s
          |> Map.put("needle", if(ready, do: "inkwell", else: "gathering"))
          |> Map.put("ready_for_pinning", ready)
          |> update_piece(
            &Map.put(&1, "status", if(ready, do: "readied", else: "relinquished; gathering"))
          )
          |> Map.put("held", nil)

        %{"action" => "gather", "amount" => n} ->
          remaining = s["outstanding"] - n

          s
          |> Map.put("outstanding", remaining)
          |> Map.put("gathered", s["gathered"] + n)
          |> Map.put("needle", if(remaining == 0, do: "inkwell", else: "gathering"))
          |> Map.put("ready_for_pinning", remaining == 0)
          |> update_piece(fn p ->
            %{
              p
              | "gathered" => p["gathered"] + n,
                "status" => if(remaining == 0, do: "readied", else: "relinquished; gathering")
            }
          end)
      end

    {:ok, %{next | "revision" => revision, "events" => s["events"] ++ [e]}}
  end

  defp update_piece(s, f),
    do: Map.update!(s, "pieces", fn pieces -> List.update_at(pieces, -1, f) end)

  def export(s),
    do: Jason.encode!(%{"schema" => "snail-body-quilling-v1", "state" => s}, pretty: true)

  def import(json) when is_binary(json) and byte_size(json) <= 1_000_000 do
    with {:ok,
          %{
            "schema" => "snail-body-quilling-v1",
            "state" => %{"id" => id, "events" => events} = s
          }} <- Jason.decode(json),
         {:ok, _} <- Ecto.UUID.cast(id),
         true <- is_list(events) and length(events) <= 160 do
      replay =
        Enum.reduce_while(events, {:ok, initial(id)}, fn e, {:ok, acc} ->
          command =
            case e do
              %{"action" => "take"} when map_size(e) == 1 -> :take
              %{"action" => "return"} when map_size(e) == 1 -> :return
              %{"action" => "withdraw", "amount" => n} when map_size(e) == 2 -> {:withdraw, n}
              %{"action" => "gather", "amount" => n} when map_size(e) == 2 -> {:gather, n}
              %{"action" => "quill", "text" => t} when map_size(e) == 2 -> {:quill, t}
              _ -> :invalid
            end

          case operate(acc, command) do
            {:ok, next} -> {:cont, {:ok, next}}
            _ -> {:halt, :invalid}
          end
        end)

      case replay do
        {:ok, expected} when expected == s -> {:ok, expected}
        _ -> {:error, :invalid_witness}
      end
    else
      _ -> {:error, :invalid_witness}
    end
  end

  def import(_), do: {:error, :invalid_witness}

  # One finite routed line. Amounts are integer thousandths of an experimental unit.
  def line_path,
    do: [
      [-1.15, -0.6, 0.6],
      [-1.15, -0.6, 1.2],
      [1.15, -0.6, 1.2],
      [1.15, -0.6, -1.2],
      [-1.15, -0.6, -1.2]
    ]

  def prefix(points, amount) do
    {segments, _} =
      Enum.reduce_while(Enum.zip(points, tl(points)), {[hd(points)], max(0, amount)}, fn {a, b},
                                                                                         {out,
                                                                                          left} ->
        length = WedgingGeometry.distance(a, b)

        if left <= length,
          do: {:halt, {out ++ [add(a, scale(sub(b, a), left / length))], 0}},
          else: {:cont, {out ++ [b], left - length}}
      end)

    segments
  end

  @doc "One versioned analytic helix underlying all six radial-fold inspection purchases."
  def arc_point(t) when is_number(t) and t >= 0 and t <= 1 do
    angle = 3 * :math.pi() * t
    [0.85 * :math.cos(angle), -0.55 - 1.5 * t, 0.85 * :math.sin(angle)]
  end

  def arc_frame(t) do
    angle = 3 * :math.pi() * t

    tangent = [
      -0.85 * 3 * :math.pi() * :math.sin(angle),
      -1.5,
      0.85 * 3 * :math.pi() * :math.cos(angle)
    ]

    norm = :math.sqrt(Enum.sum(Enum.map(tangent, &(&1 * &1))))

    %{
      point: arc_point(t),
      tangent: scale(tangent, 1 / norm),
      radial: [:math.cos(angle), 0, :math.sin(angle)],
      binormal: [
        -1.5 / norm * :math.sin(angle),
        0.85 * 3 * :math.pi() / norm,
        1.5 / norm * :math.cos(angle)
      ],
      address: t * arc_length()
    }
  end

  def arc_length, do: :math.sqrt(:math.pow(0.85 * 3 * :math.pi(), 2) + 2.25)

  def reference_arc do
    %{
      version: "snail-radial-arc-v1",
      length: arc_length(),
      samples: Enum.map(0..144, &arc_frame(&1 / 144)),
      purchases: Enum.map(0..5, &arc_frame(&1 / 6))
    }
  end

  def model(state, fold \\ 90, quarter \\ 0) do
    theta = quarter * :math.pi() / 2
    center = arc_point(quarter / 6)
    radial = [:math.cos(theta), 0, :math.sin(theta)]
    tangent = [-:math.sin(theta), 0, :math.cos(theta)]
    a = fold * :math.pi() / 180
    across = add([0, :math.cos(a), 0], scale(tangent, :math.sin(a)))
    normal = add(scale(tangent, :math.cos(a)), [0, -:math.sin(a), 0])
    place = fn u, v -> center |> add(scale(radial, u)) |> add(scale(across, v)) end
    rings = for offset <- [-0.18, 0.18], do: sector(place, offset)
    shared = for v <- [-0.24, 0.24], do: place.(0, v)

    mouth =
      for i <- 0..32,
          do:
            place.(
              -0.18 + 0.22 * :math.cos(i * :math.pi() / 16),
              0.22 * :math.sin(i * :math.pi() / 16)
            )

    far = Enum.map(mouth, &add(&1, scale(normal, 0.35)))

    tunnel =
      Enum.zip(Enum.chunk_every(mouth, 2, 1, :discard), Enum.chunk_every(far, 2, 1, :discard))
      |> Enum.map(fn {[a, b], [c, d]} -> [a, b, d, c] end)

    tunnel_axis = place.(-0.18, 0)

    through = [
      add(tunnel_axis, scale(normal, -0.18)),
      tunnel_axis,
      add(tunnel_axis, scale(normal, 0.35))
    ]

    corner = [-0.55, -0.65, -0.75]
    side = [-1.45, -0.65, -0.75]
    inner = [-0.55, -0.65, 0.75]
    monitor = [-0.55, -0.65, 1.4]
    inner_plane = rectangle(inner, [0.2, 0, 0], [0, 0.14, 0])
    eye = [-0.55, -0.65, -0.25]
    monitor_plane = Enum.map(inner_plane, &add(eye, scale(sub(&1, eye), 1.65)))
    mirror = rectangle(corner, [0.16, 0, 0.16], [0, 0.15, 0])

    helix = Enum.map(reference_arc().samples, & &1.point)

    spiral_surfaces =
      for i <- 0..143 do
        points =
          for {r, j} <- [{0.77, i}, {0.93, i}, {0.93, i + 1}, {0.77, i + 1}] do
            t = j / 144

            [
              r * :math.cos(3 * :math.pi() * t),
              -0.55 - 1.5 * t,
              r * :math.sin(3 * :math.pi() * t)
            ]
          end

        %{id: "corkscrew-ribbon-#{i}", points: points, color: "#5eead4", kind: "corkscrew"}
      end

    table_supports =
      for x <- [-1.2, 1.2], z <- [-0.6, 0.6], reduce: [] do
        surfaces ->
          surfaces ++
            box(
              "table-support-#{x}-#{z}",
              [x - 0.04, -0.2, z - 0.04],
              [x + 0.04, -0.1, z + 0.04],
              "#d9b65e"
            )
      end

    surfaces =
      spiral_surfaces ++
        table_supports ++
        (box("cabinet", [-1.45, -2.8, -1.45], [1.45, -0.2, 1.45], "#7093b7")
         |> Enum.reject(&(&1.id == "cabinet-5"))) ++
        side_wall() ++
        annulus("table", 1.4, 0.24, -0.1, "#d9b65e") ++
        annulus("standing-landinging", 0.48, 0.24, 0, "#5eead4") ++
        box("intermediate-shield", [-0.45, -0.5, -0.45], [0.45, -0.4, 0.45], "#a78bfa") ++
        box("down-under-computer", [-0.65, -2.65, -0.45], [0.65, -2.25, 0.45], "#67b6dd") ++
        box("inkwell", [0.65, 0, 0.55], [0.8, 0.15, 0.7], "#d8b4fe") ++
        [
          %{
            id: "ordinary-flat-monitor",
            points: monitor_plane,
            color: "#b6cedd",
            kind: "monitor"
          },
          %{id: "inner-aperture", points: inner_plane, color: "#5eead4", kind: "aperture"},
          %{
            id: "cabinet-side-aperture",
            points: rectangle(side, [0, 0, 0.2], [0, 0.14, 0]),
            color: "#fbbf24",
            kind: "aperture"
          },
          %{id: "corner-fold-plane", points: mirror, color: "#f472b6", kind: "instrument"}
        ] ++
        for(
          {ring, index} <- Enum.with_index(rings),
          {points, i} <- Enum.with_index(ring),
          do: %{
            id: "partial-ring-#{index}-#{i}",
            points: points,
            color: if(index == 0, do: "#5eead4", else: "#fbbf24"),
            kind: "wedging"
          }
        ) ++
        for(
          {p, i} <- Enum.with_index(tunnel),
          do: %{id: "tunnel-wall-#{i}", points: p, color: "#b8a2ec", kind: "tunnel"}
        ) ++
        [
          %{
            id: "pittoning-surface",
            points: rectangle(tunnel_axis, scale(radial, 0.12), scale(across, 0.12)),
            color: "#f472b6",
            kind: "pittoning"
          }
        ]

    needle_tip = if state["needle"] == "held", do: [0.8, 0.5, 0.5], else: [0.725, 0.12, 0.625]

    bobbin =
      for i <- 0..48 do
        angle = i * :math.pi() / 8
        [-1.15 + 0.12 * :math.cos(angle), -0.6 + 0.12 * :math.sin(angle), 0.48 + 0.12 * i / 48]
      end

    lines =
      [
        line(
          "HERE-persistent-square",
          [[-0.7, 0, -0.7], [0.7, 0, -0.7], [0.7, 0, 0.7], [-0.7, 0, 0.7], [-0.7, 0, -0.7]],
          "#e2e8f0"
        ),
        line("descending-corkscrew", helix, "#5eead4"),
        line("spindle", [[0, 0.4, 0], [0, -2.12, 0]], "#e2e8f0"),
        line("shared-plane-intersections", shared, "#f472b6"),
        line("THROUGH-ALONG", through, "#e2e8f0"),
        line("XT-to-YT", arrow(tunnel_axis, normal, radial, 0.045), "#5eead4"),
        line(
          "YT-to-XT",
          arrow(add(tunnel_axis, scale(normal, 0.35)), scale(normal, -1), radial, -0.045),
          "#fbbf24"
        ),
        line("tunnel-mouth", mouth, "#d8b4fe"),
        line("tunnel-opening", far, "#d8b4fe"),
        line("side-AROUND-THE-CORNER", [side, corner, inner, monitor], "#f472b6"),
        line(
          "Quilling-Stitching-Needle",
          [needle_tip, add(needle_tip, [0.03, 0.35, 0])],
          "#fbbf24"
        ),
        line("bobbin", bobbin, "#d9b65e"),
        line("gathered-YT-winding", winding(state["gathered"] / 1000), "#fbbf24"),
        line("standing-to-readying-lead", [[0, 0, 0], [-1.15, -0.6, 0.6]], "#d9b65e"),
        line("outstanding-YT", prefix(line_path(), state["outstanding"] / 1000), "#fbbf24")
      ] ++
        for {p, i} <- Enum.with_index(inner_plane),
            do: line("projection-ray-#{i}", [eye, p, Enum.at(monitor_plane, i)], "#6d8b9e")

    %{
      surfaces: surfaces,
      lines: lines,
      fixed: %{
        here: [[-0.7, 0, -0.7], [0.7, 0, -0.7], [0.7, 0, 0.7], [-0.7, 0, 0.7]],
        landinging: %{center: [0, 0, 0], radius: 0.48},
        computer: %{min: [-0.65, -2.65, -0.45], max: [0.65, -2.25, 0.45]}
      },
      fold: %{
        degrees: fold,
        quarter: quarter,
        center: center,
        normal: normal,
        mouth: mouth,
        far: far,
        shared_points: shared,
        tunnel_axis: tunnel_axis,
        XT_to_YT: [tunnel_axis, List.last(through)],
        YT_to_XT: [List.last(through), tunnel_axis],
        janusite:
          "both faces of the same transformed annular strips; continuous paired boundaries"
      },
      instrumentation: %{
        id: "side-around-corner",
        path: [side, corner, inner, monitor],
        plane: mirror,
        reflection_normal: [1 / :math.sqrt(2), 0, -1 / :math.sqrt(2)],
        relation: "TOWARD STANDING / TOWARD REGARDING-ABILITY",
        provenance: "Human-appointed experimental planar fold; retained when hidden",
        known_projection: Projection.model(Projection.defaults())["vertical"],
        registration:
          "references existing planar candidate; local rigid/scale registration to production remains open",
        inner: inner_plane,
        monitor: monitor_plane
      },
      separation: %{
        table_opening_radius: 0.24,
        intervening_shield: %{min: [-0.45, -0.5, -0.45], max: [0.45, -0.4, 0.45]},
        direct_vertical_access: false,
        computer_top: -2.25,
        shield_bottom: -0.5
      },
      line: %{
        units:
          "integer thousandths of a unit; paid-out excess only, fixed standing-to-readying lead excluded",
        standing_anchor: [0, 0, 0],
        readying_point: hd(line_path()),
        fixed_lead: [[0, 0, 0], hd(line_path())],
        path: line_path(),
        visible: prefix(line_path(), state["outstanding"] / 1000),
        outstanding: state["outstanding"],
        gathered: state["gathered"],
        withdrawn: state["withdrawn"],
        ready: state["ready_for_pinning"]
      },
      within_eye: add(tunnel_axis, scale(normal, 0.08)),
      within_toward: add(tunnel_axis, scale(normal, 0.35)),
      status:
        "Same workshop, experimental body study. No Tuple Ship container, production transform, new Ground, RE-STEP or anchored index."
    }
  end

  defp arrow(origin, direction, radial, offset) do
    start = add(origin, scale(radial, offset))
    finish = add(start, scale(direction, 0.35))
    tail = sub(finish, scale(direction, 0.08))
    [start, finish, add(tail, scale(radial, 0.035)), finish, sub(tail, scale(radial, 0.035))]
  end

  defp winding(length) do
    # Exact helical arc-length parameter; low pitch, radius .13.
    pitch = 0.012 / (2 * :math.pi())
    angle = length / :math.sqrt(0.13 * 0.13 + pitch * pitch)
    count = max(1, ceil(angle * 8))

    for i <- 0..count do
      t = angle * i / count
      [-1.15 + 0.13 * :math.cos(t), -0.6 + 0.13 * :math.sin(t), 0.48 + pitch * t]
    end
  end

  defp side_wall do
    for {z0, z1, y0, y1} <- [
          {-1.45, -0.95, -2.8, -0.2},
          {-0.55, 1.45, -2.8, -0.2},
          {-0.95, -0.55, -2.8, -0.79},
          {-0.95, -0.55, -0.51, -0.2}
        ],
        reduce: [] do
      out ->
        out ++
          [
            %{
              id: "side-wall-#{z0}-#{y0}",
              points: [[-1.45, y0, z0], [-1.45, y0, z1], [-1.45, y1, z1], [-1.45, y1, z0]],
              color: "#7093b7",
              kind: "cabinet"
            }
          ]
    end
  end

  defp line(id, points, color), do: %{id: id, points: points, color: color, kind: "line"}

  defp rectangle(c, u, v),
    do: [add(add(c, u), v), add(sub(c, u), v), sub(sub(c, u), v), add(sub(c, v), u)]

  defp sector(place, offset) do
    for i <- 0..47 do
      a = (30 + i * 300 / 48) * :math.pi() / 180
      b = (30 + (i + 1) * 300 / 48) * :math.pi() / 180

      for {r, t} <- [{0.27, a}, {0.33, a}, {0.33, b}, {0.27, b}],
          do: place.(offset + r * :math.cos(t), r * :math.sin(t))
    end
  end

  defp annulus(id, outer, inner, y, color) do
    for i <- 0..47 do
      a = i * :math.pi() / 24
      b = (i + 1) * :math.pi() / 24

      %{
        id: "#{id}-#{i}",
        points:
          for(
            {r, t} <- [{inner, a}, {outer, a}, {outer, b}, {inner, b}],
            do: [r * :math.cos(t), y, r * :math.sin(t)]
          ),
        color: color,
        kind: id
      }
    end
  end

  defp box(id, [x, y, z], [u, v, w], color) do
    vertices = [
      [x, y, z],
      [u, y, z],
      [u, y, w],
      [x, y, w],
      [x, v, z],
      [u, v, z],
      [u, v, w],
      [x, v, w]
    ]

    for {indices, i} <-
          Enum.with_index([
            [0, 1, 2, 3],
            [4, 5, 6, 7],
            [0, 1, 5, 4],
            [1, 2, 6, 5],
            [2, 3, 7, 6],
            [3, 0, 4, 7]
          ]),
        do: %{
          id: "#{id}-#{i}",
          points: Enum.map(indices, &Enum.at(vertices, &1)),
          color: color,
          kind: id
        }
  end

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp scale(a, n), do: Enum.map(a, &(&1 * n))
end
