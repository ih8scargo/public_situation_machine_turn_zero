defmodule PublicSituationMachineTurnZero.ParkingingStand do
  use Ecto.Schema

  @primary_key false
  @foreign_key_type :binary_id

  schema "parkinging_stands" do
    field :number, :integer, primary_key: true, read_after_writes: true
    belongs_to :tuple_ship, PublicSituationMachineTurnZero.TupleShip
    field :allotted_at, :utc_datetime
  end
end
