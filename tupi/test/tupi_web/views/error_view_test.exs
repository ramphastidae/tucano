defmodule TupiWeb.ErrorViewTest do
  use TupiWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(TupiWeb.ErrorView, "404.json", []) == 
      %{errors: [%{detail: "Endpoint Not Found"}]}
  end

  test "renders 500.json" do
    assert render(TupiWeb.ErrorView, "500.json", []) ==
      %{errors: [%{detail: "Internal Server Error"}]}
  end
end
