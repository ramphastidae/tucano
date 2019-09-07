defmodule TupiWeb.ApplicantSettingView do
  use TupiWeb, :view
  use JSONAPI.View, type: "applicant_settings"

  def fields do
    [
      :type_key, 
      :allocations
    ]
  end

  def relationships do
    [applicant: {TupiWeb.ApplicantSimpleView, :include}]
  end
end
