defmodule Tupi.ApplicantFactory do
  defmacro __using__(_opts) do
    quote do
      def applicant_factory do
        %Tupi.Accounts.Applicant{
          group: "MiEI",
          score: 15.2,
          uni_number: Tupi.Auth.random_string(7),
          user: build(:user)
        }
      end
    end
  end
end
