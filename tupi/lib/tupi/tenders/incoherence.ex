defmodule Tupi.Tenders.Incoherence do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tupi.EctoEnums
  alias Tupi.Accounts.Applicant

  schema "incoherences" do
    field :description, :string
    field :status, EctoEnums.IncoherenceEnum, default: 1

    belongs_to :applicant, Applicant
    
    timestamps()
  end

  @doc false
  def changeset(incoherence, attrs) do
    incoherence
    |> cast(attrs, [:description, :applicant_id])
    |> validate_required([:description, :applicant_id])
  end

  def update_changeset(incoherence, attrs) do
    incoherence
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
