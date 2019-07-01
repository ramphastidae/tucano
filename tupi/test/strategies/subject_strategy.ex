defmodule Tupi.SubjectStrategy do
  use ExMachina.Strategy, function_name: :create_subject_strategy

  def handle_create_subject_strategy(record, _opts) do
    {:ok, setting} = Tupi.Tenders.create_setting(
                    %{"type_key" => "Profile",
                      "allocations" => 2},
                    "miei1819")

    {:ok, subject} = Tupi.Tenders.create_subject(
                    %{"timetables" => [
                        %{"begin" => record.timetables |> List.first |> Map.get(:begin), 
                        "end" => record.timetables |> List.first |> Map.get(:end), 
                        "weekday" => record.timetables |> List.first |> Map.get(:weekday)}
                      ],
                      "conflicts" => [
                        %{"subject_code" => record.conflicts |> List.first |> Map.get(:subject_code)}
                      ],
                      "code" => record.code, 
                      "name" => record.name, 
                      "openings" => record.openings,
                      "setting_id" => setting.id},
                    "miei1819")
    subject
  end
end
