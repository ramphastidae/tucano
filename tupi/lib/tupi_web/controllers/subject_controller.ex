defmodule TupiWeb.SubjectController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Auth
  alias Tupi.Tenders.Subject
  alias Tupi.Tenders

  action_fallback TupiWeb.FallbackController

  plug JSONAPI.QueryParser,
    filter: ~w(code name),
    sort: ~w(openings),
    view: SubjectView

  def index(conn, _params) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :list_subjects, user) do
      subjects = Tenders.list_subjects(Tenders.get_contest_header(conn), conn.assigns.jsonapi_query.filter)
      render(conn, "index.json", %{data: subjects})
    end
  end

  def create(conn, %{"data" => %{"attributes" => subject_params}}) do
    user = Auth.current_user(conn)
    contest = Tenders.get_contest_header(conn)

    with :ok <- Bodyguard.permit(Accounts, :create_subject, user),
         :ok <- Bodyguard.permit(Accounts, :create_subject, Tenders.get_contest_slug!(contest), :before_begin),
         {:ok, %Subject{} = subject} <- 
          Tenders.create_subject(subject_params, Tenders.get_contest_header(conn)) do
      conn
      |> put_status(:created)
      |> render("show.json", %{data: subject})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :get_subject_preload!, user) do
      subject = Tenders.get_subject_preload!(id, Tenders.get_contest_header(conn))
      render(conn, "show.json", %{data: subject})
    end
  end

  def update(conn, %{"id" => id, "data" => %{"attributes" => subject_params}}) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :update_subject, user) do
      subject = Tenders.get_subject_preload!(id, Tenders.get_contest_header(conn))
      with {:ok, %Subject{} = subject} <-
          Tenders.update_subject(subject, subject_params, Tenders.get_contest_header(conn)) do
        render(conn, "show.json", %{data: subject})
      end
    end
  end
end
