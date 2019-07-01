defmodule TupiWeb.ConnCaseHelper do
  import Tupi.Factory
  import Phoenix.ConnTest
  import Plug.Conn

  alias Tupi.Email
  alias Tupi.Guardian
  alias Tupi.Accounts.User
  alias Tupi.Repo

  def send_reset_email_test(user_mail) do
    with %User{} = user <- Repo.get_by(User, email: user_mail) do
      Email.send_reset_email(user.email, user.reset_password_token)
    end
  end

  def send_password_email_test(user_mail) do
    with %User{} = user <- Repo.get_by(User, email: user_mail) do
      Email.send_password_email(user.email, user.reset_password_token)
    end
  end

  def contest_setup() do
    user = create_user_strategy(:user)
    Tupi.Accounts.promote_user(user, :manager)
    contest = build(:contest)
    Tupi.Tenders.create_contest(
      %{"name" => contest.name,
        "begin" => contest.begin,
        "end" => contest.end,
        "manager_id" => user.id}
    )
  end

  def contest_update(manager) do
    Tupi.Tenders.get_contest_slug!("miei1819")
    |> Tupi.Tenders.update_contest_helper(%{"manager_id" => manager.id})
  end

  def contest_update_before_begin do
    Tupi.Tenders.get_contest_slug!("miei1819")
    |> Tupi.Tenders.update_contest_helper(%{begin: Timex.shift(Timex.now, days: 2)})
  end

  def contest_update_after_end(slug) do
    Tupi.Tenders.get_contest_slug!(slug)
    |> Tupi.Tenders.update_contest_helper(%{end: Timex.shift(Timex.now, hours: -1)})
  end

  def browser_authenticate(user \\ insert(:user)) do
    conn = build_conn()
    |> assign(:current_user, user)
    %{conn: conn, user: user}
  end

  def api_authenticate(user \\ create_user_strategy(:user)) do
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
    conn = build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{jwt}")
    |> put_req_header("tenant", "miei1819")
    %{conn: conn, user: user}
  end

  def json_api_headers(conn) do
    conn
    |> put_req_header("content-type", "application/vnd.api+json")
    |> put_req_header("accept", "application/vnd.api+json")
  end

  def fetch_json_ids(key, conn, status \\ 200) do
    records = json_response(conn, status)[key]
    Enum.map(records, fn(json) ->
      Map.get(json, "id")
    end)
  end

  def with_session(conn, session_params \\ []) do
    session_opts =
      Plug.Session.init(
        store: :cookie,
        key: "_app",
        encryption_salt: "abc",
        signing_salt: "abc"
      )

    conn
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Session.call(session_opts)
    |> Plug.Conn.fetch_session
    |> Plug.Conn.fetch_query_params
    |> put_session_params_in_session(session_params)
  end

  defp put_session_params_in_session(conn, session_params) do
    List.foldl(session_params, conn, fn ({key, value}, acc)
    -> Plug.Conn.put_session(acc, key, value) end)
  end

  defmacro render_json(template, assigns) do
    view = Module.get_attribute(__CALLER__.module, :view)
    quote do
      render_json(unquote(template), unquote(view), unquote(assigns))
    end
  end
  def render_json(template, view, assigns) do
    view.render(template, assigns) |> format_json
  end

  defp format_json(data) do
    data |> Jason.encode! |> Jason.decode!
  end
end
