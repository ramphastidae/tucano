defmodule TupiWeb.ResultView do
  use TupiWeb, :view
  use JSONAPI.View, type: "results"

  def fields do
    [
      :code, 
      :name,
      :openings
    ]
  end

  def relationships do
    [
      setting: {TupiWeb.SettingView, :include},
      applicants: {TupiWeb.ApplicantView, :include}
    ]
  end
end
