use Mix.Config

# "You can use `mix phx.gen.secret` to get one"
config :tupi, TupiWeb.Endpoint,
  secret_key_base: "Change Me"

# Configure your database
config :tupi, Tupi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "change_me",
  password: "change_me",
  database: "tupi_prod",
  pool_size: 15

# "You can use `mix guardian.gen.secret` to get one"
config :tupi, Tupi.Guardian,
  issuer: "tupi",
  secret_key: "Change Me"

config :tupi, Tupi.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.domain",
  hostname: "your.domain",
  port: 1025,
  username: "your.name@your.domain", # or {:system, "SMTP_USERNAME"}
  password: "pa55word", # or {:system, "SMTP_PASSWORD"}
  tls: :always, # can be `:always` or `:never`
  allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"],
  ssl: false, # can be `true`
  retries: 1,
  no_mx_lookups: false, # can be `true`
  auth: :always 

# Env, should be bottom
System.put_env(%{"FROM_EMAIL" => "geral@tupi.tupi"})
System.put_env(%{"FRONTEND_URL" => "http://localhost"})
