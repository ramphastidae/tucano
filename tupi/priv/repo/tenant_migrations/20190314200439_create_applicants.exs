defmodule Tupi.Repo.Migrations.CreateApplicants do
  use Ecto.Migration

  def change do
    create table(:applicants) do
      add :uni_number, :string, null: false
      add :score, :float
      add :group, :string

      add :user_id, references(:users, on_delete: :delete_all, prefix: "public")

      timestamps()
    end

    create unique_index(:applicants, [:uni_number])
    create unique_index(:applicants, [:user_id])
  end
end
