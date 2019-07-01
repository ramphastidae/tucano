defmodule Tupi.TimetableFactory do
  defmacro __using__(_opts) do
    quote do
      def timetable_factory do
        %Tupi.Tenders.Timetable{
          begin: ~T[09:30:00],
          end: ~T[12:30:00],
          weekday: 3
        }
      end
    end
  end
end
