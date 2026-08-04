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
    GenServer.call(__MODULE__, {:furnish_name, parkinging_stand, shackling_pin, name})
  end

  def furnish_earthly_locality(parkinging_stand, shackling_pin, earthly_locality) do
    GenServer.call(
      __MODULE__,
      {:furnish_earthly_locality, parkinging_stand, shackling_pin, earthly_locality}
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
      earthly_locality: nil
    }

    :ok = :dets.insert(state.table, {parkinging_stand, leashing})
    :ok = :dets.sync(state.table)

    {:reply, leashing, state}
  end

  def handle_call({:re_shackle, parkinging_stand, shackling_pin}, _from, state) do
    reply =
      case :dets.lookup(state.table, parkinging_stand) do
        [{^parkinging_stand, leashing}] ->
          if pins_match?(leashing.shackling_pin, shackling_pin), do: {:ok, leashing}, else: :error

        [] ->
          :error
      end

    {:reply, reply, state}
  end

  def handle_call({:furnish_name, parkinging_stand, shackling_pin, name}, _from, state) do
    {:reply, update_leashing(state.table, parkinging_stand, shackling_pin, :name, name), state}
  end

  def handle_call(
        {:furnish_earthly_locality, parkinging_stand, shackling_pin, earthly_locality},
        _from,
        state
      ) do
    reply =
      update_leashing(
        state.table,
        parkinging_stand,
        shackling_pin,
        :earthly_locality,
        earthly_locality
      )

    {:reply, reply, state}
  end

  defp update_leashing(table, parkinging_stand, shackling_pin, field, value) do
    reply =
      case :dets.lookup(table, parkinging_stand) do
        [{^parkinging_stand, leashing}] ->
          if pins_match?(leashing.shackling_pin, shackling_pin) do
            updated_leashing = Map.put(leashing, field, value)
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

  defp pins_match?(stored_pin, supplied_pin)
       when byte_size(stored_pin) == byte_size(supplied_pin),
       do: Plug.Crypto.secure_compare(stored_pin, supplied_pin)

  defp pins_match?(_stored_pin, _supplied_pin), do: false

  @impl true
  def terminate(_reason, state) do
    :dets.close(state.table)
  end
end
