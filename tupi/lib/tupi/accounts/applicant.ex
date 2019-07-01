defmodule Tupi.Accounts.Applicant do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Tupi.Accounts.User
  alias Tupi.Tenders.Application
  alias Tupi.Tenders.Subject

  schema "applicants" do
    field :group, :string
    field :score, :float
    field :uni_number, :string

    belongs_to :user, User
    has_many :applications, Application, on_replace: :delete
    many_to_many :subjects, Subject, join_through: Application

    timestamps()
  end

  @doc false
  def changeset(applicant, attrs) do
    applicant
    |> cast(attrs, [:uni_number, :score, :group, :user_id])
    #|> cast_assoc(:user)
    |> validate_required([:uni_number, :score, :group])
    |> unique_constraint(:uni_number)
    |> unique_constraint(:user_id)
  end

  def update_changeset(applicant, attrs) do
    applicant
    |> cast(attrs, [])
    |> cast_assoc(:applications)
  end

  def manager_update_changeset(applicant, attrs) do
    applicant
    |> cast(attrs, [:score, :group])
    |> validate_required([:score, :group])
  end

  def with_applications do
    applications_query = from a in Application, order_by: a.preference
    from q in Tupi.Accounts.Applicant, preload: [applications: ^applications_query]
  end

  def with_applications_order do
    applications_query = 
      from a in Application, 
      inner_join: subject in Subject,
      on: a.subject_id == subject.id,
      order_by: subject.setting_id,
      order_by: a.preference
    from q in Tupi.Accounts.Applicant, preload: [applications: ^applications_query]
  end

  def with_subjects do
    from q in Tupi.Accounts.Applicant, preload: [:subjects]
  end
end
