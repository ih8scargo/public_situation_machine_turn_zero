defmodule PublicSituationMachineTurnZero.Repo do
  use Ecto.Repo,
    otp_app: :public_situation_machine_turn_zero,
    adapter: Ecto.Adapters.Postgres
end
