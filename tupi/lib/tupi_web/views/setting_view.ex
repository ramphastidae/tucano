defmodule TupiWeb.SettingView do
  use TupiWeb, :view
  use JSONAPI.View, type: "settings"

  def fields do
    [
      :type_key, 
      :allocations
    ]
  end
end
