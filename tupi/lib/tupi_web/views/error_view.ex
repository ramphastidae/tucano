defmodule TupiWeb.ErrorView do
  use TupiWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render("404.json", _assigns) do
    %{errors: [%{detail: "Endpoint Not Found"}]}
  end

  def render("500.json", _assigns) do
    %{errors: [%{detail: "Internal Server Error"}]}
  end

  def render("401.json", _assigns) do
    %{errors: [%{detail: "Not Authorized", status: 401}]}
  end

  def render("400.json", _assigns) do
    %{errors: [%{detail: "Bad Request", status: 400}]}
  end

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
