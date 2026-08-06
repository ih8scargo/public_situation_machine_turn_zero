defmodule PublicSituationMachineTurnZero.XtYtInterrelationing do
  use Ecto.Schema

  @foreign_key_type :binary_id

  schema "xt_yt_interrelationings" do
    belongs_to :tuple_ship, PublicSituationMachineTurnZero.TupleShip
    field :country, :string
    field :region, :string
    field :city, :string
    field :visionizing_scope, :string
    field :constitutional_default, :boolean, default: false
    field :furnished_at, :utc_datetime
  end
end
