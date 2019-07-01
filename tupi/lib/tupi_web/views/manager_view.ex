defmodule TupiWeb.ManagerView do
  use TupiWeb, :view
  use JSONAPI.View, type: "managers"

  def fields do
    [
      :email, 
      :name,
      :status
    ]
  end
end
