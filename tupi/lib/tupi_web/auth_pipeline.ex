defmodule Tupi.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :tupi,
  module: Tupi.Guardian,
  error_handler: Tupi.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
