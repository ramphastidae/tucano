defmodule Tupi.SettingFactory do
  defmacro __using__(_opts) do
    quote do
      def setting_factory do
        %Tupi.Tenders.Setting{
          type_key: "perfil",
          allocations: 2
        }
      end
    end
  end
end
