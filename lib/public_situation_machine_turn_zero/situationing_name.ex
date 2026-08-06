defmodule PublicSituationMachineTurnZero.SituationingName do
  use Ecto.Schema

  @foreign_key_type :binary_id

  schema "situationing_names" do
    belongs_to :tuple_ship, PublicSituationMachineTurnZero.TupleShip
    field :name, :string
    field :furnished_at, :utc_datetime
  end
end
