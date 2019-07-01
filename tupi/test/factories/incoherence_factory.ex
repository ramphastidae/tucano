defmodule Tupi.IncoherenceFactory do
  defmacro __using__(_opts) do
    quote do
      def incoherence_factory do
        %Tupi.Tenders.Incoherence{
          description: "My score is wrong.",
          status: "unviewed",
          applicant: build(:applicant)
        }
      end
    end
  end
end
