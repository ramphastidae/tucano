defmodule Tupi.UserStrategy do
  use ExMachina.Strategy, function_name: :create_user_strategy

  def handle_create_user_strategy(record, _opts) do
    {:ok, user} = Tupi.Accounts.create_user(
                    %{email: record.email, 
                      password: record.password,
                      name: record.name})
    user
  end
end
