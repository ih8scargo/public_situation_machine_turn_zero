defmodule PublicSituationMachineTurnZero.DetsRegistryImporter do
  @moduledoc """
  One-time importer for Parkinging Stand records created by the former DETS registry.

  The target PostgreSQL tables must be empty. Run the import from a verified copy
  of the DETS file while the former application is no longer accepting writes.
  """

  alias PublicSituationMachineTurnZero.Appointmenting
  alias PublicSituationMachineTurnZero.ParkingingStand
  alias PublicSituationMachineTurnZero.Repo
  alias PublicSituationMachineTurnZero.Shackling
  alias PublicSituationMachineTurnZero.SituationingName
  alias PublicSituationMachineTurnZero.TupleShip
  alias PublicSituationMachineTurnZero.XtYtInterrelationing

  @table :public_situation_machine_turn_zero_dets_import

  def import(path) do
    {:ok, @table} =
      :dets.open_file(@table,
        file: String.to_charlist(path),
        type: :set,
        access: :read
      )

    try do
      entries = :dets.foldl(&collect_entry/2, [], @table)
      last_number = dets_last_number()

      Enum.each(entries, &import_entry!/1)
      advance_parkinging_stand_sequence(last_number)

      %{imported: length(entries), last_number: last_number}
    after
      :dets.close(@table)
    end
  end

  defp collect_entry({parkinging_stand, leashing}, entries) when is_binary(parkinging_stand),
    do: [{parkinging_stand, normalize_leashing(leashing)} | entries]

  defp collect_entry(_metadata, entries), do: entries

  defp dets_last_number do
    case :dets.lookup(@table, :last_number) do
      [{:last_number, number}] -> number
      [] -> 1
    end
  end

  defp import_entry!({parkinging_stand, leashing}) do
    Repo.transaction(fn ->
      tuple_ship = Repo.insert!(%TupleShip{furnished_at: second(leashing.ceremony_time)})

      Repo.insert!(%ParkingingStand{
        number: String.to_integer(parkinging_stand),
        tuple_ship_id: tuple_ship.id,
        allotted_at: second(leashing.ceremony_time)
      })

      Repo.insert!(%Shackling{
        tuple_ship_id: tuple_ship.id,
        pin: leashing.shackling_pin,
        furnished_at: second(leashing.ceremony_time)
      })

      leashing.pet_name_history
      |> Enum.reverse()
      |> Enum.each(fn entry ->
        Repo.insert!(%SituationingName{
          tuple_ship_id: tuple_ship.id,
          name: entry.name,
          furnished_at: second(entry.furnished_at)
        })
      end)

      Enum.each(leashing.appointmentings, fn {kind, furnished_at} ->
        Repo.insert!(%Appointmenting{
          tuple_ship_id: tuple_ship.id,
          kind: Atom.to_string(kind),
          furnished_at: second(furnished_at)
        })
      end)

      leashing.earthly_locality_history
      |> Enum.reverse()
      |> Enum.each(fn entry ->
        locality = entry.earthly_locality

        Repo.insert!(%XtYtInterrelationing{
          tuple_ship_id: tuple_ship.id,
          country: Map.get(locality, :country, ""),
          region: Map.get(locality, :region, ""),
          city: Map.get(locality, :city, ""),
          visionizing_scope: Map.get(locality, :visionizing_scope),
          constitutional_default: Map.get(locality, :constitutional_default, false),
          furnished_at: second(entry.furnished_at)
        })
      end)
    end)
  end

  defp normalize_leashing(leashing) do
    leashing
    |> Map.put_new(:pet_name_history, legacy_pet_name_history(leashing))
    |> Map.put_new(:appointmentings, %{})
    |> Map.put_new(:earthly_locality, nil)
    |> Map.put_new(:earthly_locality_history, legacy_earthly_locality_history(leashing))
  end

  defp legacy_pet_name_history(%{name: name, ceremony_time: ceremony_time})
       when is_binary(name),
       do: [%{name: name, furnished_at: ceremony_time}]

  defp legacy_pet_name_history(_leashing), do: []

  defp legacy_earthly_locality_history(%{
         earthly_locality: earthly_locality,
         ceremony_time: ceremony_time
       })
       when is_map(earthly_locality),
       do: [%{earthly_locality: earthly_locality, furnished_at: ceremony_time}]

  defp legacy_earthly_locality_history(_leashing), do: []

  defp advance_parkinging_stand_sequence(last_number) do
    Repo.query!(
      """
      SELECT setval(
        'parkinging_stands_number_seq',
        GREATEST((SELECT COALESCE(MAX(number), 1) FROM parkinging_stands), $1),
        true
      )
      """,
      [last_number]
    )
  end

  defp second(%DateTime{} = piece_of_time), do: DateTime.truncate(piece_of_time, :second)
end
