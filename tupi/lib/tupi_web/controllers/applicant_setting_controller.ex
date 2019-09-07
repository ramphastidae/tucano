defmodule TupiWeb.ApplicantSettingController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Auth
  alias Tupi.Tenders
  alias Tupi.Tenders.ApplicantSetting

  action_fallback TupiWeb.FallbackController

  def index(conn, %{"applicant_id" => applicant_id}) do
    user = Auth.current_user(conn)
    applicant = Accounts.get_applicant_preload!(applicant_id, Tenders.get_contest_header(conn))
    with :ok <- Bodyguard.permit(Accounts, :list_applicant_settings, user, applicant.user) do
      applicant_settings = Tenders.list_applicant_settings(applicant_id, Tenders.get_contest_header(conn))
      render(conn, "index.json", %{data: applicant_settings})
    end
  end

  def update(conn, %{"applicant_id" => applicant_id, "id" => id, "data" => %{"attributes" => %{"applicant_setting" => setting_params}}}) do
    user = Auth.current_user(conn)
    applicant = Accounts.get_applicant_preload!(applicant_id, Tenders.get_contest_header(conn))
    contest = Tenders.get_contest_header(conn)

    with :ok <- Bodyguard.permit(Accounts, :update_applicant_setting, user, applicant.user),
         :ok <- Bodyguard.permit(Accounts, :update_applicant_setting, Tenders.get_contest_slug!(contest), :period) do
      applicant_setting = Tenders.get_applicant_setting!(id, Tenders.get_contest_header(conn))
      with {:ok, %ApplicantSetting{} = applicant_setting} <-
          Tenders.update_applicant_setting(applicant_setting, setting_params, Tenders.get_contest_header(conn)) do
        render(conn, "show.json", %{data: applicant_setting})
      end
    end
  end
end
