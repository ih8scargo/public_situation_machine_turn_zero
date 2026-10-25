defmodule PublicSituationMachineTurnZero.Repo.Migrations.CreateExperimentalInstrumentationRecords do
  use Ecto.Migration
  def change do
    create table(:experimental_instrumentation_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :standing, :map, null: false
      add :lock_version, :integer, null: false, default: 1
      timestamps(type: :utc_datetime)
    end
  end
end
