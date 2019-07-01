defmodule TupiWeb.IncoherenceControllerTest do
  use TupiWeb.ConnCase

  alias Tupi.Accounts

  setup do
    {:ok, api_authenticate()}
  end

  describe "List all Incoherences" do
    test "GET /incoherences with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      create_incoherence_strategy(:incoherence)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.incoherence_path(conn, :index))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_incoherences, user)
    end

    test "GET /incoherences with invalid manager", %{conn: conn, user: user} do
      create_incoherence_strategy(:incoherence)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.incoherence_path(conn, :index))
        |> plug_doc(module: TupiWeb.IncoherenceController, action: :index)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :list_incoherences, user) == {:error, :unauthorized}
    end

    test "GET /applicants/:applicant_id/incoherences with valid applicant" do
      incoherence = create_incoherence_strategy(:incoherence)
      applicant = Accounts.get_applicant_preload!(incoherence.applicant_id, "miei1819")
      %{conn: conn, user: user} = api_authenticate(applicant.user)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_incoherence_path(conn, :index, applicant.id))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_applicant_incoherences, user, applicant.user)
    end

    test "GET /applicants/:applicant_id/incoherences with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      incoherence = create_incoherence_strategy(:incoherence)
      applicant = Accounts.get_applicant_preload!(incoherence.applicant_id, "miei1819")

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_incoherence_path(conn, :index, applicant.id))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_applicant_incoherences, user)
    end
  end

  describe "Show Incoherence" do
    test "GET /applicants/:applicant_id/incoherences/:id with valid applicant" do
      incoherence = create_incoherence_strategy(:incoherence)
      applicant = Accounts.get_applicant_preload!(incoherence.applicant_id, "miei1819")
      %{conn: conn, user: user} = api_authenticate(applicant.user)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.applicant_incoherence_path(conn, :show, applicant.id, incoherence.id))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :get_applicant_incoherence!, user, applicant.user)
    end
  end

  describe "Create Incoherence" do
    test "POST /applicants/:applicant_id/incoherences with valid applicant" do
      applicant = create_applicant_strategy(:applicant)
      %{conn: conn, user: user} = api_authenticate(applicant.user)
      incoherence = build(:incoherence)

      struct = %{
        data: %{
          attributes: %{
            description: incoherence.description,
            applicant_id: applicant.id
          },
          type: "incoherences"
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> post(Routes.applicant_incoherence_path(conn, :create, applicant.id), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :create_incoherence, user, applicant.user)
      assert json_response(conn, 201)["data"]["attributes"] != %{}
    end

    test "POST /applicants/:applicant_id/incoherences with invalid applicant", %{conn: conn, user: user} do
      applicant = create_applicant_strategy(:applicant)
      incoherence = build(:incoherence)

      struct = %{
        data: %{
          attributes: %{
            description: incoherence.description,
            applicant_id: user.id
          },
          type: "incoherences"
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> post(Routes.applicant_incoherence_path(conn, :create, user.id), struct)
        |> plug_doc(module: TupiWeb.IncoherenceController, action: :create)
        |> doc()

      assert Bodyguard.permit(Accounts, :create_incoherence, user, applicant.user) == {:error, :unauthorized}
      assert json_response(conn, 404)["errors"] != []
    end
  end

  describe "Update Incoherence" do
    test "PUT /incoherences/:id with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      incoherence = create_incoherence_strategy(:incoherence)

      struct = %{
        data: %{
          attributes: %{
            status: "solved"
          },
          type: "incoherences",
          id: incoherence.id |> Integer.to_string
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.incoherence_path(conn, :update, incoherence.id), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :update_incoherence, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "PUT /incoherences/:id with invalid manager", %{conn: conn, user: user} do
      incoherence = create_incoherence_strategy(:incoherence)

      struct = %{
        data: %{
          attributes: %{
            status: "solved"
          },
          type: "incoherences",
          id: incoherence.id |> Integer.to_string
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.incoherence_path(conn, :update, incoherence.id), struct)
        |> plug_doc(module: TupiWeb.IncoherenceController, action: :update)
        |> doc()

      assert Bodyguard.permit(Accounts, :update_incoherence, user) == {:error, :unauthorized}
      assert json_response(conn, 404)["errors"] != []
    end
  end

  describe "Delete Incoherence" do
    test "DELETE /applicants/:applicant_id/incoherences/:id with valid applicant" do
      incoherence = create_incoherence_strategy(:incoherence)
      applicant = Accounts.get_applicant_preload!(incoherence.applicant_id, "miei1819")
      %{conn: conn, user: user} = api_authenticate(applicant.user)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete(Routes.applicant_incoherence_path(conn, :delete, applicant.id, incoherence.id))
        |> doc()

      assert conn.status == 204
      assert Bodyguard.permit(Accounts, :delete_incoherence, user, applicant.user)
    end

    test "DELETE /applicants/:applicant_id/incoherences/:id with invalid applicant", %{conn: conn, user: user} do
      incoherence = create_incoherence_strategy(:incoherence)
      applicant = create_applicant_strategy(:applicant)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete(Routes.applicant_incoherence_path(conn, :delete, applicant.id, incoherence.id))
        |> plug_doc(module: TupiWeb.IncoherenceController, action: :delete)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :delete_incoherence, user, applicant.user) == {:error, :unauthorized}
    end
  end
end
