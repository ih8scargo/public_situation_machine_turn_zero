defmodule PublicSituationMachineTurnZero.Refolding.Standing do
  @moduledoc """
  Consequential return record. No Regarding, Segmentationing, or viewport belongs here.
  ENZO is the stipulated initial FROM; subsequent changes require explicit consequence.
  """
  @type t :: %__MODULE__{
          from: String.t(),
          material: map(),
          consequence: map(),
          by_way_of: String.t()
        }
  @enforce_keys [:by_way_of]
  defstruct from: "ENZO", material: %{}, consequence: %{operation: :initial}, by_way_of: nil
end
