import Config

config :public_situation_machine_turn_zero,
  parkinging_stand_registry_path:
    Path.join(
      System.tmp_dir!(),
      "public_situation_machine_turn_zero/parkinging_stands_test_#{System.pid()}.dets"
    )

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :public_situation_machine_turn_zero, PublicSituationMachineTurnZeroWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "qjW8TiVQyoNtpaTnmzkqfNGf199Q8oPTGxoIY0GSXtVqErNhFByGF+1HdU2tSHFz",
  server: false

# In test we don't send emails
config :public_situation_machine_turn_zero, PublicSituationMachineTurnZero.Mailer,
  adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
