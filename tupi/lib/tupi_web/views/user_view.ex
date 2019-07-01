defmodule TupiWeb.UserView do
  use TupiWeb, :view
  use JSONAPI.View, type: "users"

  def fields do
    [
      :email, 
      :name,
      :level
    ]
  end
end
