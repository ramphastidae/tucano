defmodule Tupi.ManagerFactory do
  defmacro __using__(_opts) do
    quote do
      def manager_factory do
        %Tupi.Accounts.User{
          name: "Jane Smith",
          email: sequence(:email, &"manager#{&1}@tucano.pt"),
          password: "manager12345",
          level: "manager"
        }
      end
    end
  end
end
