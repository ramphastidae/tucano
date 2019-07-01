defmodule Tupi.Repo.Migrations.CreateIncoherences do
  use Ecto.Migration

  def change do
    create table(:incoherences) do
      add :description, :string
      add :status, :integer, null: false
      add :applicant_id, references(:applicants)

      timestamps()
    end

  end
end
