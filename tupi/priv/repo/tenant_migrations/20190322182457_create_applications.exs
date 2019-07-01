defmodule Tupi.Repo.Migrations.CreateApplications do
  use Ecto.Migration

  def change do
    create table(:applications) do
      add :preference, :integer
      add :stage, :integer, null: false
      add :applicant_id, references(:applicants)

      timestamps()
    end

  end
end
