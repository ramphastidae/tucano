defmodule Tupi.Repo do
  use Ecto.Repo,
    otp_app: :tupi,
    adapter: Ecto.Adapters.Postgres
end
