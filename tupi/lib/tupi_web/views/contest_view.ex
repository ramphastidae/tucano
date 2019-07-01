defmodule TupiWeb.ContestView do
  use TupiWeb, :view
  use JSONAPI.View, type: "contests"

  def fields do
    [
      :name,
      :begin,
      :end,
      :slug
    ]
  end
end
