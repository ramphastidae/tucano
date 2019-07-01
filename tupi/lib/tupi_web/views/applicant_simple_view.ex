defmodule TupiWeb.ApplicantSimpleView do
  use TupiWeb, :view
  use JSONAPI.View, type: "applicants"

  def fields do
    [
      :group,
      :score,
      :uni_number
    ]
  end
end
