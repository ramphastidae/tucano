defmodule TupiWeb.ApplicantController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Accounts.Applicant
  alias Tupi.Auth
  alias Tupi.Tenders

  action_fallback TupiWeb.FallbackController

  def index(conn, _params) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :list_applicants, user) do
      applicants = Accounts.list_applicants(Tenders.get_contest_header(conn))
      render(conn, "index.json", %{data: applicants})
    end
  end

  def create(conn, %{"data" => %{"attributes" => applicant_params}}) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :create_applicant, user),
         {:ok, %Applicant{} = applicant} <- 
          Accounts.create_applicant(applicant_params, Tenders.get_contest_header(conn)) do
      conn
      |> put_status(:created)
      |> render("show.json", %{data: applicant})
    end
  end

  #def create(conn, %{"data" => attributes_list}) do
  #  user = Auth.current_user(conn)
  #  with :ok <- Bodyguard.permit(Accounts, :create_applicant_multi, user),
  #       {:ok, changes} <- 
  #        Accounts.create_applicant_multi(attributes_list, 
  #          Tenders.get_contest_header(conn)) do
  #    conn
  #    |> put_status(:created)
  #    |> render("index.json", %{data: changes})
  #  end
  #end

  def show(conn, %{"id" => id}) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :get_applicant_preload!, user) do
      applicant = Accounts.get_applicant_preload!(id, Tenders.get_contest_header(conn))
      render(conn, "show.json", %{data: applicant})
    end
  end

  def update(conn, %{"id" => id, "data" => %{"attributes" => applicant_params}}) do
    user = Auth.current_user(conn)
    contest = Tenders.get_contest_header(conn)
    applicant = Accounts.get_applicant_preload!(id, contest)

    cond do
      Bodyguard.permit(Accounts, :update_applicant, user, applicant.user) == :ok &&
      Bodyguard.permit(Accounts, :update_applicant, Tenders.get_contest_slug!(contest), :period) == :ok ->
        with {:ok, %Applicant{} = applicant} <- 
            Accounts.update_applicant(applicant, applicant_params, contest) do
          render(conn, "show.json", %{data: applicant})
        end
      Bodyguard.permit(Accounts, :manager_update_applicant, user, applicant.user) == :ok ->
        with {:ok, %Applicant{} = applicant} <- 
            Accounts.manager_update_applicant(applicant, applicant_params, contest) do
          render(conn, "show.json", %{data: applicant})
        end
      true -> {:error, :unauthorized}
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Auth.current_user(conn)
    cond do
      id == "all" ->
        with :ok <- Bodyguard.permit(Accounts, :delete_applicant_multi, user) do
          with {:ok, _info} <- Accounts.delete_applicant_multi(Tenders.get_contest_header(conn)) do
            send_resp(conn, :no_content, "")
          end
        end
      true ->
        with :ok <- Bodyguard.permit(Accounts, :delete_applicant, user) do
          applicant = Accounts.get_applicant!(id, Tenders.get_contest_header(conn))
          with {:ok, %Applicant{}} <- 
              Accounts.delete_applicant(applicant, Tenders.get_contest_header(conn)) do
            send_resp(conn, :no_content, "")
          end
        end
    end
  end

  def results(conn, %{"id" => id}) do
    user = Auth.current_user(conn)
    contest = Tenders.get_contest_header(conn)
    applicant = Accounts.get_applicant_preload!(id, Tenders.get_contest_header(conn))

    with :ok <- Bodyguard.permit(Accounts, :list_applicant_results, user, applicant.user),
         :ok <- Bodyguard.permit(Accounts, :list_applicant_results, Tenders.get_contest_slug!(contest), :published) do
      with subjects <- Tenders.list_applicant_results(id, Tenders.get_contest_header(conn)) do
        put_view(conn, TupiWeb.ResultView)
        |> render("index.json", %{data: subjects})
      end
    end
  end
end
