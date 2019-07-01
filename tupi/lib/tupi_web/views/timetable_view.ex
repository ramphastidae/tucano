defmodule TupiWeb.TimetableView do
  use TupiWeb, :view
  use JSONAPI.View, type: "timetables"

  def fields do
    [
      :begin, 
      :end,
      :weekday
    ]
  end
end
