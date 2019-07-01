defmodule TupiWeb.UserController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Auth

  action_fallback TupiWeb.FallbackController

  def index(conn, _params) do
    user = Auth.current_user(conn)
    users = [Accounts.get_user!(user.id)]
    render(conn, "index.json", %{data: users})
  end

  def show(conn, %{"id" => id}) do
    user_conn = Auth.current_user(conn)
    user = Accounts.get_user!(id)
    with :ok <- Bodyguard.permit(Accounts, :get_user!, user_conn, user) do
      render(conn, "show.json", %{data: user})
    end
  end
end
