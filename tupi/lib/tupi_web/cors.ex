defmodule TupiWeb.CORS do
  use Corsica.Router,
    origins: [~r{^http://localhost(:\d*)?$}, System.get_env("FRONTEND_URL")],
    log: [rejected: :error, invalid: :warn, accepted: :debug],
    allow_headers: :all,
    allow_credentials: true,
    max_age: 600

  resource "/*"
end
