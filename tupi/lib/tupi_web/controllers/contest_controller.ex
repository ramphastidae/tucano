defmodule TupiWeb.ContestController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Tenders.Contest
  alias Tupi.Auth
  alias Tupi.Tenders
  alias Tupi.Mediator

  action_fallback TupiWeb.FallbackController

  def index(conn, _params) do
    user = Auth.current_user(conn)

    cond do
      Accounts.is_manager(user) ->
        with :ok <- Bodyguard.permit(Accounts, :list_contests_manager, user) do
          contests = Tenders.list_contests_manager(user)
          render(conn, "index.json", %{data: contests})
        end

      Accounts.is_normal(user) ->
        with :ok <- Bodyguard.permit(Accounts, :list_contests_applicant, user) do
          contests = Tenders.list_contests_applicant(user)
          render(conn, "index.json", %{data: contests})
        end
    end
  end

  def show(conn, %{"id" => slug}) do
    user = Auth.current_user(conn)

    with :ok <- Bodyguard.permit(Accounts, :get_contest_slug!, user, slug) do
      contest = Tenders.get_contest_slug!(slug)
      render(conn, "show.json", %{data: contest})
    end
  end

  def create(conn, %{"data" => %{"attributes" => contest_params}}) do
    user = Auth.current_user(conn)

    with :ok <- Bodyguard.permit(Accounts, :create_contest, user) do
      contest_params = Map.put(contest_params, "manager_id", user.id)

      with {:ok, %Contest{} = contest} <- Tenders.create_contest(contest_params) do
        conn
        |> put_status(:created)
        |> render("show.json", %{data: contest})
      end
    end
  end

  def update(conn, %{"id" => slug, "data" => %{"attributes" => contest_params}}) do
    user = Auth.current_user(conn)

    with :ok <- Bodyguard.permit(Accounts, :update_contest, user) do
      contest = Tenders.get_contest_slug!(slug)

      with {:ok, %Contest{} = contest} <-
             Tenders.update_contest(contest, contest_params) do
        render(conn, "show.json", %{data: contest})
      end
    end
  end

  def delete(conn, %{"id" => slug}) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :delete_contest, user) do
      contest = Tenders.get_contest_slug!(slug)
      with {:ok, %Contest{}} <-
             Tenders.delete_contest(contest) do
        send_resp(conn, :no_content, "")
      end
    end
  end

  def applicant(conn, _params) do
    user = Auth.current_user(conn)

    with :ok <- Bodyguard.permit(Accounts, :get_user_preload!, user) do
      user = Accounts.get_user_preload!(user.id, Tenders.get_contest_header(conn))

      if is_nil(user.applicant) do
        {:error, :unauthorized}
      else
        applicant =
          Accounts.get_applicant_preload!(user.applicant.id, Tenders.get_contest_header(conn))

        conn
        |> put_view(TupiWeb.ApplicantView)
        |> render("show.json", %{data: applicant})
      end
    end
  end

  def mediator(conn, _params) do
    user = Auth.current_user(conn)
    contest = Tenders.get_contest_header(conn)

    with :ok <- Bodyguard.permit(Accounts, :allocate_applicants, user),
         :ok <- Bodyguard.permit(Accounts, :allocate_applicants, Tenders.get_contest_slug!(contest), :after_end) do
      with :ok <- Mediator.allocate_applicants(Tenders.get_contest_header(conn)) do
        conn
        |> send_resp(:accepted, "")
      end
    end
  end
end
