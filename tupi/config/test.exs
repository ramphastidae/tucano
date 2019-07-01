use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tupi, TupiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :tupi, Tupi.Repo,
  database: "tupi_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Fast testing only
config :bcrypt_elixir, :log_rounds, 4

# Guardian config
config :tupi, Tupi.Guardian,
  issuer: "tupi",
  secret_key: "3hyR55lGL39D6PuSpIbP9xs9hVXoczZDbxYNSbFGwVKCPFSrOU23TtqhwsmdXVVV"

# Bamboo config
config :tupi, Tupi.Mailer,
  adapter: Bamboo.TestAdapter

# Env
System.put_env(%{"FROM_EMAIL" => "geral@tupi.tupi"})
System.put_env(%{"FRONTEND_URL" => "www.tupi.tupi"})
