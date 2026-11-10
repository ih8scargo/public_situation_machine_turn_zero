defmodule PublicSituationMachineTurnZero.Workshop.SnailWeave do
  @moduledoc "Bounded integration of existing opening, SnailBody labor and continuous-arc turn witnesses. No RE-STEP, NAV-STEP or PINNING operation."
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Workshop.{SnailBody, WedgingRehearsal}

  def new, do: initial(Ecto.UUID.generate(), SnailBody.new())

  defp initial(id, body),
    do: %{
      "version" => "snail-weave-v1",
      "id" => id,
      "revision" => 0,
      "opening" => A.new().standing,
      "body" => body,
      "brace" => "bracing flat page",
      "yt" => false,
      "seat" => nil,
      "offices" => %{},
      "turns" => [],
      "footings" => [],
      "completions" => [],
      "active" => nil,
      "pointing" => nil,
      "tool_ancestry" => [],
      "events" => []
    }

  def operate(s, rev, c) do
    cond do
      rev != s["revision"] -> {:error, :stale}
      rev >= 120 -> {:error, :limit}
      true -> command(s, c)
    end
  end

  defp command(s, {:pull, dx, dy}) when is_number(dx) and is_number(dy) do
    with {:ok, m} <-
           A.operate(A.restore(s["opening"]), {:opening_pull, %{"dx" => dx, "dy" => dy}}),
         do: save(s, %{"op" => "pull", "dx" => dx, "dy" => dy}, %{s | "opening" => m.standing})
  end

  defp command(s, :puff) do
    with {:ok, m} <- A.operate(A.restore(s["opening"]), :puff),
         do: save(s, %{"op" => "puff"}, %{s | "opening" => m.standing})
  end

  defp command(s, :pull_brace) do
    if A.puffed?(A.restore(s["opening"])) and s["brace"] != "held as Quilling Stitching Needle" do
      with {:ok, body} <- SnailBody.operate(s["body"], :take),
           do:
             save(s, %{"op" => "pull-brace"}, %{
               s
               | "body" => body,
                 "brace" => "held as Quilling Stitching Needle",
                 "tool_ancestry" =>
                   s["tool_ancestry"] ++
                     [
                       %{
                         "source" => "zeroeth-first-arch-diagonal-brace",
                         "material_identity" => "diagonal-brace-to-Quilling-Needle",
                         "needle_piece" => body["held"],
                         "labor" => "Human pull UP",
                         "opening_source" => "first-puffing-accomplished"
                       }
                     ]
             })
    else
      {:error, :opening_or_held}
    end
  end

  defp command(s, {:quill, text}) do
    with true <- s["brace"] == "held as Quilling Stitching Needle",
         {:ok, body} <- SnailBody.operate(s["body"], {:quill, text}) do
      save(s, %{"op" => "quill", "text" => text}, %{s | "body" => body, "yt" => true})
    else
      _ -> {:error, :human_labor_required}
    end
  end

  defp command(s, {:body, c}) do
    permitted = c == :return or match?({:gather, _}, c) or (s["yt"] and match?({:withdraw, _}, c))

    with true <- permitted, {:ok, b} <- SnailBody.operate(s["body"], c) do
      encoded =
        case c do
          :return -> %{"action" => "return"}
          {k, n} -> %{"action" => Atom.to_string(k), "amount" => n}
        end

      save(s, %{"op" => "body", "command" => encoded}, %{
        s
        | "body" => b,
          "brace" =>
            if(c == :return, do: "seated in Inkwell; brace ancestry retained", else: s["brace"])
      })
    else
      _ -> {:error, :needle_or_labor}
    end
  end

  defp command(s, :seat) do
    if A.puffed?(A.restore(s["opening"])) and is_nil(s["seat"]) do
      g = SnailBody.model(s["body"], 90, 0)

      # Center the new datum in the existing Snail void, rather than silently
      # inheriting the earlier off-axis Craft/radial-tunnel eye coordinates.
      eye = [0, Enum.at(g.within_eye, 1), 0]
      receiver = Enum.zip_with(g.fold.tunnel_axis, g.fold.normal, fn v, n -> v + 0.5 * n end)
      delta = Enum.zip_with(receiver, eye, &(&1 - &2))
      distance = :math.sqrt(Enum.sum(Enum.map(delta, &(&1 * &1))))

      seat = %{
        "id" => "#{s["id"]}-seat",
        "room" => "one-snail-house",
        "datum" => [3, 3],
        "reference_dimensions" => [6, 6],
        "eye" => eye,
        "forward" => Enum.map(delta, &(&1 / distance)),
        "pittoning" => "locked into this room; not a new RE-STEP",
        "reference_to_body" => [
          [1 / 6, 0, 0, hd(eye) - 0.5],
          [0, 0, -1, Enum.at(eye, 1)],
          [0, 1 / 6, 0, Enum.at(eye, 2) - 0.5],
          [0, 0, 0, 1]
        ],
        "registration" =>
          "proposed six-reference-units to one body unit; explicit midpoint-to-central-Snail-void registration; earlier Craft coordinates not assumed"
      }

      save(s, %{"op" => "seat"}, %{s | "seat" => seat})
    else
      {:error, :seat}
    end
  end

  defp command(s, {:appoint, office}) when office in ~w(xt yt) do
    if A.puffed?(A.restore(s["opening"])) and !Map.has_key?(s["offices"], office) do
      role = if office == "xt", do: WedgingRehearsal.author(), else: WedgingRehearsal.pretending()

      o = %{
        "id" => "#{s["id"]}-#{office}-office",
        "office" => if(office == "xt", do: "XT Furnishing COB", else: "YT Traversaling COB"),
        "TOWARD" => role,
        "FROM" => "Human WITH Terrestrial Computer upon Ground",
        "agent" => false,
        "meaning" => "office appointment; not an XT/YT geometric bearing"
      }

      save(s, %{"op" => "appoint", "office" => office}, %{
        s
        | "offices" => Map.put(s["offices"], office, o)
      })
    else
      {:error, :appointment}
    end
  end

  defp command(s, :provide) do
    cond do
      !s["yt"] or is_nil(s["seat"]) or !Map.has_key?(s["offices"], "xt") ->
        {:error, :labor_seat_office}

      length(s["turns"]) >= 2 ->
        {:error, :bounded_two_turns}

      Enum.any?(s["turns"], &(&1["status"] not in ~w(resolved rehearsed))) ->
        {:error, :finish_previous_turn}

      true ->
        n = length(s["turns"])
        id = "#{s["id"]}-turn-#{n + 1}"
        frame = SnailBody.arc_frame(n / 6) |> Jason.encode!() |> Jason.decode!()

        turn = %{
          "id" => id,
          "office" => s["offices"]["xt"]["id"],
          "status" => "furnishing",
          "arc" => "snail-radial-arc-v1",
          "interval" => [n / 6, (n + 1) / 6],
          "addresses" => [n / 6 * SnailBody.arc_length(), (n + 1) / 6 * SnailBody.arc_length()],
          "passage" => "continuous-spooning-scooping",
          "quarter" => n,
          "target_fold" => 90,
          "motion_order" => [0, 0.5, 1],
          "cubical" => %{
            "id" => id <> "-cubical",
            "frame" => frame,
            "meaning" => "differentiated CUBICAL standing, no literal box required"
          },
          "material" => nil,
          "registration" => nil
        }

        save(s, %{"op" => "provide"}, %{s | "turns" => s["turns"] ++ [turn]})
    end
  end

  defp command(s, {:register, material}) when is_binary(material) do
    turn = List.last(s["turns"])

    cond do
      is_nil(turn) or turn["status"] != "furnishing" ->
        {:error, :cubical_first}

      !Enum.any?(s["body"]["material"], &(&1["id"] == material)) ->
        {:error, :material_identity}

      true ->
        reg = %{
          "source_material" => material,
          "cubical" => turn["cubical"]["id"],
          "stages" =>
            ~w(appointed loading-deck groundward upward-relay receiver monitor encounter),
          "identity" => "one authored item; presentations are registrations, not copies"
        }

        next =
          update_turn(
            s,
            turn["id"],
            &%{&1 | "material" => material, "status" => "emplacing", "registration" => reg}
          )

        save(s, %{"op" => "register", "material" => material}, next)
    end
  end

  defp command(s, :settle) do
    t = List.last(s["turns"])

    if t && t["status"] == "emplacing",
      do: save(s, %{"op" => "settle"}, update_turn(s, t["id"], &%{&1 | "status" => "provided"})),
      else: {:error, :placement}
  end

  defp command(s, {:take, id, passage, mode, human})
       when mode in ~w(rehearsal actual) and is_binary(human) and byte_size(human) in 1..80 do
    human = String.trim(human)
    t = Enum.find(s["turns"], &(&1["id"] == id))

    cond do
      human == "" ->
        {:error, :human_relation}

      !Map.has_key?(s["offices"], "yt") or is_nil(t) or is_nil(s["seat"]) ->
        {:error, :appointment}

      s["active"] != nil or t["status"] not in ~w(provided rehearsed resolved) ->
        {:error, :turn}

      passage != t["passage"] ->
        {:error, :unfurnished_alternate}

      Enum.any?(
        s["completions"],
        &(&1["turn"] == id && &1["mode"] == mode && &1["human"] == human)
      ) ->
        {:error, :already_completed}

      true ->
        active = %{
          "turn" => id,
          "office" => s["offices"]["yt"]["id"],
          "human" => human,
          "mode" => mode,
          "position" => 0,
          "passage" => passage,
          "material" => t["material"]
        }

        save(
          s,
          %{"op" => "take", "turn" => id, "passage" => passage, "mode" => mode, "human" => human},
          s |> update_turn(id, &%{&1 | "status" => "taking"}) |> Map.put("active", active)
        )
    end
  end

  defp command(s, :advance) do
    a = s["active"]

    if a && a["position"] < 2,
      do:
        save(s, %{"op" => "advance"}, %{s | "active" => %{a | "position" => a["position"] + 1}}),
      else: {:error, :appointed_motion}
  end

  defp command(s, :complete) do
    a = s["active"]

    if a && a["position"] == 2 do
      t = Enum.find(s["turns"], &(&1["id"] == a["turn"]))

      completion =
        Map.take(a, ~w(turn office human mode material))
        |> Map.put("id", "#{s["id"]}-completion-#{s["revision"] + 1}")

      footing = %{
        "id" => completion["id"] <> "-footing",
        "turn" => t["id"],
        "human" => a["human"],
        "office" => a["office"],
        "material" => t["material"],
        "arc" => t["arc"],
        "address" => List.last(t["addresses"]),
        "point" => SnailBody.arc_point(List.last(t["interval"])),
        "kind" => "actual bounded Scooping Spooning Footing; not a protected RE-STEP"
      }

      next =
        s
        |> update_turn(
          t["id"],
          &%{&1 | "status" => if(a["mode"] == "actual", do: "resolved", else: "rehearsed")}
        )
        |> Map.put("active", nil)
        |> Map.put("completions", s["completions"] ++ [completion])

      next =
        if a["mode"] == "actual",
          do: Map.put(next, "footings", s["footings"] ++ [footing]),
          else: next

      save(s, %{"op" => "complete"}, next)
    else
      {:error, :completion_not_scrubbing}
    end
  end

  defp command(s, :point) do
    if s["seat"] do
      g = SnailBody.model(s["body"])
      target = Enum.zip_with(g.fold.tunnel_axis, g.fold.normal, fn v, n -> v + 0.5 * n end)

      p = %{
        "id" => "#{s["id"]}-pointing",
        "FROM" => s["seat"]["id"],
        "TOWARD" => "Quilling Stitching and prospective PINNING",
        "target" => target,
        "ancestry" => ["zeroeth-first-arch", "diagonal-brace", "Quilling Stitching Needle"],
        "pinning" => false
      }

      save(s, %{"op" => "point"}, %{s | "pointing" => p})
    else
      {:error, :seat}
    end
  end

  defp command(_, _), do: {:error, :unavailable}

  defp update_turn(s, id, f),
    do: Map.update!(s, "turns", &Enum.map(&1, fn t -> if t["id"] == id, do: f.(t), else: t end))

  defp save(s, e, next) do
    next = record_standing(s, e, next)
    {:ok, %{next | "revision" => s["revision"] + 1, "events" => s["events"] ++ [e]}}
  end

  # Every integration furnishing/acquisition uses the existing constitutional
  # event/course/THROUGH-BY-WAY-OF builder. Arrays above are indexes into this graph.
  defp record_standing(s, e, n) do
    turn = List.last(n["turns"])

    node = fn id, subject, predicate, object, through ->
      %{
        id: id,
        subject: subject,
        predicate: predicate,
        object: object,
        through: through,
        role: "furnishing"
      }
    end

    material = List.last(n["body"]["material"])
    event_id = "#{s["id"]}-weave-#{s["revision"] + 1}"

    spec =
      case e["op"] do
        "puff" ->
          {["first-puffing-accomplished"],
           [
             node.(
               "zeroeth-first-arch",
               "first archway",
               "AVAILABLE FOR XT TOWARD YT",
               "ordinary page bracing",
               "first-puffing-accomplished"
             ),
             node.(
               "zeroeth-second-arch",
               "second archway",
               "UP OVER ACROSS FOR HOLDING",
               "TC taking",
               "zeroeth-first-arch"
             ),
             node.(
               "zeroeth-brace",
               "diagonal-brace-to-Quilling-Needle",
               "BRACES",
               "ordinary flat page",
               "zeroeth-first-arch"
             )
           ]}

        "pull-brace" ->
          {["zeroeth-brace"],
           [
             node.(
               n["body"]["held"],
               "diagonal-brace-to-Quilling-Needle",
               "HUMAN PULLS UP AND PRETENDS AS",
               "Quilling Stitching Needle",
               "zeroeth-brace"
             )
           ]}

        "quill" ->
          {[n["body"]["held"]],
           [
             node.(
               material["id"],
               "Human",
               "STRINGS UP WORDS",
               material["text"],
               n["body"]["held"]
             ),
             node.(
               material["id"] <> "-YT",
               "YT",
               "BECOMES AVAILABLE THROUGH LABOR",
               material["id"],
               material["id"]
             )
           ]}

        "seat" ->
          {["human-standing"],
           [
             node.(
               n["seat"]["id"],
               "Traversaling Seat",
               "PITTONING LOCK INTO",
               "one-snail-house",
               "human-standing"
             )
           ]}

        "appoint" ->
          o = n["offices"][e["office"]]
          {["cob-for"], [node.(o["id"], o["office"], "APPOINTED TOWARD", o["TOWARD"], "cob-for")]}

        "provide" ->
          {[turn["office"]],
           [
             node.(
               turn["cubical"]["id"],
               turn["office"],
               "FURNISHES CUBICAL DIFFERENTIATION",
               turn["arc"],
               turn["office"]
             ),
             node.(
               turn["id"],
               turn["office"],
               "PROVIDES TURN",
               turn["passage"],
               turn["cubical"]["id"]
             )
           ]}

        "register" ->
          {[turn["cubical"]["id"], turn["material"]],
           [
             node.(
               turn["id"] <> "-registered",
               turn["material"],
               "REGISTERED TO CUBICAL STANDING",
               turn["cubical"]["id"],
               turn["cubical"]["id"]
             )
           ]}

        "settle" ->
          {[turn["id"] <> "-registered"],
           [
             node.(
               turn["id"] <> "-staging",
               turn["material"],
               "STANDING AND STAGING FOR STANDING",
               turn["id"],
               turn["id"] <> "-registered"
             )
           ]}

        "take" ->
          id = event_id <> "-taking"
          t = Enum.find(n["turns"], &(&1["id"] == e["turn"]))

          {[t["id"] <> "-staging", n["offices"]["yt"]["id"]],
           [
             node.(
               id,
               n["offices"]["yt"]["id"],
               "INHERITS AND TAKES",
               t["id"],
               t["id"] <> "-staging"
             ),
             node.(
               event_id <> "-held-UP",
               "zeroeth-second-arch",
               "HOLDS TRANSVERSE BEARING UP BECAUSE",
               "TC taking",
               "zeroeth-second-arch"
             )
           ]}

        "complete" ->
          a = s["active"]
          c = List.last(n["completions"])
          f = List.last(n["footings"])
          id = if a["mode"] == "actual", do: f["id"], else: c["id"]

          {[a["appointment"]],
           [
             node.(
               id,
               a["human"],
               if(a["mode"] == "actual",
                 do: "ACQUIRES OWN SCOOPING SPOONING FOOTING",
                 else: "COMPLETES REHEARSAL WITHOUT ACQUISITION"
               ),
               a["turn"],
               a["appointment"]
             )
           ]}

        "point" ->
          {[n["seat"]["id"], "zeroeth-brace"],
           [
             node.(
               event_id <> "-pointing",
               n["pointing"]["id"],
               "POINTS TOWARD PROSPECTIVE PINNING",
               "no actual PINNING",
               n["seat"]["id"]
             )
           ]}

        "body" ->
          piece = List.last(n["body"]["pieces"])["id"]

          {[piece],
           [
             node.(
               event_id <> "-line",
               piece,
               "INKWELL / MEASURED BOBBIN " <> e["command"]["action"],
               "not actual PINNING",
               piece
             )
           ]}

        _ ->
          nil
      end

    if spec do
      {deps, nodes} = spec

      m =
        A.furnish(
          A.restore(n["opening"]),
          event_id,
          "Constitutioning Human WITH appointed office",
          "Explicit " <> e["op"],
          "bounded Snail House integration",
          deps,
          event_id <> "-course",
          nodes
        )

      n = Map.put(n, "opening", m.standing)

      n =
        if e["op"] == "take",
          do: put_in(n, ["active", "appointment"], event_id <> "-taking"),
          else: n

      if e["op"] == "provide" do
        update_in(
          n,
          ["opening", "relations", turn["cubical"]["id"]],
          &Map.merge(&1, %{
            "arc" => turn["arc"],
            "interval" => turn["interval"],
            "addresses" => turn["addresses"],
            "frame" => turn["cubical"]["frame"]
          })
        )
      else
        n
      end
    else
      n
    end
  end

  def fold_allowed?(s, q, angle) do
    !Enum.any?(
      s["turns"],
      &(&1["status"] == "emplacing" && &1["quarter"] == q && angle != &1["target_fold"])
    )
  end

  def export(s), do: Jason.encode!(%{"schema" => "snail-weave-v1", "state" => s}, pretty: true)

  def import(json) when is_binary(json) and byte_size(json) <= 8_000_000 do
    with {:ok,
          %{
            "schema" => "snail-weave-v1",
            "state" => %{"id" => id, "events" => events, "body" => %{"id" => body_id}} = s
          }} <- Jason.decode(json),
         {:ok, _} <- Ecto.UUID.cast(id),
         {:ok, _} <- Ecto.UUID.cast(body_id),
         true <- is_list(events) && length(events) <= 120 do
      b = SnailBody.new() |> Map.put("id", body_id)

      result =
        Enum.reduce_while(events, {:ok, initial(id, b)}, fn e, {:ok, acc} ->
          c = decode(e)

          case operate(acc, acc["revision"], c) do
            {:ok, n} -> {:cont, {:ok, n}}
            _ -> {:halt, :invalid}
          end
        end)

      case result do
        {:ok, expected} when expected == s -> {:ok, expected}
        _ -> {:error, :invalid_witness}
      end
    else
      _ -> {:error, :invalid_witness}
    end
  end

  def import(_), do: {:error, :invalid_witness}

  defp decode(e) do
    case e do
      %{"op" => "pull", "dx" => x, "dy" => y} when map_size(e) == 3 ->
        {:pull, x, y}

      %{"op" => "quill", "text" => text} when map_size(e) == 2 ->
        {:quill, text}

      %{"op" => "appoint", "office" => o} when map_size(e) == 2 ->
        {:appoint, o}

      %{"op" => "register", "material" => m} when map_size(e) == 2 ->
        {:register, m}

      %{"op" => "take", "turn" => t, "passage" => p, "mode" => m, "human" => h}
      when map_size(e) == 5 ->
        {:take, t, p, m, h}

      %{"op" => "body", "command" => %{"action" => "return"}} when map_size(e) == 2 ->
        {:body, :return}

      %{"op" => "body", "command" => %{"action" => a, "amount" => n} = c}
      when map_size(e) == 2 and map_size(c) == 2 ->
        case a do
          "withdraw" -> {:body, {:withdraw, n}}
          "gather" -> {:body, {:gather, n}}
          _ -> nil
        end

      %{"op" => op} when map_size(e) == 1 ->
        Map.get(
          %{
            "puff" => :puff,
            "pull-brace" => :pull_brace,
            "seat" => :seat,
            "provide" => :provide,
            "settle" => :settle,
            "advance" => :advance,
            "complete" => :complete,
            "point" => :point
          },
          op
        )

      _ ->
        nil
    end
  end
end
