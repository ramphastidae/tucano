defmodule TupiWeb.ApplicantView do
  use TupiWeb, :view
  use JSONAPI.View, type: "applicants"

  def fields do
    [
      :email, 
      :name,
      :group,
      :score,
      :uni_number
    ]
  end

  def name(applicant, _conn) do
    applicant.user.name
  end

  def email(applicant, _conn) do
    applicant.user.email
  end

  def relationships do
    [
      applications: {TupiWeb.ApplicationView, :include},
      subjects: {TupiWeb.SubjectView, :include}
    ]
  end
end
