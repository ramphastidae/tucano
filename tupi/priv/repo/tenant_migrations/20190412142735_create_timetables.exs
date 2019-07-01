defmodule Tupi.Repo.Migrations.CreateTimetables do
  use Ecto.Migration

  def change do
    create table(:timetables) do
      add :begin, :time
      add :end, :time
      add :weekday, :integer

      add :subject_id, references(:subjects, on_delete: :delete_all)

      timestamps()
    end

  end
end
