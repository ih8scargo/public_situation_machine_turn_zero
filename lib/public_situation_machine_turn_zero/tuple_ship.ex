defmodule PublicSituationMachineTurnZero.TupleShip do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tuple_ships" do
    field :furnished_at, :utc_datetime
  end
end
