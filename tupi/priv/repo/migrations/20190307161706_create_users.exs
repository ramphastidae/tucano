defmodule Tupi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string
      add :name, :string
      add :level, :integer, null: false
      add :status, :integer, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
