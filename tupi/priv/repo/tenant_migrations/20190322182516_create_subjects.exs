defmodule Tupi.Repo.Migrations.CreateSubjects do
  use Ecto.Migration

  def change do
    create table(:subjects) do
      add :code, :string
      add :name, :string
      add :openings, :integer

      timestamps()
    end

    create unique_index(:subjects, [:code])

    alter table(:applications) do
      add :subject_id, references(:subjects)
    end

    create unique_index(:applications, [:applicant_id, :subject_id], 
      name: :unique_applicant_subject)
  end
end
