defmodule PublicSituationMachineTurnZero.ParkingingStandRegistry do
  @moduledoc """
  Furnishes durable, sequential Parkinging Stand Numbers.

  Parkinging Stand #1 predates the public allotmenting registry, so public
  furnishing begins with 000000000002.
  """

  use GenServer

  @table __MODULE__

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def furnish_leashing(shackling_pin, ceremony_time) do
    GenServer.call(__MODULE__, {:furnish_leashing, shackling_pin, ceremony_time})
  end

  def re_shackle(parkinging_stand, shackling_pin) do
    GenServer.call(__MODULE__, {:re_shackle, parkinging_stand, shackling_pin})
  end

  def furnish_name(parkinging_stand, shackling_pin, name) do
    furnish_pet_name(parkinging_stand, shackling_pin, name, DateTime.utc_now())
  end

  def furnish_pet_name(parkinging_stand, shackling_pin, name, furnished_at) do
    GenServer.call(
      __MODULE__,
      {:furnish_pet_name, parkinging_stand, shackling_pin, name, furnished_at}
    )
  end

  def furnish_appointmenting(parkinging_stand, shackling_pin, appointmenting, furnished_at) do
    GenServer.call(
      __MODULE__,
      {:furnish_appointmenting, parkinging_stand, shackling_pin, appointmenting, furnished_at}
    )
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
    GenServer.call(
      __MODULE__,
      {:furnish_earthly_locality, parkinging_stand, shackling_pin, earthly_locality, furnished_at}
    )
  end

  @impl true
  def init(options) do
    path = Keyword.fetch!(options, :path)
    :ok = path |> Path.dirname() |> File.mkdir_p()

    {:ok, @table} =
      :dets.open_file(@table,
        file: String.to_charlist(path),
        type: :set,
        repair: true
      )

    case :dets.lookup(@table, :last_number) do
      [] -> :ok = :dets.insert(@table, {:last_number, 1})
      [{:last_number, _number}] -> :ok
    end

    {:ok, %{table: @table}}
  end

  @impl true
  def handle_call({:furnish_leashing, shackling_pin, ceremony_time}, _from, state) do
    number = :dets.update_counter(state.table, :last_number, 1)

    parkinging_stand =
      number
      |> Integer.to_string()
      |> String.pad_leading(12, "0")

    leashing = %{
      parkinging_stand: parkinging_stand,
      shackling_pin: shackling_pin,
      ceremony_time: ceremony_time,
      name: nil,
      pet_name_history: [],
      earthly_locality: nil,
      earthly_locality_history: [],
      appointmentings: %{}
    }

    :ok = :dets.insert(state.table, {parkinging_stand, leashing})
    :ok = :dets.sync(state.table)

    {:reply, leashing, state}
  end

  def handle_call({:re_shackle, parkinging_stand, shackling_pin}, _from, state) do
    reply =
      case :dets.lookup(state.table, parkinging_stand) do
        [{^parkinging_stand, stored_leashing}] ->
          leashing = normalize_leashing(stored_leashing)
          if pins_match?(leashing.shackling_pin, shackling_pin), do: {:ok, leashing}, else: :error

        [] ->
          :error
      end

    {:reply, reply, state}
  end

  def handle_call(
        {:furnish_pet_name, parkinging_stand, shackling_pin, name, furnished_at},
        _from,
        state
      ) do
    reply =
      update_leashing(state.table, parkinging_stand, shackling_pin, fn leashing ->
        history_entry = %{name: name, furnished_at: furnished_at}

        leashing
        |> Map.put(:name, name)
        |> Map.update!(:pet_name_history, &[history_entry | &1])
      end)

    {:reply, reply, state}
  end

  def handle_call(
        {:furnish_appointmenting, parkinging_stand, shackling_pin, appointmenting, furnished_at},
        _from,
        state
      ) do
    reply =
      update_leashing(state.table, parkinging_stand, shackling_pin, fn leashing ->
        Map.update!(leashing, :appointmentings, fn appointmentings ->
          Map.put(appointmentings, appointmenting, furnished_at)
        end)
      end)

    {:reply, reply, state}
  end

  def handle_call(
        {:furnish_earthly_locality, parkinging_stand, shackling_pin, earthly_locality,
         furnished_at},
        _from,
        state
      ) do
    reply =
      update_leashing(state.table, parkinging_stand, shackling_pin, fn leashing ->
        history_entry = %{earthly_locality: earthly_locality, furnished_at: furnished_at}

        leashing
        |> Map.put(:earthly_locality, earthly_locality)
        |> Map.update!(:earthly_locality_history, &[history_entry | &1])
      end)

    {:reply, reply, state}
  end

  defp update_leashing(table, parkinging_stand, shackling_pin, update) do
    reply =
      case :dets.lookup(table, parkinging_stand) do
        [{^parkinging_stand, stored_leashing}] ->
          leashing = normalize_leashing(stored_leashing)

          if pins_match?(leashing.shackling_pin, shackling_pin) do
            updated_leashing = update.(leashing)
            :ok = :dets.insert(table, {parkinging_stand, updated_leashing})
            :ok = :dets.sync(table)
            {:ok, updated_leashing}
          else
            :error
          end

        [] ->
          :error
      end

    reply
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

  defp pins_match?(stored_pin, supplied_pin)
       when byte_size(stored_pin) == byte_size(supplied_pin),
       do: Plug.Crypto.secure_compare(stored_pin, supplied_pin)

  defp pins_match?(_stored_pin, _supplied_pin), do: false

  @impl true
  def terminate(_reason, state) do
    :dets.close(state.table)
  end
end
