defmodule TupiWeb.ManagerController do
  use TupiWeb, :controller

  alias Tupi.Auth
  alias Tupi.Accounts
  alias Tupi.Accounts.User

  action_fallback TupiWeb.FallbackController

  def index(conn, _params) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :list_managers, user) do
      managers = Accounts.list_managers()
      render(conn, "index.json", %{data: managers})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :get_manager!, user) do
      manager = Accounts.get_manager!(id)
      render(conn, "show.json", %{data: manager})
    end
  end

  def create(conn, %{"data" => %{"attributes" => user_params}}) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :create_manager, user),
         {:ok, manager} <- Accounts.create_manager(user_params) do
      manager = Auth.reset_password_token(manager)
      Tupi.Email.send_password_email(manager.email, manager.reset_password_token)
      |> Tupi.Mailer.deliver_now()

      conn
      |> put_status(:created)
      |> render("show.json", %{data: manager})
    end
  end

  def update(conn, %{"data" => %{"attributes" => user_params}, "id" => id}) do
    user = Auth.current_user(conn)
    manager = Accounts.get_user!(id)
    cond do
      Bodyguard.permit(Accounts, :update_manager, user) == :ok ->
        with {:ok, %User{} = manager} <- Accounts.update_manager(manager, user_params) do
          render(conn, "show.json", %{data: manager})
        end
      Bodyguard.permit(Accounts, :update_user, user, manager) == :ok ->
        with {:ok, %User{} = manager} <- Accounts.update_manager(manager, user_params) do
          render(conn, "show.json", %{data: manager})
        end
      true ->
        Bodyguard.permit(Accounts, :update_user, user)
    end
  end
end
