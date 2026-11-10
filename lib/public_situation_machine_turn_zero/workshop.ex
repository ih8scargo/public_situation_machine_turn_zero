defmodule PublicSituationMachineTurnZero.Workshop do
  @moduledoc "Independent geometric assembly; no constitutional operations. Revisions protect construction LOCK."
  alias PublicSituationMachineTurnZero.Workshop.{
    Geometry,
    Steeling,
    LegacyV2,
    Projection,
    Rehearsal,
    Calibration,
    Inspection,
    Surfacing
  }

  @views ~w(front reverse plan lower transverse departure reciprocal tunneling diorama)
  def views, do: @views

  def legacy?(model), do: model["schema_version"] in [1, 2]
  def import_limit, do: 16_000_000

  def new do
    build(Ecto.UUID.generate(), 0, %{"tc" => 0, "ch" => 6}, [
      %{
        "revision" => 0,
        "action" => "initial",
        "actor" => "workshop constructor",
        "positions" => %{"tc" => 0, "ch" => 6},
        "parameters" => Steeling.defaults(),
        "projection_parameters" => Projection.defaults()
      }
    ])
    |> Map.merge(%{
      "lock" => nil,
      "witnesses" => [],
      "legacy_source" => nil,
      "rehearsal" => Rehearsal.new()
    })
  end

  defp build(
         id,
         revision,
         positions,
         provenance,
         parameters \\ Steeling.defaults(),
         projection_parameters \\ Projection.defaults()
       ) do
    %{
      "schema_version" => 3,
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
      "projection" => Projection.model(projection_parameters),
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

  def rehearse(model, revision, command) do
    if legacy?(model) do
      {:error, :legacy_read_only}
    else
      with {:ok, state} <- Rehearsal.operate(model["rehearsal"], revision, command, model),
           do: {:ok, Map.put(model, "rehearsal", state)}
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

  defp change(%{"lock" => nil} = m, {:projection, parameters}) do
    if Projection.valid?(parameters) do
      if parameters == m["projection"]["parameters"],
        do: {:ok, m},
        else: {:ok, advance(m, "projection", m["positions"], nil, parameters)}
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
      "snapshot" => Map.drop(next, ["lock", "witnesses", "legacy_source", "rehearsal"])
    }

    {:ok, %{next | "lock" => id, "witnesses" => next["witnesses"] ++ [witness]}}
  end

  defp change(%{"lock" => lock} = m, :release) when is_binary(lock),
    do: {:ok, %{advance(m, "release", m["positions"]) | "lock" => nil}}

  defp change(_, _), do: {:error, :unavailable}

  defp advance(m, action, positions, parameters \\ nil, projection_parameters \\ nil) do
    projection_parameters = projection_parameters || m["projection"]["parameters"]
    parameters = parameters || m["steeling"]["parameters"]
    revision = m["revision"] + 1

    event = %{
      "revision" => revision,
      "action" => action,
      "actor" => "Human construction control",
      "positions" => positions,
      "parameters" => parameters,
      "projection_parameters" => projection_parameters
    }

    build(
      m["construction_id"],
      revision,
      positions,
      m["provenance"] ++ [event],
      parameters,
      projection_parameters
    )
    |> Map.merge(Map.take(m, ["lock", "witnesses", "legacy_source", "rehearsal"]))
  end

  def migrate_legacy(model, view, yaw \\ 0) do
    if legacy?(model) do
      source = LegacyV2.export(model, view, yaw)

      with {:ok, _, _} <- LegacyV2.import(source),
           do: {:ok, %{new() | "legacy_source" => Jason.decode!(source)}}
    else
      {:error, :not_legacy}
    end
  end

  def export(model, view, yaw \\ 0, bearing \\ "both") do
    if legacy?(model),
      do: LegacyV2.export(model, view, yaw),
      else:
        Jason.encode!(
          %{
            "schema_version" => 3,
            "construction" => model,
            "view" => %{"regarding" => view, "yaw" => yaw, "bearing" => bearing}
          },
          pretty: true
        )
  end

  def export(model, view, yaw, bearing, calibration) do
    envelope = export(model, view, yaw, bearing) |> Jason.decode!()

    if calibration && !legacy?(model),
      do:
        Jason.encode!(
          envelope
          |> Map.put("schema_version", 4)
          |> Map.put("extensions", %{"calibration_v1" => calibration}),
          pretty: true
        ),
      else: Jason.encode!(envelope, pretty: true)
  end

  def export(model, view, yaw, bearing, calibration, inspection) do
    envelope = export(model, view, yaw, bearing, calibration) |> Jason.decode!()

    if inspection && !legacy?(model) do
      extensions = Map.put(envelope["extensions"] || %{}, "inspection_v1", inspection)

      Jason.encode!(envelope |> Map.put("schema_version", 5) |> Map.put("extensions", extensions),
        pretty: true
      )
    else
      Jason.encode!(envelope, pretty: true)
    end
  end

  def export(model, view, yaw, bearing, calibration, inspection, surfacing) do
    envelope = export(model, view, yaw, bearing, calibration, inspection) |> Jason.decode!()

    if surfacing && !legacy?(model) do
      ext = Map.put(envelope["extensions"] || %{}, "surfacing_v1", surfacing)

      Jason.encode!(envelope |> Map.put("schema_version", 6) |> Map.put("extensions", ext),
        pretty: true
      )
    else
      Jason.encode!(envelope, pretty: true)
    end
  end

  def import(json) when is_binary(json) and byte_size(json) <= 16_000_000 do
    case Jason.decode(json) do
      {:ok, %{"schema_version" => version} = envelope} when version in [1, 2] ->
        if Map.has_key?(envelope, "extensions"),
          do: {:error, :invalid_witness},
          else: LegacyV2.import(json)

      {:ok,
       %{
         "schema_version" => version,
         "construction" => m,
         "view" => %{"regarding" => view, "yaw" => yaw, "bearing" => bearing} = specification
       } = envelope}
      when version in [3, 4, 5, 6] ->
        extension =
          case envelope["extensions"] do
            %{"calibration_v1" => extension} -> extension
            _ -> nil
          end

        extension_valid =
          case version do
            3 ->
              !Map.has_key?(envelope, "extensions")

            4 ->
              envelope["extensions"] == %{"calibration_v1" => extension} &&
                Calibration.valid?(extension)

            5 ->
              ext = envelope["extensions"]

              is_map(ext) and
                Enum.sort(Map.keys(ext)) in [
                  ["inspection_v1"],
                  ["calibration_v1", "inspection_v1"]
                ] and Inspection.valid?(ext["inspection_v1"]) and
                (!Map.has_key?(ext, "calibration_v1") or Calibration.valid?(extension))

            6 ->
              ext = envelope["extensions"]

              is_map(ext) and Map.has_key?(ext, "surfacing_v1") and
                Enum.all?(Map.keys(ext), &(&1 in ~w(surfacing_v1 calibration_v1 inspection_v1))) and
                Surfacing.valid?(ext["surfacing_v1"]) and
                (!Map.has_key?(ext, "calibration_v1") or Calibration.valid?(extension)) and
                (!Map.has_key?(ext, "inspection_v1") or Inspection.valid?(ext["inspection_v1"]))
          end

        if extension_valid and map_size(specification) == 3 and
             bearing in ~w(vertical oblique both) and view in @views and
             is_number(yaw) and
             yaw >= -180 and yaw <= 180 and valid_model?(m) and
             (version not in [5, 6] or !Map.has_key?(envelope["extensions"], "inspection_v1") or
                Inspection.registered?(envelope["extensions"]["inspection_v1"], m)),
           do:
             {:ok, m,
              specification
              |> then(fn v ->
                if extension, do: Map.put(v, "calibration_v1", extension), else: v
              end)
              |> then(fn v ->
                if version in [5, 6] && Map.has_key?(envelope["extensions"], "inspection_v1"),
                  do: Map.put(v, "inspection_v1", envelope["extensions"]["inspection_v1"]),
                  else: v
              end)
              |> then(fn v ->
                if version == 6,
                  do: Map.put(v, "surfacing_v1", envelope["extensions"]["surfacing_v1"]),
                  else: v
              end)},
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
         projection_parameters <- projection_parameters_of(s),
         true <- Projection.valid?(projection_parameters),
         true <- valid_events?(events, p, parameters, projection_parameters),
         true <-
           s == build(s["construction_id"], r, p, events, parameters, projection_parameters),
         do: true,
         else: (_ -> false)
  end

  defp valid_snapshot?(_), do: false
  defp parameters_of(%{"steeling" => %{"parameters" => p}}), do: p
  defp parameters_of(_), do: nil
  defp projection_parameters_of(%{"projection" => %{"parameters" => p}}), do: p
  defp projection_parameters_of(_), do: nil
  defp valid_position?(n), do: is_number(n) and n >= 0 and n <= 12

  defp valid_events?(events, positions, parameters, projection_parameters) do
    initial = %{
      "revision" => 0,
      "action" => "initial",
      "actor" => "workshop constructor",
      "positions" => %{"tc" => 0, "ch" => 6},
      "parameters" => Steeling.defaults(),
      "projection_parameters" => Projection.defaults()
    }

    result =
      events
      |> Enum.drop(1)
      |> Enum.with_index(1)
      |> Enum.reduce_while(
        {initial["positions"], initial["parameters"], initial["projection_parameters"], false},
        fn {event, i}, {prior, previous_parameters, previous_projection, locked} ->
          case event do
            %{
              "revision" => ^i,
              "action" => action,
              "actor" => "Human construction control",
              "positions" => %{"tc" => tc, "ch" => ch} = p,
              "parameters" => params,
              "projection_parameters" => pp
            }
            when map_size(event) == 6 and map_size(p) == 2 ->
              valid =
                Steeling.valid?(params) and Projection.valid?(pp) and valid_position?(tc) and
                  valid_position?(ch) and (i <= 100 or action == "release") and
                  case action do
                    "move" ->
                      !locked and params == previous_parameters and pp == previous_projection and
                        Enum.count(["tc", "ch"], &(p[&1] != prior[&1])) == 1

                    "reset" ->
                      !locked and params == previous_parameters and pp == previous_projection and
                        p == initial["positions"]

                    "lock" ->
                      !locked and params == previous_parameters and pp == previous_projection and
                        p == prior

                    "release" ->
                      locked and params == previous_parameters and pp == previous_projection and
                        p == prior

                    "steeling" ->
                      !locked and p == prior and pp == previous_projection and
                        params != previous_parameters

                    "reset-steeling" ->
                      !locked and p == prior and pp == previous_projection and
                        params == Steeling.defaults()

                    "projection" ->
                      !locked and p == prior and params == previous_parameters and
                        pp != previous_projection

                    _ ->
                      false
                  end

              next_locked =
                case action do
                  "lock" -> true
                  "release" -> false
                  _ -> locked
                end

              if valid, do: {:cont, {p, params, pp, next_locked}}, else: {:halt, :invalid}

            _ ->
              {:halt, :invalid}
          end
        end
      )

    hd(events) == initial and
      case result do
        {p, params, projection, _} ->
          p == positions and params == parameters and projection == projection_parameters

        _ ->
          false
      end
  end

  defp valid_model?(m) when is_map(m) do
    base = Map.drop(m, ["lock", "witnesses", "legacy_source", "rehearsal"])

    with true <- valid_snapshot?(base),
         true <- Rehearsal.valid?(m["rehearsal"], m),
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
             Enum.sort(Map.keys(base) ++ ["lock", "witnesses", "legacy_source", "rehearsal"]),
         true <- is_nil(m["lock"]) or List.last(records)["snapshot"] == base,
         do: true,
         else: (_ -> false)
  end

  defp valid_model?(_), do: false
  defp valid_source?(nil), do: true

  defp valid_source?(%{"schema_version" => version} = envelope) when version in [1, 2],
    do: match?({:ok, _, _}, LegacyV2.import(Jason.encode!(envelope)))

  defp valid_source?(_), do: false
end
