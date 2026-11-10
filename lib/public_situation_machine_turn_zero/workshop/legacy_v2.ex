defmodule PublicSituationMachineTurnZero.Workshop.LegacyV2 do
  @moduledoc "Frozen Assignment 02 / schema-2 compatibility reader and validator."
  alias PublicSituationMachineTurnZero.Workshop.{Geometry, Steeling, LegacyV1}
  @views ~w(front reverse plan lower transverse)
  def views, do: @views

  def legacy?(model), do: model["schema_version"] == 1
  def import_limit, do: 8_000_000

  def new do
    build(Ecto.UUID.generate(), 0, %{"tc" => 0, "ch" => 6}, [
      %{
        "revision" => 0,
        "action" => "initial",
        "actor" => "workshop constructor",
        "positions" => %{"tc" => 0, "ch" => 6},
        "parameters" => Steeling.defaults()
      }
    ])
    |> Map.merge(%{"lock" => nil, "witnesses" => [], "legacy_source" => nil})
  end

  defp build(id, revision, positions, provenance, parameters \\ Steeling.defaults()) do
    %{
      "schema_version" => 2,
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
      "assembly" => %{
        "id" => "contraption",
        "name" => "THIS ONE RE-STEPPING AND MAY BE RE-STOMPING CONTRAPTION",
        "longitudinal_extents" => 18
      },
      "steeling" => Steeling.model(parameters),
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
      legacy?(model) -> {:error, :legacy_read_only}
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

  defp change(%{"lock" => nil} = m, {:steeling, parameters}) do
    if Steeling.valid?(parameters) do
      if parameters == m["steeling"]["parameters"],
        do: {:ok, m},
        else: {:ok, advance(m, "steeling", m["positions"], parameters)}
    else
      {:error, :invalid_parameters}
    end
  end

  defp change(%{"lock" => nil} = m, :reset_steeling),
    do: {:ok, advance(m, "reset-steeling", m["positions"], Steeling.defaults())}

  defp change(%{"lock" => nil} = m, :reset),
    do: {:ok, advance(m, "reset", %{"tc" => 0, "ch" => 6})}

  defp change(%{"lock" => nil} = m, :lock) do
    next = advance(m, "lock", m["positions"])
    id = "#{m["construction_id"]}-lock-#{next["revision"]}"

    witness = %{
      "id" => id,
      "revision" => next["revision"],
      "snapshot" => Map.drop(next, ["lock", "witnesses", "legacy_source"])
    }

    {:ok, %{next | "lock" => id, "witnesses" => next["witnesses"] ++ [witness]}}
  end

  defp change(%{"lock" => lock} = m, :release) when is_binary(lock),
    do: {:ok, %{advance(m, "release", m["positions"]) | "lock" => nil}}

  defp change(_, _), do: {:error, :unavailable}

  defp advance(m, action, positions, parameters \\ nil) do
    parameters = parameters || m["steeling"]["parameters"]
    revision = m["revision"] + 1

    event = %{
      "revision" => revision,
      "action" => action,
      "actor" => "Human construction control",
      "positions" => positions,
      "parameters" => parameters
    }

    build(m["construction_id"], revision, positions, m["provenance"] ++ [event], parameters)
    |> Map.merge(Map.take(m, ["lock", "witnesses", "legacy_source"]))
  end

  def migrate_legacy(model, view) do
    if legacy?(model) do
      source = LegacyV1.export(model, view)

      with {:ok, _, _} <- LegacyV1.import(source),
           do: {:ok, %{new() | "legacy_source" => Jason.decode!(source)}}
    else
      {:error, :not_legacy}
    end
  end

  def export(model, view, yaw \\ 0) do
    if legacy?(model),
      do: LegacyV1.export(model, view),
      else:
        Jason.encode!(
          %{
            "schema_version" => 2,
            "construction" => model,
            "view" => %{"regarding" => view, "yaw" => yaw}
          },
          pretty: true
        )
  end

  def import(json) when is_binary(json) and byte_size(json) <= 8_000_000 do
    case Jason.decode(json) do
      {:ok, %{"schema_version" => 1}} ->
        with {:ok, m, view} <- LegacyV1.import(json),
             do: {:ok, m, %{"regarding" => view, "yaw" => 0}}

      {:ok,
       %{
         "schema_version" => 2,
         "construction" => m,
         "view" => %{"regarding" => view, "yaw" => yaw} = specification
       }} ->
        if view in @views and is_number(yaw) and yaw >= -180 and yaw <= 180 and valid_model?(m),
          do: {:ok, m, specification},
          else: {:error, :invalid_witness}

      _ ->
        {:error, :invalid_witness}
    end
  end

  def import(_), do: {:error, :invalid_witness}

  defp valid_snapshot?(s) when is_map(s) do
    with {:ok, _} <- Ecto.UUID.cast(s["construction_id"]),
         r when is_integer(r) and r >= 0 and r <= 101 <- s["revision"],
         %{"tc" => tc, "ch" => ch} = p <- s["positions"],
         true <- valid_position?(tc) and valid_position?(ch),
         events when is_list(events) <- s["provenance"],
         true <- length(events) == r + 1,
         parameters <- parameters_of(s),
         true <- Steeling.valid?(parameters),
         true <- valid_events?(events, p, parameters),
         true <- s == build(s["construction_id"], r, p, events, parameters),
         do: true,
         else: (_ -> false)
  end

  defp valid_snapshot?(_), do: false
  defp parameters_of(%{"steeling" => %{"parameters" => p}}), do: p
  defp parameters_of(_), do: nil
  defp valid_position?(n), do: is_number(n) and n >= 0 and n <= 12

  defp valid_events?(events, positions, parameters) do
    initial = %{
      "revision" => 0,
      "action" => "initial",
      "actor" => "workshop constructor",
      "positions" => %{"tc" => 0, "ch" => 6},
      "parameters" => Steeling.defaults()
    }

    result =
      events
      |> Enum.drop(1)
      |> Enum.with_index(1)
      |> Enum.reduce_while({initial["positions"], initial["parameters"], false}, fn {event, i},
                                                                                    {prior,
                                                                                     previous_parameters,
                                                                                     locked} ->
        case event do
          %{
            "revision" => ^i,
            "action" => action,
            "actor" => "Human construction control",
            "positions" => %{"tc" => tc, "ch" => ch} = p,
            "parameters" => params
          }
          when map_size(event) == 5 and map_size(p) == 2 ->
            valid =
              Steeling.valid?(params) and valid_position?(tc) and valid_position?(ch) and
                (i <= 100 or action == "release") and
                case action do
                  "move" ->
                    !locked and params == previous_parameters and
                      Enum.count(["tc", "ch"], &(p[&1] != prior[&1])) == 1

                  "reset" ->
                    !locked and params == previous_parameters and p == initial["positions"]

                  "lock" ->
                    !locked and params == previous_parameters and p == prior

                  "release" ->
                    locked and params == previous_parameters and p == prior

                  "steeling" ->
                    !locked and p == prior and params != previous_parameters

                  "reset-steeling" ->
                    !locked and p == prior and params == Steeling.defaults()

                  _ ->
                    false
                end

            if valid,
              do:
                {:cont,
                 {p, params,
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
        {p, params, _} -> p == positions and params == parameters
        _ -> false
      end
  end

  defp valid_model?(m) when is_map(m) do
    base = Map.drop(m, ["lock", "witnesses", "legacy_source"])

    with true <- valid_snapshot?(base),
         true <- valid_source?(m["legacy_source"]),
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
         true <-
           Map.keys(m) |> Enum.sort() ==
             Enum.sort(Map.keys(base) ++ ["lock", "witnesses", "legacy_source"]),
         true <- is_nil(m["lock"]) or List.last(records)["snapshot"] == base,
         do: true,
         else: (_ -> false)
  end

  defp valid_model?(_), do: false
  defp valid_source?(nil), do: true

  defp valid_source?(%{"schema_version" => 1} = envelope),
    do: match?({:ok, _, _}, LegacyV1.import(Jason.encode!(envelope)))

  defp valid_source?(_), do: false
end
