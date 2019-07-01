defmodule Tupi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tupi.EctoEnums
  alias Tupi.Accounts.Applicant

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    field :name, :string
    field :level, EctoEnums.TypesEnum, default: 2
    field :status, EctoEnums.StatusEnum, default: 1

    field :reset_password_token, :string
    field :reset_token_sent_at, :utc_datetime

    has_one :applicant, Applicant, on_delete: :delete_all

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name])
    |> downcase_email
    |> validate_required([:email, :password])
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/\A[^@\s]+@[^@\s]+\z/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> genput_password_hash
  end

  defp genput_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(pass))
      _ ->
        changeset
    end
  end

  defp downcase_email(changeset) do
    update_change(changeset, :email, &String.downcase/1)
  end

  def admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :status])
    |> downcase_email
    |> validate_required([:email])
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/\A[^@\s]+@[^@\s]+\z/)
    |> unique_constraint(:email)
  end

  def password_token_changeset(user, attrs) do
    user
    |> cast(attrs, [:reset_password_token, :reset_token_sent_at])
    #|> validate_required([:reset_password_token, :reset_token_sent_at])
  end

  def update_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> genput_password_hash
  end
end
