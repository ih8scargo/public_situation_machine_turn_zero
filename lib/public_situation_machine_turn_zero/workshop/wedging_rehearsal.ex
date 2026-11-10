defmodule PublicSituationMachineTurnZero.Workshop.WedgingRehearsal do
  @moduledoc "Bounded experimental appointments/furnishings/traversal witnesses for one Snail House. No protected constitutional operations."
  alias PublicSituationMachineTurnZero.Workshop.WedgingGeometry, as: G
  @author "This One Authoring Constitutioning Human"
  @pretending "This One Pretendinging Constitutioning Human"
  def author, do: @author
  def pretending, do: @pretending
  def new, do: initial(Ecto.UUID.generate())

  defp initial(id),
    do: %{
      "version" => 1,
      "id" => id,
      "revision" => 0,
      "furnishing" => nil,
      "traversaling" => nil,
      "founding" => nil,
      "proposal" => nil,
      "confirmed" => [],
      "active" => nil,
      "footings" => [],
      "traversals" => [],
      "events" => []
    }

  def operate(s, rev, command) do
    cond do
      rev != s["revision"] -> {:error, :stale}
      rev >= 200 -> {:error, :limit}
      true -> command(s, command)
    end
  end

  defp command(s, {:appoint, office}) when office in ~w(furnishing traversaling) do
    cond do
      s[office] != nil -> {:ok, s}
      office == "traversaling" and s["confirmed"] == [] -> {:error, :unfurnished}
      true -> event(s, %{"action" => "appoint", "office" => office})
    end
  end

  defp command(s, {:propose, p, turn, locality, purpose}) do
    cond do
      !is_nil(s["proposal"]) ->
        {:error, :discard_or_revise}

      s["confirmed"] != [] and
          Enum.count(s["footings"], &(&1["pair"] == hd(s["confirmed"])["id"])) < 2 ->
        {:error, :minimum_pair}

      is_nil(s["furnishing"]) ->
        {:error, :appointment}

      length(s["confirmed"]) >= 4 ->
        {:error, :capacity}

      !G.valid_pair_parameters?(p) or turn not in 0..3 or locality not in ~w(mouth forward) or
        !is_binary(purpose) or byte_size(purpose) > 2000 ->
        {:error, :parameters}

      !G.available_pair?(p, turn, locality(locality)) ->
        {:error, :unavailable}

      true ->
        event(s, %{
          "action" => "propose",
          "parameters" => p,
          "turn" => turn,
          "locality" => locality,
          "purpose" => purpose
        })
    end
  end

  defp command(s, {:revise, p, purpose}) do
    proposal = s["proposal"]

    cond do
      is_nil(proposal) ->
        {:error, :proposal}

      !G.valid_pair_parameters?(p) or !is_binary(purpose) or byte_size(purpose) > 2000 ->
        {:error, :parameters}

      !G.available_pair?(p, proposal["turn"], locality(proposal["locality"])) ->
        {:error, :unavailable}

      true ->
        event(s, %{"action" => "revise", "parameters" => p, "purpose" => purpose})
    end
  end

  defp command(s, :discard) do
    if s["proposal"], do: event(s, %{"action" => "discard"}), else: {:error, :proposal}
  end

  defp command(s, :confirm) do
    if s["proposal"] do
      g = G.pair(s["proposal"]["parameters"])

      cond do
        !g["within_reserved"] ->
          {:error, :region}

        g["clearance"] < 0.002 ->
          {:error, :clearance}

        Enum.any?(s["confirmed"], fn r ->
          G.conflict_clearance(g, G.pair(r["parameters"])) < 0.002
        end) ->
          {:error, :collision}

        true ->
          event(s, %{"action" => "confirm"})
      end
    else
      {:error, :proposal}
    end
  end

  defp command(s, {:enter, id, course}) when course in ~w(up_over ordinary) do
    cond do
      is_nil(s["traversaling"]) -> {:error, :appointment}
      !Enum.any?(s["confirmed"], &(&1["id"] == id)) -> {:error, :unfurnished}
      true -> event(s, %{"action" => "enter", "pair" => id, "course" => course})
    end
  end

  defp command(s, {:progress, t}) when is_number(t) and t >= 0 and t <= 1 do
    if s["active"], do: event(s, %{"action" => "progress", "value" => t}), else: {:error, :course}
  end

  defp command(_, _), do: {:error, :command}
  defp locality("mouth"), do: :mouth
  defp locality("forward"), do: :forward
  defp event(s, e), do: {:ok, apply_event(s, e)}

  defp apply_event(s, e) do
    revision = s["revision"] + 1

    next =
      case e do
        %{"action" => "appoint", "office" => office} ->
          human = if office == "furnishing", do: @author, else: @pretending

          name =
            if office == "furnishing",
              do: "Stewardly Furnishing Co-Captain COB",
              else: "Stewardly Co-Captain Co-Bobbinning Traversaling Thing"

          Map.put(s, office, %{
            "id" => "#{s["id"]}-#{office}",
            "office" => name,
            "TOWARD" => human,
            "FROM" => "HERE alongside WITH Human / real Terrestrial Computer",
            "revision" => revision,
            "embodiment" => "separate appointment, eventual shared embodiment open",
            "co_relations" => [
              "co-relationing",
              "co-ordinationing",
              "co-operationing",
              "co-officing-er"
            ]
          })

        %{"action" => "propose"} ->
          p = %{
            "id" => "pair-#{revision}",
            "parameters" => e["parameters"],
            "turn" => e["turn"],
            "locality" => e["locality"],
            "purpose" => e["purpose"],
            "author" => @author,
            "office" => s["furnishing"]["id"],
            "status" => "candidate; no confirmed standing",
            "revision" => revision
          }

          %{s | "proposal" => p}

        %{"action" => "revise"} ->
          %{
            s
            | "proposal" =>
                Map.merge(s["proposal"], %{
                  "parameters" => e["parameters"],
                  "purpose" => e["purpose"],
                  "revision" => revision
                })
          }

        %{"action" => "discard"} ->
          %{s | "proposal" => nil}

        %{"action" => "confirm"} ->
          founding =
            s["founding"] ||
              %{
                "id" => "#{s["id"]}-inaugural-pittoning",
                "point" => [0, 0, 0],
                "relation" => "FROM HERE ALONG THROUGH HERE",
                "office" =>
                  "local purchase; first completed Little ROUNDING Footing inherits PITTONING",
                "first_footing" => nil,
                "created_at" => revision,
                "source_pair" => s["proposal"]["id"],
                "status" =>
                  "confirmed experimental founding relation; physical purchase unverified"
              }

          record =
            Map.merge(s["proposal"], %{
              "status" => "confirmed experimental furnishing",
              "confirmed_at" => revision,
              "pittoning" => founding["id"],
              "inherits" => if(s["founding"], do: founding["source_pair"], else: nil)
            })

          %{
            s
            | "founding" => founding,
              "confirmed" => s["confirmed"] ++ [record],
              "proposal" => nil
          }

        %{"action" => "enter"} ->
          %{
            s
            | "active" => %{
                "pair" => e["pair"],
                "course" => e["course"],
                "progress" => 0.0,
                "office" => s["traversaling"]["id"]
              }
          }

        %{"action" => "progress", "value" => t} ->
          next = %{s | "active" => %{s["active"] | "progress" => t}}

          if t == 1 and
               !Enum.any?(
                 s["footings"],
                 &(&1["pair"] == s["active"]["pair"] and &1["course"] == s["active"]["course"])
               ) do
            id = "#{s["id"]}-footing-#{length(s["footings"]) + 1}"
            record = Enum.find(s["confirmed"], &(&1["id"] == s["active"]["pair"]))
            course = G.pair(record["parameters"])[s["active"]["course"]]
            first = s["footings"] == []

            footing = %{
              "id" => id,
              "sequence" => length(s["footings"]) + 1,
              "pair" => record["id"],
              "course" => s["active"]["course"],
              "office" => s["traversaling"]["id"],
              "pittoning" => s["founding"]["id"],
              "holds_inaugural_office" => first,
              "return" => course.return,
              "HERE_ground_reference" => [0, 0, 0],
              "before" => Enum.map(s["footings"], & &1["id"]),
              "after" => Enum.map(s["footings"], & &1["id"]) ++ [id],
              "revision" => revision,
              "kind" =>
                "experimental Little ROUNDING Footing; not production constitutional acquisition"
            }

            founding =
              if first, do: Map.put(s["founding"], "first_footing", id), else: s["founding"]

            traversal = %{
              "pair" => record["id"],
              "course" => s["active"]["course"],
              "length" => course.length,
              "return" => course.return,
              "footing" => id,
              "source_furnishing" => record["id"],
              "office" => s["traversaling"]["id"]
            }

            %{
              next
              | "footings" => s["footings"] ++ [footing],
                "founding" => founding,
                "traversals" => s["traversals"] ++ [traversal]
            }
          else
            next
          end
      end

    %{next | "revision" => revision, "events" => s["events"] ++ [e]}
  end

  def export(s),
    do: Jason.encode!(%{"schema_version" => "wedging-round-two-v1", "state" => s}, pretty: true)

  def import(json) when is_binary(json) and byte_size(json) <= 2_000_000 do
    with {:ok,
          %{
            "schema_version" => "wedging-round-two-v1",
            "state" => %{"id" => id, "events" => events} = s
          }} <- Jason.decode(json),
         {:ok, _} <- Ecto.UUID.cast(id),
         true <- is_list(events) && length(events) <= 200 do
      result =
        Enum.reduce_while(events, {:ok, initial(id)}, fn e, {:ok, current} ->
          command =
            case e do
              %{"action" => "appoint", "office" => v} when map_size(e) == 2 ->
                {:appoint, v}

              %{
                "action" => "propose",
                "parameters" => p,
                "turn" => t,
                "locality" => l,
                "purpose" => x
              }
              when map_size(e) == 5 ->
                {:propose, p, t, l, x}

              %{"action" => "revise", "parameters" => p, "purpose" => x} when map_size(e) == 3 ->
                {:revise, p, x}

              %{"action" => "discard"} when map_size(e) == 1 ->
                :discard

              %{"action" => "confirm"} when map_size(e) == 1 ->
                :confirm

              %{"action" => "enter", "pair" => p, "course" => c} when map_size(e) == 3 ->
                {:enter, p, c}

              %{"action" => "progress", "value" => t} when map_size(e) == 2 ->
                {:progress, t}

              _ ->
                nil
            end

          case operate(current, current["revision"], command) do
            {:ok, next} when next != current -> {:cont, {:ok, next}}
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
end
