defmodule PublicSituationMachineTurnZero.Workshop.LegacyV1 do
  @moduledoc "Frozen schema-1 reader/validator. Historical geometry is never silently rewritten."
  alias PublicSituationMachineTurnZero.Workshop.LegacyGeometry, as: Geometry
  @views ~w(front reverse plan lower)
  def views, do: @views

  def new do
    build(Ecto.UUID.generate(), 0, %{"tc" => 0, "ch" => 12}, [
      %{
        "revision" => 0,
        "action" => "initial",
        "actor" => "workshop constructor",
        "positions" => %{"tc" => 0, "ch" => 12}
      }
    ])
    |> Map.merge(%{"lock" => nil, "witnesses" => []})
  end

  defp build(id, revision, positions, provenance) do
    %{
      "schema_version" => 1,
      "construction_id" => id,
      "revision" => revision,
      "coordinates" => %{
        "origin" => [0, 0, 0],
        "x" => "along rail TC toward CH",
        "y" => "UP",
        "z" => "transverse",
        "unit" => "one provisional extent; not physical distance"
      },
      "positions" => positions,
      "rail" => Geometry.rail(),
      "entities" => Geometry.regions(positions),
      "relationships" => Geometry.relationships(),
      "reservations" => Geometry.reservations(),
      "turn" => %{"local" => 0, "anchored_index" => 0, "status" => "reserved; no turn operation"},
      "provenance" => provenance
    }
  end

  def operate(model, revision, command) do
    cond do
      revision != model["revision"] -> {:error, :stale_revision}
      model["revision"] >= 100 and command != :release -> {:error, :revision_limit}
      true -> change(model, command)
    end
  end

  defp change(%{"lock" => nil} = m, {:move, id, position})
       when id in ["tc", "ch"] and is_number(position) and position >= 0 and position <= 12 do
    if m["positions"][id] == position,
      do: {:ok, m},
      else: {:ok, advance(m, "move", Map.put(m["positions"], id, position))}
  end

  defp change(%{"lock" => nil} = m, :reset),
    do: {:ok, advance(m, "reset", %{"tc" => 0, "ch" => 12})}

  defp change(%{"lock" => nil} = m, :lock) do
    next = advance(m, "lock", m["positions"])
    id = "#{m["construction_id"]}-lock-#{next["revision"]}"

    witness = %{
      "id" => id,
      "revision" => next["revision"],
      "snapshot" => Map.drop(next, ["lock", "witnesses"])
    }

    {:ok, %{next | "lock" => id, "witnesses" => next["witnesses"] ++ [witness]}}
  end

  defp change(%{"lock" => lock} = m, :release) when is_binary(lock),
    do: {:ok, %{advance(m, "release", m["positions"]) | "lock" => nil}}

  defp change(_, _), do: {:error, :unavailable}

  defp advance(m, action, positions) do
    revision = m["revision"] + 1

    event = %{
      "revision" => revision,
      "action" => action,
      "actor" => "Human construction control",
      "positions" => positions
    }

    build(m["construction_id"], revision, positions, m["provenance"] ++ [event])
    |> Map.merge(Map.take(m, ["lock", "witnesses"]))
  end

  def export(model, view),
    do:
      Jason.encode!(
        %{"schema_version" => 1, "construction" => model, "view" => %{"regarding" => view}},
        pretty: true
      )

  def import(json) when is_binary(json) and byte_size(json) <= 2_000_000 do
    with {:ok, %{"schema_version" => 1, "construction" => m, "view" => %{"regarding" => view}}} <-
           Jason.decode(json),
         true <- view in @views,
         true <- valid_model?(m),
         do: {:ok, m, view},
         else: (_ -> {:error, :invalid_witness})
  end

  def import(_), do: {:error, :invalid_witness}

  defp valid_snapshot?(s) when is_map(s) do
    with {:ok, _} <- Ecto.UUID.cast(s["construction_id"]),
         r when is_integer(r) and r >= 0 and r <= 101 <- s["revision"],
         %{"tc" => tc, "ch" => ch} = p <- s["positions"],
         true <- valid_position?(tc) and valid_position?(ch),
         events when is_list(events) <- s["provenance"],
         true <- length(events) == r + 1,
         true <- valid_events?(events, p),
         true <- s == build(s["construction_id"], r, p, events),
         do: true,
         else: (_ -> false)
  end

  defp valid_snapshot?(_), do: false
  defp valid_position?(n), do: is_number(n) and n >= 0 and n <= 12

  defp valid_events?(events, positions) do
    initial = %{
      "revision" => 0,
      "action" => "initial",
      "actor" => "workshop constructor",
      "positions" => %{"tc" => 0, "ch" => 12}
    }

    result =
      events
      |> Enum.drop(1)
      |> Enum.with_index(1)
      |> Enum.reduce_while({initial["positions"], false}, fn {event, i}, {prior, locked} ->
        case event do
          %{
            "revision" => ^i,
            "action" => action,
            "actor" => "Human construction control",
            "positions" => %{"tc" => tc, "ch" => ch} = p
          }
          when map_size(event) == 4 and map_size(p) == 2 ->
            valid =
              valid_position?(tc) and valid_position?(ch) and (i <= 100 or action == "release") and
                case action do
                  "move" -> !locked and Enum.count(["tc", "ch"], &(p[&1] != prior[&1])) == 1
                  "reset" -> !locked and p == initial["positions"]
                  "lock" -> !locked and p == prior
                  "release" -> locked and p == prior
                  _ -> false
                end

            if valid,
              do:
                {:cont,
                 {p,
                  if(action == "lock",
                    do: true,
                    else: if(action == "release", do: false, else: locked)
                  )}},
              else: {:halt, :invalid}

          _ ->
            {:halt, :invalid}
        end
      end)

    hd(events) == initial and
      case result do
        {p, _} -> p == positions
        _ -> false
      end
  end

  defp valid_model?(m) when is_map(m) do
    base = Map.drop(m, ["lock", "witnesses"])

    with true <- valid_snapshot?(base),
         records when is_list(records) <- m["witnesses"],
         true <- length(records) <= 50,
         true <-
           Enum.all?(records, fn record ->
             case record do
               %{"id" => id, "revision" => r, "snapshot" => s} when map_size(record) == 3 ->
                 valid_snapshot?(s) and s["construction_id"] == m["construction_id"] and
                   s["revision"] == r and r <= m["revision"] and
                   id == "#{m["construction_id"]}-lock-#{r}" and
                   List.last(s["provenance"])["action"] == "lock" and
                   s["provenance"] == Enum.take(m["provenance"], r + 1)

               _ ->
                 false
             end
           end),
         lock_events <- Enum.filter(m["provenance"], &(&1["action"] == "lock")),
         true <- Enum.map(records, & &1["revision"]) == Enum.map(lock_events, & &1["revision"]),
         expected_lock <-
           if(List.last(m["provenance"])["action"] == "lock",
             do: List.last(records)["id"],
             else: nil
           ),
         true <- m["lock"] == expected_lock,
         true <- Map.keys(m) |> Enum.sort() == Enum.sort(Map.keys(base) ++ ["lock", "witnesses"]),
         true <- is_nil(m["lock"]) or List.last(records)["snapshot"] == base,
         do: true,
         else: (_ -> false)
  end

  defp valid_model?(_), do: false
end
