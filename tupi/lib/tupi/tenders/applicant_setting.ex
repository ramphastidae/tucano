defmodule Tupi.Tenders.ApplicantSetting do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tupi.Accounts.Applicant
  alias Tupi.Tenders

  schema "applicant_settings" do
    field :type_key, :string
    field :allocations, :integer

    belongs_to :applicant, Applicant

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:type_key, :allocations, :applicant_id])
    |> validate_required([:type_key, :allocations, :applicant_id])
  end

  def update_changeset(setting, attrs, tenant) do
    setting
    |> cast(attrs, [:allocations])
    |> validate_required([:allocations])
    |> validate_max_allocations(setting, tenant)
  end

  defp validate_max_allocations(changeset, a_setting, tenant) do
    {_, new_allocations} = fetch_field(changeset, :allocations)
    case valid_allocations?(new_allocations, a_setting, tenant) do
      true -> changeset
      false -> add_error(changeset, :allocations, "Greater than global setting.")
    end
  end

  defp valid_allocations?(allocations, a_setting, tenant) do
    setting = Tenders.get_setting_key!(a_setting.type_key, tenant)
    setting.allocations >= allocations && allocations >= 0
  end
end
