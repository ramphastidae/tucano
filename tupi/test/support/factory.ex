defmodule Tupi.Factory do
  use ExMachina.Ecto, repo: Tupi.Repo
  use Tupi.UserStrategy
  use Tupi.UserFactory
  use Tupi.ManagerFactory
  use Tupi.AdminFactory
  use Tupi.ApplicantFactory
  use Tupi.ApplicantStrategy
  use Tupi.ContestFactory
  use Tupi.SettingFactory
  use Tupi.SettingStrategy
  use Tupi.TimetableFactory
  use Tupi.SubjectFactory
  use Tupi.SubjectStrategy
  use Tupi.ConflictFactory
  use Tupi.IncoherenceFactory
  use Tupi.IncoherenceStrategy
  use Tupi.ApplicationFactory
end
