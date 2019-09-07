defmodule Tupi.Repo.Migrations.ApplicantSettings do
  use Ecto.Migration

  def change do
    create table(:applicant_settings) do
      add :type_key, :string
      add :allocations, :integer
      add :applicant_id, references(:applicants)

      timestamps()
    end
  end
end
