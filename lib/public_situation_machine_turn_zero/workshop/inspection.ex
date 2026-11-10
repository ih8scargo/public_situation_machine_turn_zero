defmodule PublicSituationMachineTurnZero.Workshop.Inspection do
  @moduledoc "Recoverable inspection appointments; never construction, acquisition or NAV-STEP."
  @stands [3, 8, 13, 18, 23]
  @keys ~w(stand from target distance orbit elevation turn mode through monitor_offset monitor_side monitor_xy monitor_start feed_mode treatment)
  def stands, do: @stands

  def new(model, stand \\ 13) when stand in @stands do
    point = station(model, stand)["point"]

    p = %{
      "stand" => stand,
      "from" => point,
      "target" => "letter:#{stand}",
      "distance" => 3.0,
      "orbit" => 0.0,
      "elevation" => 8.0,
      "turn" => 0.0,
      "mode" => "orbit",
      "through" => false,
      "monitor_start" => 1.0,
      "feed_mode" => "orbit",
      "monitor_offset" => 1.0,
      "monitor_side" => 1,
      "monitor_xy" => [15, 3],
      "treatment" => "registered"
    }

    %{
      "version" => 1,
      "revision" => 0,
      "original_from" => point,
      "parameters" => p,
      "history" => [p],
      "overview" => %{"regarding" => "front", "yaw" => 0}
    }
  end

  def station(model, index), do: Enum.find(model["steeling"]["stations"], &(&1["index"] == index))

  def valid_parameters?(p) when is_map(p) do
    Enum.sort(Map.keys(p)) == Enum.sort(@keys) and p["stand"] in @stands and vector?(p["from"], 3) and
      is_binary(p["target"]) and String.length(p["target"]) <= 100 and
      p["mode"] in ~w(overview orbit along_forward along_backward surface_along monitor) and
      p["feed_mode"] in ~w(orbit along_forward along_backward surface_along) and
      is_boolean(p["through"]) and p["monitor_side"] in [-1, 1] and vector?(p["monitor_xy"], 2) and
      p["treatment"] in ~w(solid registered structural) and
      Enum.all?(
        [
          {"distance", 0.08, 80},
          {"orbit", -180, 180},
          {"elevation", -89, 89},
          {"turn", -180, 180},
          {"monitor_start", 0.08, 120},
          {"monitor_offset", -20, 120}
        ],
        fn {k, a, b} -> is_number(p[k]) and p[k] >= a and p[k] <= b end
      ) and (p["through"] or p["monitor_offset"] >= 0.08)
  end

  def valid_parameters?(_), do: false

  def valid?(
        %{
          "version" => 1,
          "revision" => r,
          "original_from" => origin,
          "overview" => overview,
          "parameters" => p,
          "history" => h
        } = s
      )
      when is_integer(r) and is_list(h) do
    map_size(s) == 6 and is_map(overview) and map_size(overview) == 2 and
      overview["regarding"] in ~w(front reverse plan lower transverse departure reciprocal tunneling diorama) and
      is_number(overview["yaw"]) and abs(overview["yaw"]) <= 180 and r in 0..500 and
      vector?(origin, 3) and length(h) == r + 1 and
      Enum.all?(h, &valid_parameters?/1) and List.last(h) == p and hd(h)["from"] == origin
  end

  def valid?(_), do: false

  def registered?(state, model) do
    Enum.all?(state["history"], fn p ->
      Enum.any?(model["provenance"], fn event ->
        stations =
          PublicSituationMachineTurnZero.Workshop.Steeling.model(event["parameters"])["stations"]

        Enum.find(stations, &(&1["index"] == p["stand"]))["point"] == p["from"]
      end)
    end)
  end

  def change(s, revision, p) do
    p =
      if is_map(p),
        do: Map.new(p, fn {k, v} -> {k, if(is_number(v) and v == 0, do: 0.0, else: v)} end),
        else: p

    cond do
      revision != s["revision"] ->
        {:error, :stale}

      not valid_parameters?(p) ->
        {:error, :invalid}

      p == s["parameters"] ->
        {:ok, s}

      revision >= 500 ->
        {:error, :limit}

      true ->
        {:ok,
         %{s | "revision" => revision + 1, "parameters" => p, "history" => s["history"] ++ [p]}}
    end
  end

  def appoint(s, model, index) when index in @stands do
    point = station(model, index)["point"]

    p =
      Map.merge(s["parameters"], %{
        "stand" => index,
        "from" => point,
        "target" => "letter:#{index}",
        "distance" => 3.0,
        "orbit" => 0.0,
        "elevation" => 8.0,
        "turn" => 0.0,
        "mode" => "orbit",
        "monitor_offset" => 1.0,
        "through" => false
      })

    change(s, s["revision"], p)
  end

  def locality(model, registry, id) do
    case String.split(id, ":", parts: 2) do
      ["letter", raw] ->
        case Integer.parse(raw) do
          {i, ""} when i in 1..25 ->
            s = station(model, i)

            %{
              "id" => id,
              "label" => "#{s["letter"]}#{i}",
              "point" => s["point"],
              "radius" => 0.32,
              "normal" => [0, 0, -1],
              "source" =>
                Map.merge(s, %{
                  "presentation_frame" => %{
                    "origin" => s["point"],
                    "basis" => [[1, 0, 0], [0, 1, 0], [0, 0, 1]],
                    "status" => "provisional display frame; not constitutional letter orientation"
                  },
                  "from_face" => %{"normal" => [0, 0, -1], "z_offset" => -0.04},
                  "inherited_u_reference" => %{
                    "origin" => [15, 3, 0],
                    "normal" => [0, 0, 1],
                    "curvature_limit" => 90
                  }
                })
            }

          _ ->
            nil
        end

      ["region", key] when key in ~w(tc ch central lower) ->
        e = model["entities"][key]

        %{
          "id" => id,
          "label" => e["name"],
          "point" => add(e["frame"]["origin"], [3, 3, 3]),
          "radius" => 5.2,
          "normal" => [0, 0, -1],
          "source" => e
        }

      ["plane", key] ->
        item = Enum.find(registry["items"], &(&1["id"] == key))

        if item do
          n = length(item["points"])

          point =
            Enum.reduce(item["points"], [0, 0, 0], fn p, s -> add(s, Enum.map(p, &(&1 / n))) end)

          normal = item["frame"]["bearing"]
          normal = if dot(normal, normal) == 0, do: [0, 0, 1], else: normal

          normal =
            case String.split(key, "-surface-") do
              [entity, _] ->
                center = add(model["entities"][entity]["frame"]["origin"], [3, 3, 3])
                if dot(normal, sub(point, center)) < 0, do: Enum.map(normal, &(-&1)), else: normal

              _ ->
                normal
            end

          %{
            "id" => id,
            "label" => item["label"],
            "point" => point,
            "radius" => 0.08,
            "normal" => normal,
            "source" => item,
            "decomposition" => %{
              "existing" => %{
                "id" => key,
                "kind" => item["kind"],
                "constituent_points" => item["points"]
              },
              "candidate_aperture" =>
                "UNFURNISHED; would require an explicitly appointed frame, bounds and bearing",
              "appointed_aperture" =>
                if(item["kind"] == "aperture",
                  do: "A04 aperture witness; dimensions remain provisional",
                  else: "none"
                ),
              "operational_instrument" => "none; selecting a surface does not create hardware"
            }
          }
        end

      _ ->
        nil
    end
  end

  def instrument(state, model, registry) do
    p = state["parameters"]
    target = locality(model, registry, p["target"]) || locality(model, registry, "letter:13")
    d = if p["through"], do: p["distance"], else: max(p["distance"], target["radius"] + 0.08)
    o = p["orbit"] * :math.pi() / 180
    e = p["elevation"] * :math.pi() / 180

    eye =
      cond do
        p["mode"] == "monitor" ->
          [
            15 + (Enum.at(p["monitor_xy"], 0) - 15) * p["monitor_offset"] / p["monitor_start"],
            3 + (Enum.at(p["monitor_xy"], 1) - 3) * p["monitor_offset"] / p["monitor_start"],
            -2 + p["monitor_side"] * p["monitor_offset"]
          ]

        p["mode"] in ~w(along_forward along_backward) ->
          add(p["from"], [0, 0, -d])

        true ->
          add(target["point"], [
            d * :math.sin(o) * :math.cos(e),
            d * :math.sin(e),
            -d * :math.cos(o) * :math.cos(e)
          ])
      end

    eye =
      if String.starts_with?(p["target"], "plane:") and !p["through"] and
           p["mode"] in ~w(orbit surface_along) do
        normal = target["normal"]
        norm = dot(normal, normal)

        correction =
          if norm > 0, do: max(0, 0.08 - dot(sub(eye, target["point"]), normal)) / norm, else: 0

        add(eye, Enum.map(normal, &(&1 * correction)))
      else
        eye
      end

    %{
      "eye" => eye,
      "from" => p["from"],
      "target" => target,
      "monitor_signed" => Enum.at(eye, 2) + 2,
      "monitor_distance" => abs(Enum.at(eye, 2) + 2),
      "mode" => p["mode"]
    }
  end

  def focus(state, model, registry, id) do
    case locality(model, registry, id) do
      nil ->
        {:error, :locality}

      target ->
        [x, y, z] = target["normal"]
        yaw = :math.atan2(x, -z) * 180 / :math.pi()
        elevation = :math.atan2(y, :math.sqrt(x * x + z * z)) * 180 / :math.pi()

        p =
          Map.merge(state["parameters"], %{
            "target" => id,
            "distance" => target["radius"] + 0.7,
            "orbit" => yaw,
            "elevation" => min(89, max(-89, elevation)),
            "turn" => 0.0,
            "mode" => "orbit",
            "monitor_offset" => max(0.08, state["parameters"]["monitor_offset"]),
            "through" => false
          })

        change(state, state["revision"], p)
    end
  end

  def monitor(state, model, registry) do
    eye = instrument(state, model, registry)["eye"]
    signed = Enum.at(eye, 2) + 2

    p =
      Map.merge(state["parameters"], %{
        "mode" => "monitor",
        "monitor_xy" => Enum.take(eye, 2),
        "monitor_start" => max(0.08, abs(signed)),
        "feed_mode" =>
          if(state["parameters"]["mode"] in ~w(orbit along_forward along_backward surface_along),
            do: state["parameters"]["mode"],
            else: state["parameters"]["feed_mode"]
          ),
        "monitor_side" => if(signed < 0, do: -1, else: 1),
        "monitor_offset" => min(120, max(0.08, abs(signed))),
        "through" => false
      })

    change(state, state["revision"], p)
  end

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
  defp sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp dot(a, b), do: Enum.zip_with(a, b, &(&1 * &2)) |> Enum.sum()

  defp vector?(v, n),
    do: is_list(v) and length(v) == n and Enum.all?(v, &(is_number(&1) and abs(&1) <= 10_000))
end
