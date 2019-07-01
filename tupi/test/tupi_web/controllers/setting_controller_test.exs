defmodule TupiWeb.SettingControllerTest do
  use TupiWeb.ConnCase

  alias Tupi.Accounts

  setup do
    {:ok, api_authenticate()}
  end

  describe "List all Settings" do
    test "GET /settings with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      create_setting_strategy(:setting)
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.setting_path(conn, :index))
        |> doc()
      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_settings, user)
    end

    test "GET /settings with invalid manager", %{conn: conn, user: user} do
      create_setting_strategy(:setting)
      conn = conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.setting_path(conn, :index))
        |> plug_doc(module: TupiWeb.SettingController, action: :index)
        |> doc()
      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :list_settings, user) == {:error, :unauthorized}
    end
  end
end
