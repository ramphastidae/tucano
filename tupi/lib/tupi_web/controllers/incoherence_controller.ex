defmodule TupiWeb.IncoherenceController do
  use TupiWeb, :controller

  alias Tupi.Accounts
  alias Tupi.Auth
  alias Tupi.Tenders.Incoherence
  alias Tupi.Tenders

  action_fallback TupiWeb.FallbackController

  def index(conn, %{"applicant_id" => applicant_id}) do
    user = Auth.current_user(conn)
    applicant = Accounts.get_applicant_preload!(applicant_id, Tenders.get_contest_header(conn))
    with :ok <- Bodyguard.permit(Accounts, :list_applicant_incoherences, user, applicant.user) do
      incoherences = Tenders.list_applicant_incoherences(applicant_id, Tenders.get_contest_header(conn))
      render(conn, "index.json", %{data: incoherences})
    end
  end

  def index(conn, _params) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :list_incoherences, user) do
      incoherences = Tenders.list_incoherences(Tenders.get_contest_header(conn))
      render(conn, "index.json", %{data: incoherences})
    end
  end

  def show(conn, %{"applicant_id" => applicant_id, "id" => id}) do
    user = Auth.current_user(conn)
    applicant = Accounts.get_applicant_preload!(applicant_id, Tenders.get_contest_header(conn))
    with :ok <- Bodyguard.permit(Accounts, :get_applicant_incoherence!, user, applicant.user) do
      incoherence = Tenders.get_applicant_incoherence!(applicant_id, id, Tenders.get_contest_header(conn))
      render(conn, "show.json", %{data: incoherence})
    end
  end

  def create(conn, %{"applicant_id" => applicant_id, "data" => %{"attributes" => incoherence_params}}) do
    user = Auth.current_user(conn)
    applicant = Accounts.get_applicant_preload!(applicant_id, Tenders.get_contest_header(conn))
    with :ok <- Bodyguard.permit(Accounts, :create_incoherence, user, applicant.user),
         {:ok, %Incoherence{} = incoherence} <- 
          Tenders.create_incoherence(incoherence_params, Tenders.get_contest_header(conn)) do
      conn
      |> put_status(:created)
      |> render("show.json", %{data: incoherence})
    end
  end

  def update(conn, %{"id" => id, "data" => %{"attributes" => incoherence_params}}) do
    user = Auth.current_user(conn)
    with :ok <- Bodyguard.permit(Accounts, :update_incoherence, user) do
      incoherence = Tenders.get_incoherence!(id, Tenders.get_contest_header(conn))
      with {:ok, %Incoherence{} = incoherence} <-
          Tenders.update_incoherence(incoherence, incoherence_params, Tenders.get_contest_header(conn)) do
        render(conn, "show.json", %{data: incoherence})
      end
    end
  end

  def delete(conn, %{"applicant_id" => applicant_id, "id" => id}) do
    user = Auth.current_user(conn)
    applicant = Accounts.get_applicant_preload!(applicant_id, Tenders.get_contest_header(conn))
    with :ok <- Bodyguard.permit(Accounts, :delete_incoherence, user, applicant.user) do
      incoherence = Tenders.get_incoherence!(id, Tenders.get_contest_header(conn))
      with {:ok, %Incoherence{}} <- 
          Tenders.delete_incoherence(incoherence, Tenders.get_contest_header(conn)) do
        send_resp(conn, :no_content, "")
      end
    end
  end
end
