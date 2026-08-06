defmodule PublicSituationMachineTurnZero.Appointmenting do
  use Ecto.Schema

  @foreign_key_type :binary_id

  schema "appointmentings" do
    belongs_to :tuple_ship, PublicSituationMachineTurnZero.TupleShip
    field :kind, :string
    field :furnished_at, :utc_datetime
  end
end
