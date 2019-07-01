defmodule Tupi.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Tupi.Accounts.User{
          name: "Jane Smith",
          email: sequence(:email, &"email#{&1}@tucano.pt"),
          password: "test12345"
          #level: sequence(:role, ["admin", "manager", "normal"])
        }
      end
    end
  end
end
