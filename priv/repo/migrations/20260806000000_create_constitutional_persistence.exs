defmodule PublicSituationMachineTurnZero.Repo.Migrations.CreateConstitutionalPersistence do
  use Ecto.Migration

  def change do
    create table(:tuple_ships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :furnished_at, :utc_datetime, null: false
    end

    create table(:parkinging_stands, primary_key: false) do
      add :number, :bigserial, primary_key: true
      add :tuple_ship_id, references(:tuple_ships, type: :binary_id, on_delete: :restrict),
        null: false

      add :allotted_at, :utc_datetime, null: false
    end

    execute "ALTER SEQUENCE parkinging_stands_number_seq RESTART WITH 2",
            "ALTER SEQUENCE parkinging_stands_number_seq RESTART WITH 1"

    create unique_index(:parkinging_stands, [:tuple_ship_id])

    create table(:shacklings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tuple_ship_id, references(:tuple_ships, type: :binary_id, on_delete: :restrict),
        null: false

      add :pin, :text, null: false
      add :furnished_at, :utc_datetime, null: false
      add :retired_at, :utc_datetime
    end

    create unique_index(:shacklings, [:tuple_ship_id],
             where: "retired_at IS NULL",
             name: :shacklings_one_active_per_tuple_ship
           )

    create table(:situationing_names) do
      add :tuple_ship_id, references(:tuple_ships, type: :binary_id, on_delete: :restrict),
        null: false

      add :name, :string, size: 120, null: false
      add :furnished_at, :utc_datetime, null: false
    end

    create index(:situationing_names, [:tuple_ship_id, :id])

    create table(:appointmentings) do
      add :tuple_ship_id, references(:tuple_ships, type: :binary_id, on_delete: :restrict),
        null: false

      add :kind, :string, null: false
      add :furnished_at, :utc_datetime, null: false
    end

    create index(:appointmentings, [:tuple_ship_id, :id])

    create table(:xt_yt_interrelationings) do
      add :tuple_ship_id, references(:tuple_ships, type: :binary_id, on_delete: :restrict),
        null: false

      add :country, :text, null: false, default: ""
      add :region, :text, null: false, default: ""
      add :city, :text, null: false, default: ""
      add :visionizing_scope, :string
      add :constitutional_default, :boolean, null: false, default: false
      add :furnished_at, :utc_datetime, null: false
    end

    create index(:xt_yt_interrelationings, [:tuple_ship_id, :id])
  end
end
