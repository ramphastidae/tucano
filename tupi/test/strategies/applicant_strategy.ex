defmodule Tupi.ApplicantStrategy do
  use ExMachina.Strategy, function_name: :create_applicant_strategy

  def handle_create_applicant_strategy(record, _opts) do
    {:ok, user} = Tupi.Accounts.create_applicant(
                    %{"user" => 
                      %{"email" => record.user.email, 
                        "password" => record.user.password, 
                        "name" => record.user.name}, 
                      "uni_number" => record.uni_number, 
                      "score" => record.score, 
                      "group" => record.group},
                    "miei1819")
    user
  end
end
