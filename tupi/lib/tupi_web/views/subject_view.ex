defmodule TupiWeb.SubjectView do
  use TupiWeb, :view
  use JSONAPI.View, type: "subjects"

  def fields do
    [
      :code, 
      :name,
      :openings
    ]
  end

  def relationships do
    [
      timetables: {TupiWeb.TimetableView, :include},
      setting: {TupiWeb.SettingView, :include},
      conflicts: {TupiWeb.ConflictView, :include}
    ]
  end
end
