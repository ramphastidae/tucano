defmodule TupiWeb.UserControllerTest do
  use TupiWeb.ConnCase

  alias Tupi.Accounts

  setup do
    {:ok, api_authenticate()}
  end

  describe "List self user" do
    test "GET /users", %{conn: conn} do
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> delete_req_header("tenant")
        |> get(Routes.user_path(conn, :index))
        |> doc()
      assert json_response(conn, 200)["data"] != []
    end
  end

  describe "Show User" do
    test "GET /users/:id with admin", %{conn: conn, user: user} do
      Accounts.promote_user(user, :admin)
      user1 = insert(:user)
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> get(Routes.user_path(conn, :show, user1.id))
        |> doc()
      assert Bodyguard.permit(Accounts, :get_user!, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "GET /users/:id with manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      user1 = insert(:user)
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> get(Routes.user_path(conn, :show, user1.id))
        |> doc()
      assert Bodyguard.permit(Accounts, :get_user!, user, user1)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "GET /users/:id with self user", %{conn: conn, user: user} do
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> get(Routes.user_path(conn, :show, user.id))
        |> doc()
      assert Bodyguard.permit(Accounts, :get_user!, user, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "GET /users/:id with invalid user", %{conn: conn, user: user} do
      user1 = insert(:user)
      conn = conn
        |> json_api_headers()
        |> delete_req_header("tenant")
        |> get(Routes.user_path(conn, :show, user1.id))
        |> doc()
      assert Bodyguard.permit(Accounts, :get_user!, user, user1) == {:error, :unauthorized}
      assert json_response(conn, 401)["errors"] != []
    end
  end
end
