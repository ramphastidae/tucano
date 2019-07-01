defmodule Tupi.ApplicationFactory do
  defmacro __using__(_opts) do
    quote do
      def application_factory do
        %Tupi.Tenders.Application{
          preference: 1
        }
      end
    end
  end
end
