defmodule Tupi.ConflictFactory do
  defmacro __using__(_opts) do
    quote do
      def conflict_factory do
        %Tupi.Tenders.Conflict{
          subject_code: sequence(:code, &"PEI#{&1}"),
        }
      end
    end
  end
end
