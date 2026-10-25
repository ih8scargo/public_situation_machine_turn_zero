defmodule PublicSituationMachineTurnZero.Instrumentation.Store do
  @moduledoc "Independent durable seating snapshots; optimistic locking rejects stale instruments."
  alias PublicSituationMachineTurnZero.{Repo, Instrumentation}
  alias Instrumentation.Record
  def create, do: Repo.insert!(%Record{standing: Instrumentation.new().standing})

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
