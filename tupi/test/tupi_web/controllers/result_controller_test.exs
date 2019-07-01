defmodule TupiWeb.ResultControllerTest do
  use TupiWeb.ConnCase

  alias Tupi.Accounts

  setup do
    {:ok, api_authenticate()}
  end

  describe "List all Results" do
    test "GET /results with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      create_subject_strategy(:subject)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.result_path(conn, :index))
        |> doc()

      assert json_response(conn, 200)
      assert Bodyguard.permit(Accounts, :list_results, user)
    end

    test "GET /results with invalid manager", %{conn: conn, user: user} do
      create_subject_strategy(:subject)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.result_path(conn, :index))
        |> plug_doc(module: TupiWeb.ResultController, action: :index)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :list_results, user) == {:error, :unauthorized}
    end
  end
end
