defmodule PublicSituationMachineTurnZero.Architecture.Store do
  @moduledoc "Consequential standing with UUID resume, read-only witnesses and optimistic locking."
  alias PublicSituationMachineTurnZero.{Repo, Architecture}
  alias Architecture.Record
  def create, do: Repo.insert!(%Record{standing: Architecture.new().standing})

  def fetch(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %Record{standing: %{"version" => version}} = record <- Repo.get(Record, uuid),
         true <- version in Architecture.versions(),
         do: {:ok, record},
         else: (_ -> {:error, :not_found})
  end

  def save(
        %Record{standing: %{"version" => version}} = record,
        %{"version" => version} = standing
      ) do
    if version == Architecture.version() do
      record
      |> Ecto.Changeset.change(standing: standing)
      |> Ecto.Changeset.optimistic_lock(:lock_version)
      |> Repo.update(stale_error_field: :lock_version)
    else
      {:error, :read_only_witness}
    end
  end

  def save(_, _), do: {:error, :incompatible_version}
end
