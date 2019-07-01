defmodule Tupi.SettingStrategy do
  use ExMachina.Strategy, function_name: :create_setting_strategy

  def handle_create_setting_strategy(record, _opts) do
    {:ok, setting} = Tupi.Tenders.create_setting(
                    %{"type_key" => record.type_key,
                      "allocations" => record.allocations},
                    "miei1819")
    setting
  end
end
