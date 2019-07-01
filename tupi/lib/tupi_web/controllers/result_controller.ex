defmodule TupiWeb.ResultController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Auth
  alias Tupi.Tenders

  action_fallback TupiWeb.FallbackController

  def index(conn, _params) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :list_results, user) do
      results = Tenders.list_results(Tenders.get_contest_header(conn))
      render(conn, "index.json", %{data: results})
    end
  end
end
