defmodule Tupi.Tenders.Contest do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tupi.EctoEnums
  alias Tupi.Accounts
  alias Tupi.Accounts.User

  schema "contests" do
    field :name, :string
    field :begin, :utc_datetime
    field :end, :utc_datetime
    field :slug, :string
    field :status, EctoEnums.ContestEnum, default: 1

    belongs_to :manager, User

    timestamps()
  end

  @doc false
  def changeset(contest, attrs) do
    contest
    |> cast(attrs, [:name, :begin, :end, :slug, :manager_id])
    |> validate_required([:name, :begin, :end, :slug, :manager_id])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> validate_time
    |> validate_manager
  end

  def update_changeset(contest, attrs) do
    case DateTime.compare(DateTime.utc_now, contest.begin) do
      :lt -> update_normal(contest, attrs)
      :eq -> update_state(contest, attrs)
      :gt -> update_state(contest, attrs)
    end
  end

  defp update_normal(contest, attrs) do
    contest
    |> cast(attrs, [:begin, :end])
    |> validate_required([:begin, :end])
    |> validate_time
  end

  defp update_state(contest, attrs) do
    contest
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  defp validate_time(changeset) do
    {_, begin_time} = fetch_field(changeset, :begin)
    {_, end_time} = fetch_field(changeset, :end)

    case !!begin_time and !!end_time do
      true ->
        case DateTime.compare(begin_time, end_time) do
          :lt -> changeset
          _ -> add_error(changeset, :begin, "Begin time can't be after end time.")
        end
      _ -> add_error(changeset, :begin, "Times not correct format.")
    end
  end

  defp validate_manager(changeset) do
    {_, id} = fetch_field(changeset, :manager_id)
    case Accounts.is_manager(id) do
      true -> changeset
      false -> add_error(changeset, :manager_id, "Invalid Manager id.")
    end
  end
end
