if Code.ensure_loaded?(Plug) do
  defmodule Tupi.ContestPlug do

    import Plug.Conn

    alias Tupi.Auth
    alias Tupi.Tenders

    def init(opts), do: opts

    def call(conn, _) do
      user = Auth.current_user(conn)
      contest = Tenders.get_contest_slug!(Tenders.get_contest_header(conn))
      cond do
        contest.manager_id == user.id -> 
          conn
        Tenders.applicant_in_contest?(user, contest) ->
          conn
        true -> 
          conn
          |> TupiWeb.FallbackController.call({:error, :not_found})
          |> halt()
      end
    end
  end
end
