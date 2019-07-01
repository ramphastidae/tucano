defmodule TupiWeb.ApplicantControllerTest do
  use TupiWeb.ConnCase
  use Bamboo.Test

  alias Tupi.Accounts

  setup do
    {:ok, api_authenticate()}
  end

  describe "List all Applicants" do
    test "GET /applicants with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_path(conn, :index))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_applicants, user)
    end

    test "GET /applicants with invalid manager", %{conn: conn, user: user} do
      create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_path(conn, :index))
        |> plug_doc(module: TupiWeb.ApplicantController, action: :index)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :list_applicants, user) == {:error, :unauthorized}
    end
  end

  describe "Show Applicant" do
    test "GET /applicants/:id with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      applicant = create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_path(conn, :show, applicant.id))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :get_applicant_preload!, user)
    end

    test "GET /applicants/:id with invalid manager", %{conn: conn, user: user} do
      applicant = create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_path(conn, :show, applicant.id))
        |> plug_doc(module: TupiWeb.ApplicantController, action: :show)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :get_applicant_preload!, user) == {:error, :unauthorized}
    end
  end

  describe "Create Applicant" do
    test "POST /applicants with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      applicant = build(:applicant)

      struct = %{
        data: %{
          attributes: %{
            group: applicant.group,
            score: applicant.score,
            uni_number: applicant.uni_number,
            user: %{email: applicant.user.email, name: applicant.user.name}
          },
          type: "applicants"
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> post(Routes.applicant_path(conn, :create), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :create_applicant, user)
      assert json_response(conn, 201)["data"]["attributes"] != %{}
      assert_delivered_email(send_password_email_test(applicant.user.email))
    end

    # test "POST /applicants bulk with valid manager", %{conn: conn, user: user} do
    #  Accounts.promote_user(user, :manager)
    #  applicant = build(:applicant)
    #  applicant2 = build(:applicant)
    #  struct = %{"data" => [
    #    %{"attributes" =>
    #      %{"group" => applicant.group,
    #        "score" => applicant.score, "uni_number" => applicant.uni_number,
    #        "user" => %{"email" => applicant.user.email, "name" => applicant.user.name}},
    #        "type" => "applicants"},
    #    %{"attributes" =>
    #      %{"group" => applicant2.group,
    #        "score" => applicant2.score, "uni_number" => applicant2.uni_number,
    #        "user" => %{"email" => applicant2.user.email, "name" => applicant2.user.name}},
    #        "type" => "applicants"}
    #  ]}

    #  conn = conn
    #    |> json_api_headers()
    #    |> post(Routes.applicant_path(conn, :create), struct)
    #    |> doc()
    #  assert Bodyguard.permit(Accounts, :create_applicant_multi, user)
    #  assert json_response(conn, 201)["data"] != []
    #  assert_delivered_email send_password_email_test(applicant.user.email)
    #  assert_delivered_email send_password_email_test(applicant2.user.email)
    # end

    test "POST /applicants with invalid manager", %{conn: conn, user: user} do
      applicant = build(:applicant)

      struct = %{
        data: %{
          attributes: %{
            group: applicant.group,
            score: applicant.score,
            uni_number: applicant.uni_number,
            user: %{email: applicant.user.email, name: applicant.user.name}
          },
          type: "applicants"
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> post(Routes.applicant_path(conn, :create), struct)
        |> plug_doc(module: TupiWeb.ApplicantController, action: :create)
        |> doc()

      assert Bodyguard.permit(Accounts, :create_applicant, user) == {:error, :unauthorized}
      assert json_response(conn, 404)["errors"] != []
    end
  end

  describe "Update Applicant" do
    test "PATCH /applicants/:id with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      applicant = create_applicant_strategy(:applicant)

      struct = %{
        data: %{
          attributes: %{
            group: applicant.group,
            score: 18.8
          },
          type: "applicants",
          id: applicant.id |> Integer.to_string()
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.applicant_path(conn, :update, applicant.id), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :manager_update_applicant, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "PATCH /applicants/:id with invalid manager", %{conn: conn, user: user} do
      applicant = create_applicant_strategy(:applicant)

      struct = %{
        data: %{
          attributes: %{
            group: applicant.group,
            score: applicant.score
          },
          type: "applicants",
          id: applicant.id |> Integer.to_string()
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.applicant_path(conn, :update, applicant.id), struct)
        |> plug_doc(module: TupiWeb.ApplicantController, action: :update)
        |> doc()

      assert Bodyguard.permit(Accounts, :manager_update_applicant, user) ==
               {:error, :unauthorized}

      assert json_response(conn, 404)["errors"] != []
    end

    test "PATCH /applicants/:id with self applicant" do
      applicant = create_applicant_strategy(:applicant)
      %{conn: conn, user: user} = api_authenticate(applicant.user)
      subject = create_subject_strategy(:subject)

      struct = %{
        data: %{
          attributes: %{
            applications: [
              %{
                preference: 1,
                subject_id: subject.id
              }
            ]
          },
          type: "applicants",
          id: applicant.id |> Integer.to_string()
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.applicant_path(conn, :update, applicant.id), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :update_applicant, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end
  end

  describe "Delete Applicant" do
    test "DELETE /applicants/all with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      _applicant = create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete(Routes.applicant_path(conn, :delete, "all"))
        |> doc()

      assert conn.status == 204
      assert Bodyguard.permit(Accounts, :delete_applicant_multi, user)
    end

    test "DELETE /applicants/:id with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      applicant = create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete(Routes.applicant_path(conn, :delete, applicant.id))
        |> doc()

      assert conn.status == 204
      assert Bodyguard.permit(Accounts, :delete_applicant, user)
    end

    test "DELETE /applicants/:id with invalid manager", %{conn: conn, user: user} do
      applicant = create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete(Routes.applicant_path(conn, :delete, applicant.id))
        |> plug_doc(module: TupiWeb.ApplicantController, action: :delete)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :delete_applicant, user) == {:error, :unauthorized}
    end
  end

  describe "Results Applicant" do
    #test "GET /applicants/:id/results with valid user" do
    #  applicant = create_applicant_strategy(:applicant)
    #  %{conn: conn, user: user} = api_authenticate(applicant.user)
#
    #  conn =
    #    conn
    #    |> put_req_header("accept", "application/vnd.api+json")
    #    |> get(Routes.applicant_path(conn, :results, applicant.id))
    #    |> doc()
#
    #  assert json_response(conn, 200)["data"] != []
    #  assert Bodyguard.permit(Accounts, :get_applicant_results!, user, applicant.user)
    #end

    test "GET /applicants/:id/results with invalid user", %{conn: conn, user: user} do
      applicant = create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_path(conn, :results, applicant.id))
        |> plug_doc(module: TupiWeb.ApplicantController, action: :results)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :get_applicant_results!, user, applicant.user) == {:error, :unauthorized}
    end
  end
end
