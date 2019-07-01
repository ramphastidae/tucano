defmodule Tupi.Repo.Migrations.CreateConflicts do
  use Ecto.Migration

  def change do
    create table(:conflicts) do
      add :subject_id, references(:subjects)
      add :subject_code, :string

      timestamps()
    end

  end
end
