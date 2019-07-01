defmodule Tupi.ContestFactory do
  use Timex
  defmacro __using__(_opts) do
    quote do
      def contest_factory do
        %Tupi.Tenders.Contest{
          name: "MiEI1819",
          begin: Timex.shift(Timex.now, days: -1),
          end: Timex.shift(Timex.now, days: 5)
        }
      end
    end
  end
end
