defmodule Tupi.Tenders.Subject do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tupi.Accounts.Applicant
  alias Tupi.Tenders.Application
  alias Tupi.Tenders.Conflict
  alias Tupi.Tenders.Timetable
  alias Tupi.Tenders.Setting

  schema "subjects" do
    field :code, :string
    field :name, :string
    field :openings, :integer

    has_many :applications, Application
    has_many :timetables, Timetable, on_replace: :delete
    has_many :conflicts, Conflict, on_replace: :delete
    many_to_many :applicants, Applicant, join_through: Application
    belongs_to :setting, Setting

    timestamps()
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:code, :name, :openings, :setting_id])
    |> cast_assoc(:timetables)
    |> cast_assoc(:conflicts)
    |> validate_required([:code, :name, :openings, :setting_id])
    |> unique_constraint(:code)
  end

  def update_changeset(subject, attrs) do
    subject
    |> cast(attrs, [:name, :openings])
    |> cast_assoc(:timetables)
    |> cast_assoc(:conflicts)
    #|> validate_required([:name, :openings])
  end
end
