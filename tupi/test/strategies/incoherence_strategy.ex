defmodule Tupi.IncoherenceStrategy do
  use ExMachina.Strategy, function_name: :create_incoherence_strategy

  def handle_create_incoherence_strategy(record, _opts) do
    {:ok, applicant} = Tupi.Accounts.create_applicant(
                    %{"user" => 
                      %{"email" => record.applicant.user.email, 
                        "password" => record.applicant.user.password, 
                        "name" => record.applicant.user.name}, 
                      "uni_number" => record.applicant.uni_number, 
                      "score" => record.applicant.score, 
                      "group" => record.applicant.group},
                    "miei1819")

    {:ok, incoherence} = Tupi.Tenders.create_incoherence(
                    %{"description" => record.description,
                    "applicant_id" => applicant.id},
                    "miei1819")
    incoherence
  end
end
