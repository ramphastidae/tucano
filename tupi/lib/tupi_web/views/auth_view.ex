defmodule TupiWeb.AuthView do
  use TupiWeb, :view

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
