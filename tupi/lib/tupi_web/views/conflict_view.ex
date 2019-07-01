defmodule TupiWeb.ConflictView do
  use TupiWeb, :view
  use JSONAPI.View, type: "conflicts"

  def fields do
    [:subject_code]
  end
end
