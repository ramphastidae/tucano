defmodule Tupi.SubjectFactory do
  defmacro __using__(_opts) do
    quote do
      def subject_factory do
        %Tupi.Tenders.Subject{
          code: sequence(:code, &"LEI#{&1}"),
          name: "Laboratório Engenharia Informática",
          openings: 30,
          timetables: build_list(3, :timetable),
          conflicts: build_list(2, :conflict)
        }
      end
    end
  end
end
