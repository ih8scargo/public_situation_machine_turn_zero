defmodule PublicSituationMachineTurnZero.Refolding.MemoryStore do
  @moduledoc """
  Volatile, process-local spike adapter. Survives LiveView remounts, not application
  restarts. No coupling to ParkingingStandRegistry or database persistence.
  """
  use GenServer
  @behaviour PublicSituationMachineTurnZero.Refolding.Store
  alias PublicSituationMachineTurnZero.Refolding.Standing

  def start_link(opts), do: GenServer.start_link(__MODULE__, %{}, opts)
  @impl true
  def init(records), do: {:ok, records}
  @impl true
  def load(server, key), do: GenServer.call(server, {:load, key})
  @impl true
  def transact(server, key, fun), do: GenServer.call(server, {:transact, key, fun})
  @impl true
  def handle_call({:load, key}, _from, records), do: {:reply, Map.get(records, key), records}

  def handle_call({:transact, key, fun}, _from, records) do
    %Standing{by_way_of: ^key} = standing = fun.(Map.get(records, key))
    {:reply, standing, Map.put(records, key, standing)}
  end
end
