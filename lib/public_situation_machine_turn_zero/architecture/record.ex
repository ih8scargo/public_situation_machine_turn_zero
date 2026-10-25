defmodule PublicSituationMachineTurnZero.Architecture.Record do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "experimental_architecture_records" do
    field :standing, :map
    field :lock_version, :integer, default: 1
    timestamps(type: :utc_datetime)
  end
end
