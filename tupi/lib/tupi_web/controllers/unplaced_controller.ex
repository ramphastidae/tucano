defmodule TupiWeb.UnplacedController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Auth
  alias Tupi.Tenders

  action_fallback TupiWeb.FallbackController

  def index(conn, _params) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :list_unplaced, user) do
      unplaced = Tenders.list_unplaced(Tenders.get_contest_header(conn))
      put_view(conn, TupiWeb.ApplicantView)
      |> render("index.json", %{data: unplaced})
    end
  end
end
