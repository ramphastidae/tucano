defmodule TupiWeb.AuthController do
  use TupiWeb, :controller

  alias Tupi.Auth
  alias Tupi.Accounts
  alias Tupi.Guardian

  action_fallback TupiWeb.FallbackController

  def sign_up(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> render("jwt.json", jwt: token)
    end
  end

  def user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    #user_preload = Accounts.get_user_preload!(user.id)
    render(conn, "user.json", user: user)
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Auth.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        render(conn, "jwt.json", jwt: token)
      _ ->
        {:error, :unauthorized}
    end
  end
end
