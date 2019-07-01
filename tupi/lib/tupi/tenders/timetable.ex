defmodule Tupi.Tenders.Timetable do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tupi.Tenders.Subject

  schema "timetables" do
    field :begin, :time
    field :end, :time
    # Monday-Sunday
    field :weekday, :integer

    belongs_to :subject, Subject

    timestamps()
  end

  @doc false
  def changeset(timetable, attrs) do
    timetable
    |> cast(attrs, [:begin, :end, :weekday])
    |> validate_required([:begin, :end, :weekday])
    |> validate_inclusion(:weekday, 1..7)
    |> validate_time
  end

  defp validate_time(changeset) do
    {_, begin_time} = fetch_field(changeset, :begin)
    {_, end_time} = fetch_field(changeset, :end)

    case !!begin_time and !!end_time do
      true ->
        case Time.compare(begin_time, end_time) do
          :lt -> changeset
          _ -> add_error(changeset, :begin, "Begin time can't be after end time.")
        end
      _ -> add_error(changeset, :begin, "Times not correct format.")
    end
  end
end
