defmodule TupiWeb.ManagerControllerTest do
  use TupiWeb.ConnCase
  use Bamboo.Test

  alias Tupi.Accounts

  setup do
    {:ok, api_authenticate()}
  end

  describe "List all Managers" do
    test "GET /managers with admin", %{conn: conn, user: user} do
      Accounts.promote_user(user, :admin)
      insert(:manager)
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.manager_path(conn, :index))
        |> doc()
      assert Bodyguard.permit(Accounts, :list_managers, user)
      assert json_response(conn, 200)["data"] != []
    end

    test "GET /managers with non admin", %{conn: conn, user: user} do
      insert(:manager)
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.manager_path(conn, :index))
        |> doc()
      assert Bodyguard.permit(Accounts, :list_managers, user) == {:error, :unauthorized}
      assert json_response(conn, 401)["errors"] != []
    end
  end

  describe "Show Manager" do
    test "GET /managers/:id with admin", %{conn: conn, user: user} do
      Accounts.promote_user(user, :admin)
      manager = insert(:manager)
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.manager_path(conn, :show, manager.id))
        |> doc()
      assert Bodyguard.permit(Accounts, :get_manager!, user)
      assert json_response(conn, 200)["data"] != []
    end

    test "GET /managers/:id with non admin", %{conn: conn, user: user} do
      manager = insert(:manager)
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.manager_path(conn, :show, manager.id))
        |> doc()
      assert Bodyguard.permit(Accounts, :get_manager!, user) == {:error, :unauthorized}
      assert json_response(conn, 401)["errors"] != []
    end
  end

  describe "Create Manager" do
    test "POST /managers with admin", %{conn: conn, user: user} do
      Accounts.promote_user(user, :admin)
      manager = build(:manager)
      struct = %{data: %{attributes: %{email: manager.email}, type: "managers"}}
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> post(Routes.manager_path(conn, :create), struct)
        |> doc()
      assert Bodyguard.permit(Accounts, :create_manager, user)
      assert json_response(conn, 201)["data"]["attributes"] != %{}
      assert_delivered_email send_password_email_test(manager.email)
    end

    test "POST /managers with non admin", %{conn: conn, user: user} do
      manager = build(:manager)
      struct = %{data: %{attributes: %{email: manager.email}, type: "managers"}}
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> post(Routes.manager_path(conn, :create), struct)
        |> doc()
      assert Bodyguard.permit(Accounts, :list_managers, user) == {:error, :unauthorized}
      assert json_response(conn, 401)["errors"] != []
    end
  end

  describe "Update Manager" do
    test "POST /managers/:id with admin", %{conn: conn, user: user} do
      Accounts.promote_user(user, :admin)
      manager = insert(:manager)
      struct = %{data: %{attributes: 
        %{email: manager.email, status: "inactive"}, 
        type: "managers",
        id: Integer.to_string(manager.id)
      }}
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> patch(Routes.manager_path(conn, :update, manager.id), struct)
        |> doc()
      assert Bodyguard.permit(Accounts, :update_manager, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "POST /managers/:id with self manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      struct = %{data: %{attributes: 
        %{email: user.email, password: "newpassword123"}, 
        type: "managers",
        id: Integer.to_string(user.id)
      }}
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> patch(Routes.manager_path(conn, :update, user.id), struct)
        |> doc()
      assert Bodyguard.permit(Accounts, :update_user, user, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "POST /managers/:id with different manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      manager = insert(:manager)
      struct = %{data: %{attributes: 
        %{email: manager.email, password: "newpassword123"}, 
        type: "managers",
        id: Integer.to_string(manager.id)
      }}
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> patch(Routes.manager_path(conn, :update, manager.id), struct)
        |> doc()
      assert Bodyguard.permit(Accounts, :update_user, user, manager) == {:error, :unauthorized}
      assert json_response(conn, 401)["errors"] != []
    end

    test "POST /managers/:id with unauthorized user", %{conn: conn, user: user} do
      manager = insert(:manager)
      struct = %{data: %{attributes: 
        %{email: manager.email, password: "newpassword123"}, 
        type: "managers",
        id: Integer.to_string(manager.id)
      }}
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> patch(Routes.manager_path(conn, :update, manager.id), struct)
        |> doc()
      assert Bodyguard.permit(Accounts, :update_user, user, manager) == {:error, :unauthorized}
      assert json_response(conn, 401)["errors"] != []
    end
  end
end
