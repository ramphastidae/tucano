use Timex

Enum.each 1..10, 
  fn x -> Tupi.Accounts.create_manager_seed(
            %{email: "manager#{x}@tupi.pt", password: "manager123"}) 
  end

manager = Tupi.Accounts.get_user_email("manager1@tupi.pt")
Tupi.Tenders.create_contest(
  %{"name" => "MiEI1819", 
    "begin" => Timex.now,
    "end" => Timex.shift(Timex.now, days: 5),
    "manager_id" => manager.id}
)
Tupi.Tenders.create_contest(
  %{"name" => "MiEI1920", 
    "begin" => Timex.now,
    "end" => Timex.shift(Timex.now, days: 5),
    "manager_id" => manager.id}
)

# Should use bulk insert instead
Enum.each 1..30, 
  fn x -> 
    Tupi.Accounts.create_user_applicant_seed(
      %{"user" => 
        %{"email" => "st#{x}@tupi.pt", "password" => "applicant123", "name" => "Ana"}, 
        "uni_number" => Tupi.Auth.random_string(7), "score" => 15.2, "group" => "MEI"},
      "miei1819")
  end

{:ok, setting} = Tupi.Tenders.create_setting(%{type_key: "Perfil", allocations: 2}, "miei1819")
{:ok, subject} = Tupi.Tenders.create_subject(%{code: "LEI", name: "LEI", 
                                      openings: 100, setting_id: setting.id,
                                      timetables: [%{begin: ~T[09:30:00], 
                                        end: ~T[12:30:00], weekday: 3}],
                                      conflicts: [%{subject_code: "PEI"}]}, 
                                    "miei1819")

applicant = Tupi.Accounts.list_applicants("miei1819") |> List.first()
{:ok, _applicant} = Tupi.Accounts.update_applicant(applicant, 
                      %{applications: [%{preference: 1, subject_id: subject.id}]},
                      "miei1819")
