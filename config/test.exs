import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :livre, Livre.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "livre_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :livre, LivreWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "K/5se6llEI0D8gJyAm6C1ZXtQyiKRQIOaVVEuWWdSfQbOnEI/zunAtokYGek5cpe",
  server: false

config :livre, Livre.Accounts, admin_emails: ["admin@livre.com", "admintest123@livre.com"]

config :livre, LivreWeb.SSO,
  provider_test: [
    client_id: "provider_test_client_id",
    site: "http://test.com",
    authorize_url: "http://localhost:14000/authorize",
    token_url: "http://localhost:14000/token",
    userinfo_url: "http://localhost:14000/test_provider/userinfo",
    client_secret: "mysecret"
  ]

# In test we don't send emails.
config :livre, Livre.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Don't print logs during tests
config :logger, level: :none

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
