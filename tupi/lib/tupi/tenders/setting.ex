defmodule Tupi.Tenders.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :type_key, :string
    field :allocations, :integer

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:type_key, :allocations])
    |> validate_required([:type_key, :allocations])
    |> unique_constraint(:type_key)
  end
end
