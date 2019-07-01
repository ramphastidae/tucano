defmodule Tupi.Repo.Migrations.CreateContests do
  use Ecto.Migration

  def change do
    create table(:contests) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :begin, :utc_datetime
      add :end, :utc_datetime
      add :manager_id, references(:users)
      add :status, :integer, null: false

      timestamps()
    end

    create unique_index(:contests, [:name])
    create unique_index(:contests, [:slug])
  end
end
