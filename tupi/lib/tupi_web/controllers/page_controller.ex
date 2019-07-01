defmodule TupiWeb.PageController do
  use TupiWeb, :controller

  def index(conn, _params) do
    conn
    |> json(%{tupi: "Ramphastos toco"})
  end
end
