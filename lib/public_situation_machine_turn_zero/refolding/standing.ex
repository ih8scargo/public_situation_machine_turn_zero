defmodule PublicSituationMachineTurnZero.Refolding.Standing do
  @moduledoc """
  Consequential return record. No Regarding, approach labor or viewport belongs here.
  ENZO is the stipulated initial FROM. Only lawful ZIPPERING changes FROM and
  consequentializes worked material. Each consequence retains its prior relation,
  so constitutional continuity can be outread without a separate gesture history.
  """
  @type t :: %__MODULE__{
          from: String.t(),
          material: map(),
          consequence: map(),
          by_way_of: String.t()
        }
  @enforce_keys [:by_way_of]
  defstruct from: "ENZO",
            material: %{},
            consequence: %{operation: :initial, from: "ENZO"},
            by_way_of: nil
end
