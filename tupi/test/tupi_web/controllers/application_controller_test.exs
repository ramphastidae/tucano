defmodule TupiWeb.ApplicationControllerTest do
  use TupiWeb.ConnCase

  alias Tupi.Accounts

  setup do
    {:ok, api_authenticate()}
  end

  describe "List all Applications" do
    test "GET /applicants/:applicant_id/applications with valid applicant" do
      applicant = create_applicant_strategy(:applicant)
      subject = create_subject_strategy(:subject)

      #TODO: Should be a strategy
      {:ok, _applicant} = Tupi.Accounts.update_applicant(applicant, 
                      %{applications: [%{preference: 1, subject_id: subject.id}]},
                      "miei1819")

      %{conn: conn, user: user} = api_authenticate(applicant.user)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_application_path(conn, :index, applicant.id))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_applicant_applications, user, applicant.user)
    end

    test "GET /applicants/:applicant_id/applications with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      applicant = create_applicant_strategy(:applicant)
      subject = create_subject_strategy(:subject)

      #TODO: Should be a strategy
      {:ok, _applicant} = Tupi.Accounts.update_applicant(applicant, 
                      %{applications: [%{preference: 1, subject_id: subject.id}]},
                      "miei1819")

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_application_path(conn, :index, applicant.id))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_applicant_applications, user)
    end
  end
end
