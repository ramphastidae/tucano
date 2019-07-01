defmodule TupiWeb.ApplicationView do
  use TupiWeb, :view
  use JSONAPI.View, type: "applications"

  def fields do
    [
      :preference, 
      :stage
    ]
  end

  def relationships do
    [subject: {TupiWeb.SubjectView, :include}]
  end
end
