defmodule PublicSituationMachineTurnZero.Workshop.Rehearsal do
  @moduledoc "Deterministic five-index test Situationing, separate from construction and constitutional operations."
  alias PublicSituationMachineTurnZero.Workshop.{Projection, Steeling}
  def new, do: fresh(Ecto.UUID.generate(), 0, nil) |> Map.put("previous_runs", [])

  defp fresh(id, basis, reset_from),
    do: %{
      "version" => 1,
      "id" => id,
      "basis_revision" => basis,
      "revision" => basis,
      "reset_from" => reset_from,
      "progress" => 0.0,
      "collected" => [],
      "footings" => [],
      "events" => [],
      "ready" => false
    }

  def operate(s, revision, command, model) do
    cond do
      revision != s["revision"] ->
        {:error, :stale_rehearsal}

      command == :reset and length(s["previous_runs"]) < 20 ->
        {:ok,
         fresh(Ecto.UUID.generate(), revision + 1, s["id"])
         |> Map.put("previous_runs", s["previous_runs"] ++ [Map.delete(s, "previous_runs")])}

      length(s["events"]) >= 100 ->
        {:error, :rehearsal_limit}

      true ->
        change(s, command, model)
    end
  end

  defp change(s, {:collect, index}, model) when is_integer(index) and index in 1..25 do
    cond do
      index in s["collected"] ->
        {:ok, s}

      s["ready"] ->
        {:error, :five_acquired}

      true ->
        footing = footing(s, index, model, model["revision"])
        {:ok, append(s, "collect", footing)}
    end
  end

  defp change(s, {:progress, progress}, _)
       when is_number(progress) and progress >= 0 and progress <= 1 do
    if s["progress"] == progress, do: {:ok, s}, else: {:ok, append(s, "progress", progress)}
  end

  defp change(_, _, _), do: {:error, :unavailable_rehearsal}

  defp append(s, action, value) do
    revision = s["revision"] + 1
    event = %{"revision" => revision, "action" => action, "value" => value}
    next = %{s | "revision" => revision, "events" => s["events"] ++ [event]}

    case action do
      "progress" ->
        %{next | "progress" => value}

      "collect" ->
        %{
          next
          | "collected" => value["after"],
            "footings" => s["footings"] ++ [value],
            "ready" => length(value["after"]) == 5
        }
    end
  end

  defp footing(s, index, model, construction_revision) do
    event = Enum.at(model["provenance"], construction_revision)
    station = Enum.at(Steeling.model(event["parameters"])["stations"], index - 1)
    sequence = length(s["collected"]) + 1

    %{
      "id" => "#{s["id"]}-footing-#{sequence}",
      "kind" => "Little ROUNDING Footing / workshop test transition",
      "sequence" => sequence,
      "station_index" => index,
      "station_id" => station["id"],
      "letter" => station["letter"],
      "group" => station["group"],
      "before" => s["collected"],
      "after" => s["collected"] ++ [index],
      "construction_revision" => construction_revision,
      "station_point" => station["point"],
      "source_reference" => "lower-slot-#{sequence}",
      "source_point" => Projection.source_point(sequence),
      "attachment" => "provisional indexed-station to staging association, not a physical joint"
    }
  end

  def companion(s) do
    case length(s["collected"]) do
      0 -> "Shall we collect a letter?"
      5 -> "Five letters! Shall we see about RE-STEPPING?"
      n -> "#{n} letters! #{5 - n} more to go."
    end
  end

  def valid?(s, model) when is_map(s) do
    with previous when is_list(previous) and length(previous) <= 20 <- s["previous_runs"],
         runs <- previous ++ [Map.delete(s, "previous_runs")],
         true <- Enum.all?(runs, &valid_run?(&1, model)),
         true <- length(Enum.uniq_by(runs, & &1["id"])) == length(runs),
         true <- hd(runs)["basis_revision"] == 0 and is_nil(hd(runs)["reset_from"]),
         true <-
           Enum.all?(Enum.chunk_every(runs, 2, 1, :discard), fn [a, b] ->
             b["basis_revision"] == a["revision"] + 1 and b["reset_from"] == a["id"]
           end),
         do: true,
         else: (_ -> false)
  end

  def valid?(_, _), do: false

  defp valid_run?(s, model) when is_map(s) do
    with {:ok, _} <- Ecto.UUID.cast(s["id"]),
         basis when is_integer(basis) and basis >= 0 and basis <= 2100 <- s["basis_revision"],
         events when is_list(events) and length(events) <= 100 <- s["events"] do
      initial = fresh(s["id"], basis, s["reset_from"])

      result =
        Enum.reduce_while(events, initial, fn event, state ->
          case event do
            %{"revision" => r, "action" => "progress", "value" => p}
            when map_size(event) == 3 and is_number(p) and p >= 0 and p <= 1 ->
              if r == state["revision"] + 1 and p != state["progress"],
                do: {:cont, append(state, "progress", p)},
                else: {:halt, :invalid}

            %{
              "revision" => r,
              "action" => "collect",
              "value" => %{"station_index" => index, "construction_revision" => cr} = f
            }
            when map_size(event) == 3 and is_integer(index) and index in 1..25 and is_integer(cr) and
                   cr >= 0 ->
              if r == state["revision"] + 1 and cr <= model["revision"] and
                   index not in state["collected"] and !state["ready"] and
                   f == footing(state, index, model, cr),
                 do: {:cont, append(state, "collect", f)},
                 else: {:halt, :invalid}

            _ ->
              {:halt, :invalid}
          end
        end)

      result == s
    else
      _ -> false
    end
  end

  defp valid_run?(_, _), do: false
end
