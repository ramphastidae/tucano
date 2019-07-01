defmodule TupiWeb.SettingController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Auth
  alias Tupi.Tenders

  action_fallback TupiWeb.FallbackController

  def index(conn, _params) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :list_settings, user) do
      settings = Tenders.list_settings(Tenders.get_contest_header(conn))
      render(conn, "index.json", %{data: settings})
    end
  end
end
