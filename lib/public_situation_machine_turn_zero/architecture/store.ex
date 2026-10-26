defmodule PublicSituationMachineTurnZero.Architecture.Store do
  @moduledoc "Architectural Standing and shared material ledger; optimistic locking rejects stale instruments."
  alias PublicSituationMachineTurnZero.{Repo, Architecture}
  alias Architecture.Record
  def create, do: Repo.insert!(%Record{standing: Architecture.new().standing})

  def fetch(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %Record{standing: %{"version" => version}} = record <-
           Repo.get(Record, uuid),
         true <- version in ["spindle-round-one", "spindle-rail-pass"],
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
