defmodule TupiWeb.AuthControllerTest do
  use TupiWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  #describe "sign_up" do
  #  test "user", %{conn: conn} do
  #    user = build(:user)
  #    struct = %{"user" => %{"email" => user.email, "password" => user.password}}
  #    conn = conn
  #      |> post(Routes.auth_path(conn, :sign_up), struct)
  #      |> doc()
  #    assert json_response(conn, 200)["jwt"] != %{}
  #  end
  #end

  describe "sign_in" do
    test "user with valid credentials", %{conn: conn} do
      user = create_user_strategy(:user)
      struct = %{"email" => user.email, "password" => user.password}
      conn = conn
        |> post(Routes.auth_path(conn, :sign_in), struct)
        |> doc()
      assert json_response(conn, 200)["jwt"] != %{}
    end

    test "user with valid credentials, but inactive", %{conn: conn} do
      user = create_user_strategy(:user)
      {:ok, user} = Tupi.Accounts.update_manager(user, %{status: 2})
      struct = %{"email" => user.email, "password" => user.password}
      conn = conn
        |> post(Routes.auth_path(conn, :sign_in), struct)
        |> doc()
      assert json_response(conn, :unauthorized)["errors"] != %{}
    end

    test "user with invalid credentials", %{conn: conn} do
      user = create_user_strategy(:user)
      struct = %{"email" => user.email, "password" => "test1234"}
      conn = conn
      |> post(Routes.auth_path(conn, :sign_in), struct)
      |> doc()
      assert json_response(conn, :unauthorized)["errors"] != %{}
    end
  end
end
