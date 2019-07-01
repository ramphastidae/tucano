defmodule Tupi.AdminFactory do
  defmacro __using__(_opts) do
    quote do
      def admin_factory do
        %Tupi.Accounts.User{
          name: "Jane Smith",
          email: sequence(:email, &"admin#{&1}@tucano.pt"),
          password: "admin12345",
          level: "admin"
        }
      end
    end
  end
end
