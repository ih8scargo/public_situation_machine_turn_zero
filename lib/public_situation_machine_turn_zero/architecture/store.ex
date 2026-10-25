defmodule PublicSituationMachineTurnZero.Architecture.Store do
  @moduledoc "Architectural Standing and shared material ledger; optimistic locking rejects stale instruments."
  alias PublicSituationMachineTurnZero.{Repo, Architecture}
  alias Architecture.Record
  def create, do: Repo.insert!(%Record{standing: Architecture.new().standing})

  def create_tunnel_fixture do
    lab =
      Enum.reduce([:calibrate, :position, :appoint, :step], Architecture.new(), fn operation,
                                                                                   lab ->
        {:ok, next} = Architecture.operate(lab, operation)
        next
      end)

    Repo.insert!(%Record{standing: lab.standing})
  end

  def fetch(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %Record{} = record <- Repo.get(Record, uuid),
         do: {:ok, record},
         else: (_ -> {:error, :not_found})
  end

  def save(record, standing) do
    record
    |> Ecto.Changeset.change(standing: standing)
    |> Ecto.Changeset.optimistic_lock(:lock_version)
    |> Repo.update(stale_error_field: :lock_version)
  end
end
