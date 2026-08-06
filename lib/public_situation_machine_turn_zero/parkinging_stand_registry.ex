defmodule PublicSituationMachineTurnZero.ParkingingStandRegistry do
  @moduledoc """
  Furnishes durable, sequential Parkinging Stand Numbers and reconstructs the
  constitutional Standing held through each Leashing.

  Parkinging Stand #1 predates the public allotmenting registry, so public
  furnishing begins with 000000000002.
  """

  import Ecto.Query

  alias PublicSituationMachineTurnZero.Appointmenting
  alias PublicSituationMachineTurnZero.ParkingingStand
  alias PublicSituationMachineTurnZero.Repo
  alias PublicSituationMachineTurnZero.Shackling
  alias PublicSituationMachineTurnZero.SituationingName
  alias PublicSituationMachineTurnZero.TupleShip
  alias PublicSituationMachineTurnZero.XtYtInterrelationing

  def furnish_leashing(shackling_pin, ceremony_time) do
    {:ok, leashing} =
      Repo.transaction(fn ->
        tuple_ship = Repo.insert!(%TupleShip{furnished_at: ceremony_time})

        parkinging_stand =
          Repo.insert!(%ParkingingStand{
            tuple_ship_id: tuple_ship.id,
            allotted_at: ceremony_time
          })

        Repo.insert!(%Shackling{
          tuple_ship_id: tuple_ship.id,
          pin: shackling_pin,
          furnished_at: ceremony_time
        })

        build_leashing(tuple_ship, parkinging_stand.number, shackling_pin)
      end)

    leashing
  end

  def re_shackle(parkinging_stand, shackling_pin) do
    with {:ok, tuple_ship, stand_number, stored_pin} <- find_leashing(parkinging_stand),
         true <- pins_match?(stored_pin, shackling_pin) do
      {:ok, build_leashing(tuple_ship, stand_number, stored_pin)}
    else
      _ -> :error
    end
  end

  def normalize_parkinging_stand(parkinging_stand) do
    parkinging_stand
    |> String.replace(~r/\D/u, "")
    |> String.pad_leading(12, "0")
  end

  def normalize_shackling_pin(shackling_pin) do
    shackling_pin
    |> String.replace(~r/\s/u, "")
    |> String.upcase()
    |> String.graphemes()
    |> Enum.chunk_every(4)
    |> Enum.map_join(" ", &Enum.join/1)
  end

  def furnish_name(parkinging_stand, shackling_pin, name) do
    furnish_pet_name(
      parkinging_stand,
      shackling_pin,
      name,
      DateTime.utc_now() |> DateTime.truncate(:second)
    )
  end

  def furnish_pet_name(parkinging_stand, shackling_pin, name, furnished_at) do
    update_leashing(parkinging_stand, shackling_pin, fn tuple_ship ->
      Repo.insert!(%SituationingName{
        tuple_ship_id: tuple_ship.id,
        name: name,
        furnished_at: furnished_at
      })
    end)
  end

  def furnish_appointmenting(parkinging_stand, shackling_pin, appointmenting, furnished_at) do
    update_leashing(parkinging_stand, shackling_pin, fn tuple_ship ->
      Repo.insert!(%Appointmenting{
        tuple_ship_id: tuple_ship.id,
        kind: Atom.to_string(appointmenting),
        furnished_at: furnished_at
      })
    end)
  end

  def furnish_earthly_locality(parkinging_stand, shackling_pin, earthly_locality) do
    furnish_earthly_locality(
      parkinging_stand,
      shackling_pin,
      earthly_locality,
      DateTime.utc_now() |> DateTime.truncate(:second)
    )
  end

  def furnish_earthly_locality(
        parkinging_stand,
        shackling_pin,
        earthly_locality,
        furnished_at
      ) do
    update_leashing(parkinging_stand, shackling_pin, fn tuple_ship ->
      Repo.insert!(%XtYtInterrelationing{
        tuple_ship_id: tuple_ship.id,
        country: Map.get(earthly_locality, :country, ""),
        region: Map.get(earthly_locality, :region, ""),
        city: Map.get(earthly_locality, :city, ""),
        visionizing_scope: Map.get(earthly_locality, :visionizing_scope),
        constitutional_default: Map.get(earthly_locality, :constitutional_default, false),
        furnished_at: furnished_at
      })
    end)
  end

  defp update_leashing(parkinging_stand, shackling_pin, update) do
    Repo.transaction(fn ->
      with {:ok, tuple_ship, stand_number, stored_pin} <- find_leashing(parkinging_stand),
           true <- pins_match?(stored_pin, shackling_pin) do
        update.(tuple_ship)
        {:ok, build_leashing(tuple_ship, stand_number, stored_pin)}
      else
        _ -> :error
      end
    end)
    |> case do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  defp find_leashing(parkinging_stand) do
    case Integer.parse(parkinging_stand) do
      {stand_number, ""} ->
        query =
          from parkinging_stand in ParkingingStand,
            join: tuple_ship in TupleShip,
            on: tuple_ship.id == parkinging_stand.tuple_ship_id,
            join: shackling in Shackling,
            on: shackling.tuple_ship_id == tuple_ship.id,
            where: parkinging_stand.number == ^stand_number,
            where: is_nil(shackling.retired_at),
            select: {tuple_ship, parkinging_stand.number, shackling.pin}

        case Repo.one(query) do
          {tuple_ship, number, pin} -> {:ok, tuple_ship, number, pin}
          nil -> :error
        end

      _ ->
        :error
    end
  end

  defp build_leashing(tuple_ship, stand_number, shackling_pin) do
    name_history =
      SituationingName
      |> where([name], name.tuple_ship_id == ^tuple_ship.id)
      |> order_by([name], desc: name.id)
      |> Repo.all()
      |> Enum.map(&%{name: &1.name, furnished_at: &1.furnished_at})

    appointmentings =
      Appointmenting
      |> where([appointmenting], appointmenting.tuple_ship_id == ^tuple_ship.id)
      |> order_by([appointmenting], asc: appointmenting.id)
      |> Repo.all()
      |> Map.new(fn appointmenting ->
        {String.to_existing_atom(appointmenting.kind), appointmenting.furnished_at}
      end)

    earthly_locality_history =
      XtYtInterrelationing
      |> where([interrelationing], interrelationing.tuple_ship_id == ^tuple_ship.id)
      |> order_by([interrelationing], desc: interrelationing.id)
      |> Repo.all()
      |> Enum.map(&%{earthly_locality: earthly_locality(&1), furnished_at: &1.furnished_at})

    %{
      parkinging_stand: format_parkinging_stand(stand_number),
      shackling_pin: shackling_pin,
      ceremony_time: tuple_ship.furnished_at,
      name: name_history |> List.first() |> current_name(),
      pet_name_history: name_history,
      earthly_locality: earthly_locality_history |> List.first() |> current_earthly_locality(),
      earthly_locality_history: earthly_locality_history,
      appointmentings: appointmentings
    }
  end

  defp earthly_locality(%{constitutional_default: true}) do
    %{
      country: "",
      region: "",
      city: "",
      visionizing_scope: "earth",
      constitutional_default: true
    }
  end

  defp earthly_locality(interrelationing) do
    locality = %{
      country: interrelationing.country,
      region: interrelationing.region,
      city: interrelationing.city
    }

    if interrelationing.visionizing_scope,
      do: Map.put(locality, :visionizing_scope, interrelationing.visionizing_scope),
      else: locality
  end

  defp current_name(nil), do: nil
  defp current_name(%{name: name}), do: name

  defp current_earthly_locality(nil), do: nil
  defp current_earthly_locality(%{earthly_locality: earthly_locality}), do: earthly_locality

  defp format_parkinging_stand(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(12, "0")
  end

  defp pins_match?(stored_pin, supplied_pin)
       when byte_size(stored_pin) == byte_size(supplied_pin),
       do: Plug.Crypto.secure_compare(stored_pin, supplied_pin)

  defp pins_match?(_stored_pin, _supplied_pin), do: false
end
