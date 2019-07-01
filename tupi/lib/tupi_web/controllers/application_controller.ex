defmodule TupiWeb.ApplicationController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Auth
  alias Tupi.Tenders

  action_fallback TupiWeb.FallbackController

  def index(conn, %{"applicant_id" => applicant_id}) do
    user = Auth.current_user(conn)
    contest = Tenders.get_contest_header(conn)
    applicant = Accounts.get_applicant_preload!(applicant_id, contest)

    with :ok <- Bodyguard.permit(Accounts, :list_applicant_applications, user, applicant.user),
         :ok <- Bodyguard.permit(Accounts, :list_applicant_applications, Tenders.get_contest_slug!(contest), :period_after_end) do
      applications = Tenders.list_applicant_applications(applicant_id, contest)
      render(conn, "index.json", %{data: applications})
    end
  end
end
