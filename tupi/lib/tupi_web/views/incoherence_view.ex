defmodule TupiWeb.IncoherenceView do
  use TupiWeb, :view
  use JSONAPI.View, type: "incoherences"

  def fields do
    [
      :description, 
      :status
    ]
  end

  def relationships do
    [applicant: {TupiWeb.ApplicantSimpleView, :include}]
  end
end
