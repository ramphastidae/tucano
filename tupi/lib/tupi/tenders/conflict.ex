defmodule Tupi.Tenders.Conflict do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tupi.Tenders.Subject

  schema "conflicts" do
    field :subject_code, :string

    belongs_to :subject, Subject

    timestamps()
  end

  @doc false
  def changeset(conflict, attrs) do
    conflict
    |> cast(attrs, [:subject_code])
    |> validate_required([:subject_code])
  end
end
