defmodule TupiWeb.ContestControllerTest do
  use TupiWeb.ConnCase, async: false

  alias Tupi.Accounts
  alias Tupi.Tenders

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.mode(Tupi.Repo, :auto)
    {:ok, api_authenticate()}
  end

  describe "List all Contests" do
    test "GET /contests with manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest = build(:contest)
      Tenders.create_contest(%{"name" => "MiEI19/20",
        "begin" => contest.begin,
        "end" => contest.end,
        "manager_id" => user.id})
      Tenders.create_contest(%{"name" => "CC19/20",
        "begin" => contest.begin,
        "end" => contest.end,
        "manager_id" => user.id})
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.contest_path(conn, :index))
        |> doc()
      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_contests_manager, user)
    end
  end

  describe "Show Contest" do
    test "GET /contests/:id with manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest = build(:contest)
      {:ok, tender} = Tenders.create_contest(%{"name" => "MiEI21/22",
        "begin" => contest.begin,
        "end" => contest.end,
        "manager_id" => user.id})
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.contest_path(conn, :show, tender.slug))
        |> doc()
      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :get_contest_slug!, user)
    end

    test "GET /contests/:id with applicant" do
      applicant = create_applicant_strategy(:applicant)
      %{conn: conn, user: user} = api_authenticate(applicant.user)

      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.contest_path(conn, :show, "miei1819"))
        |> doc()
      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :get_contest_slug!, user, "miei1819")
    end

    test "GET /contests/:id with non manager", %{conn: conn, user: user} do
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.contest_path(conn, :show, "miei1819"))
        |> doc()
      assert json_response(conn, 401)["errors"] != []
      assert Bodyguard.permit(Accounts, :get_contest_slug!, user) == {:error, :unauthorized}
    end
  end

  describe "Create Contest" do
    test "POST /contests with manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest = build(:contest)
      setting = build(:setting)
      struct = %{data: %{attributes:
        %{name: "MiEI22/23", begin: contest.begin, end: contest.end,
        settings: [%{type_key: setting.type_key, allocations: setting.allocations}]}, 
        type: "contests"}}
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> post(Routes.contest_path(conn, :create), struct)
        |> doc()
      assert Bodyguard.permit(Accounts, :create_contest, user)
      assert json_response(conn, 201)["data"]["attributes"] != %{}
    end

    test "POST /contests with non manager", %{conn: conn, user: user} do
      contest = build(:contest)
      struct = %{data: %{attributes:
        %{name: "MiEI19/20", begin: contest.begin, end: contest.end}, 
        type: "contests"}}
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> post(Routes.contest_path(conn, :create), struct)
        |> doc()
      assert Bodyguard.permit(Accounts, :create_contest, user) == {:error, :unauthorized}
      assert json_response(conn, 401)["errors"] != []
    end
  end

  describe "Update Contest" do
    test "PATCH /contests/:id with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest = build(:contest)
      {:ok, tender} = Tenders.create_contest(%{"name" => "MiEI2324",
        "begin" => contest.begin,
        "end" => contest.end,
        "manager_id" => user.id})

      struct = %{
        data: %{
          attributes: %{
            begin: contest.begin,
            end: contest.end
          },
          type: "contests",
          id: tender.slug
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.contest_path(conn, :update, tender.slug), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :update_contest, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "PATCH /contests/:id with invalid manager", %{conn: conn, user: user} do
      contest = build(:contest)

      struct = %{
        data: %{
          attributes: %{
            begin: contest.begin,
            end: contest.end
          },
          type: "contests",
          id: "miei1819"
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.contest_path(conn, :update, "miei1819"), struct)
        |> plug_doc(module: TupiWeb.ContestController, action: :update)
        |> doc()

      assert Bodyguard.permit(Accounts, :update_contest, user) == {:error, :unauthorized}
      assert json_response(conn, 401)["errors"] != []
    end
  end

  describe "Delete Contest" do
    test "DELETE /contests/:id with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest = build(:contest)
      {:ok, tender} = Tenders.create_contest(%{"name" => "MiEI26/27",
        "begin" => contest.begin,
        "end" => contest.end,
        "manager_id" => user.id})

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("tenant", tender.slug)
        |> delete(Routes.contest_path(conn, :delete, tender.slug))
        |> plug_doc(module: TupiWeb.ContestController, action: :delete)
        |> doc()

      assert conn.status == 204
      assert Bodyguard.permit(Accounts, :delete_contest, user)
    end
  end

  describe "Show Applicant in Contest" do
    test "GET /contests/:id/applicant with self applicant" do
      applicant = create_applicant_strategy(:applicant)
      %{conn: conn, user: user} = api_authenticate(applicant.user)

      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.contest_path(conn, :applicant, "miei1819"))
        |> doc()
      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :get_user_preload!, user)
    end

    test "GET /contests/:id/applicant with non self applicant", %{conn: conn, user: user} do
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.contest_path(conn, :applicant, "miei1819"))
        |> plug_doc(module: TupiWeb.ContestController, action: :applicant)
        |> doc()
      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :get_user_preload!, user) == {:error, :unauthorized}
    end
  end

  describe "Run Mediator in contest" do
    test "POST /contests/:id/mediator with manager, after end", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest = build(:contest)
      {:ok, tender} = Tenders.create_contest(%{"name" => "MiEI2425",
        "begin" => contest.begin,
        "end" => contest.end,
        "manager_id" => user.id})
      contest_update_after_end(tender.slug)

      conn = conn
        |> put_req_header("tenant", tender.slug)
        |> put_req_header("accept", "application/json")
        |> post(Routes.contest_path(conn, :mediator, tender.slug))
        |> doc()

      assert conn.status == 202
      assert Bodyguard.permit(Accounts, :allocate_applicants, user)
    end

    test "POST /contests/:id/mediator with manager, before end", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest = build(:contest)
      {:ok, tender} = Tenders.create_contest(%{"name" => "MiEI2526",
        "begin" => contest.begin,
        "end" => contest.end,
        "manager_id" => user.id})

      conn = conn
        |> put_req_header("tenant", tender.slug)
        |> put_req_header("accept", "application/json")
        |> post(Routes.contest_path(conn, :mediator, tender.slug))
        |> doc()

      assert conn.status == 401
      assert Bodyguard.permit(Accounts, :allocate_applicants, user)
    end

    test "POST /contests/:id/mediator with non manager", %{conn: conn, user: user} do
      conn = conn
        |> post(Routes.contest_path(conn, :mediator, "miei1819"))
        |> plug_doc(module: TupiWeb.ContestController, action: :mediator)
        |> doc()
      assert conn.status == 404
      assert Bodyguard.permit(Accounts, :allocate_applicants, user) == {:error, :unauthorized}
    end
  end
end
