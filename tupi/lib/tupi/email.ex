defmodule Tupi.Email do
  #use Bamboo.Phoenix, view: Tupi.FeedbackView
  import Bamboo.Email
  import Bamboo.Phoenix

  def send_reset_email(to_email, token) do
    new_email()
    |> to(to_email)
    |> from(System.get_env("FROM_EMAIL"))
    |> subject("Reset Password Instructions")
    |> text_body("Please visit #{System.get_env("FRONTEND_URL")}/password/edit?token=#{token} to reset your password")
  end

  def send_password_email(to_email, token) do
    new_email()
    |> to(to_email)
    |> from(System.get_env("FROM_EMAIL"))
    |> subject("Finish account registration")
    |> text_body("Please visit #{System.get_env("FRONTEND_URL")}/password/edit?token=#{token} to finish your account registration")
  end

  def send_contest_email(to_email, token) do
    new_email()
    |> to(to_email)
    |> from(System.get_env("FROM_EMAIL"))
    |> subject("You have been added to a new Contest")
    |> text_body("Please visit #{System.get_env("FRONTEND_URL")}/user/contests/#{token}")
  end
end
