defmodule PublicSituationMachineTurnZero.Shackling do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "shacklings" do
    belongs_to :tuple_ship, PublicSituationMachineTurnZero.TupleShip
    field :pin, :string
    field :furnished_at, :utc_datetime
    field :retired_at, :utc_datetime
  end
end
