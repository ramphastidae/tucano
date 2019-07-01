defmodule Tupi.Auth do
  import Ecto.Query, warn: false
  use Timex
  alias Tupi.Repo
  
  alias Tupi.Accounts.User
  alias Tupi.Guardian

  def current_user(conn) do
    with  %User{} = user <- Guardian.Plug.current_resource(conn) do
      user
    end
  end

  def random_string(len) do
    :crypto.strong_rand_bytes(len)
    |> Base.url_encode64
    |> binary_part(0, len)
  end

  ## Lib PasswordReset

  # checks if now is later than 1 day from the reset_token_sent_at
  def expired?(datetime) do
    Timex.after?(Timex.now, Timex.shift(datetime, days: 1))
  end

  # sets the token & sent at in the database for the user
  def reset_password_token(user) do
    token = random_string(48)
    sent_at = DateTime.utc_now

    user
    |> User.password_token_changeset(
      %{reset_password_token: token, reset_token_sent_at: sent_at})
    |> Repo.update!
  end

  ## Lib Auth

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)
      _ ->
        {:error, :unauthorized}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email),
    do: verify_password(password, user)
  end

  defp get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        Bcrypt.no_user_verify()
        {:error, "Login error."}
      %User{status: :inactive} ->
        Bcrypt.no_user_verify()
        {:error, "Login error."}
      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end
end
