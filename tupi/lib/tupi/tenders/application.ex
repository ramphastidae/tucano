defmodule Tupi.Tenders.Application do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tupi.EctoEnums
  alias Tupi.Accounts.Applicant
  alias Tupi.Tenders.Subject

  schema "applications" do
    field :preference, :integer
    field :stage, EctoEnums.StagesEnum, default: 1

    belongs_to :applicant, Applicant
    belongs_to :subject, Subject

    timestamps()
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [:preference, :subject_id])
    |> validate_required([:preference, :subject_id])
    |> unique_constraint(:unique_contest_applicant_subject, 
      name: :unique_applicant_subject, 
      message: "Can only have a Applicant, Subject tuple.")
  end

  def update_changeset(application, attrs) do
    application
    |> cast(attrs, [:stage])
    |> validate_required([:stage])
  end
end
