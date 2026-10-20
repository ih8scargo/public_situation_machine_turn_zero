defmodule PublicSituationMachineTurnZero.Refolding.Store do
  @moduledoc """
  Replaceable pass-one persistence contract. Transactions receive and return only a
  consequential Standing (or nil before initialization), never apparatus or socket state.
  Implementations must serialize transactions for the same BY-WAY-OF key.
  """
  alias PublicSituationMachineTurnZero.Refolding.Standing
  @callback load(GenServer.server(), String.t()) :: Standing.t() | nil
  @callback transact(GenServer.server(), String.t(), (Standing.t() | nil -> Standing.t())) ::
              Standing.t()
end
