defmodule Tupi.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :type_key, :string
      add :allocations, :integer

      timestamps()
    end

    create unique_index(:settings, [:type_key])

    alter table(:subjects) do
      add :setting_id, references(:settings)
    end
  end
end
