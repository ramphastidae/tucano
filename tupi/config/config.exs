# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tupi,
  ecto_repos: [Tupi.Repo]

# Configures the endpoint
config :tupi, TupiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vLcrUGubYxDB+6JfLJDWGZEx9SRZcpzdopY2Lmh0UTwvQ/OsLXbT6pGeZdLPfUcQ",
  render_errors: [view: TupiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Tupi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian config
config :tupi, Tupi.Guardian,
  issuer: "tupi",
  secret_key: System.get_env("GUARDIAN_SECRET")

# JSONAPI config
config :jsonapi,
  field_transformation: :camelize, # or dasherize
  namespace: "/api/v1"

config :mime, :types, %{
  "application/vnd.api+json" => ["json_api"]
}

config :phoenix, :format_encoders,
  json_api: Jason

config :triplex, 
  repo: Tupi.Repo,
  tenant_prefix: "tupi_",
  reserved_tenants: ~w(admin)

config :slugger, separator_char: ?-

config :mnesia,
  dir: '.mnesia/#{Mix.env}/#{node()}'

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
