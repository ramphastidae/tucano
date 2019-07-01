defmodule Tupi.Tenders do
  @moduledoc """
  The Tenders context.
  """

  import Ecto.Query, warn: false
  alias Tupi.Repo

  alias Tupi.Accounts
  alias Tupi.Accounts.User
  alias Tupi.Accounts.Applicant
  alias Tupi.Tenders.Contest
  alias Tupi.Tenders.Setting
  alias Tupi.Tenders.Conflict
  alias Tupi.Tenders.Application
  alias Tupi.Tenders.Subject
  alias Tupi.Tenders.Incoherence

  def get_contest_header(conn) do
    conn
    |> Plug.Conn.get_req_header("tenant")
    |> List.first()
  end

  def list_contests do
    Repo.all(Contest)
  end

  def list_contests_manager(%User{} = manager) do
    Repo.all(
      from c in Contest,
        where: c.manager_id == ^manager.id
    )
  end

  def list_contests_applicant(%User{} = applicant_user) do
    Enum.flat_map(
      Triplex.all(),
      fn name ->
        contest = get_contest_slug!(String.split(name, "_") |> List.last())

        if applicant_in_contest?(applicant_user, contest) do
          [contest]
        else
          []
        end
      end
    )
  end

  def applicant_in_contest?(user, contest) do
    !is_nil(Accounts.get_applicant_user(user.id, contest.slug))
  end

  def get_contest!(id), do: Repo.get!(Contest, id)

  def get_contest_slug!(slug) do
    Repo.get_by!(Contest, slug: slug)
  end

  def create_contest(attrs \\ %{}) do
    # TODO: Needs transaction
    slug = Slugger.slugify_downcase(attrs["name"])

    with {:ok, _} <- contest_aux(slug) do
      unless is_nil(Map.get(attrs, "settings")) do
        Enum.each(
          Map.get(attrs, "settings"),
          fn setting -> create_setting(setting, slug) end
        )
      end

      %Contest{}
      |> Contest.changeset(Map.put(attrs, "slug", slug))
      |> Repo.insert()
    end
  end

  defp contest_aux(tenant) do
    if Triplex.exists?(tenant) do
      {:error, :bad_request}
    else
      Triplex.create(tenant)
    end
  end

  def update_contest(%Contest{} = contest, attrs) do
    contest
    |> Contest.update_changeset(attrs)
    |> Repo.update()
  end

  def update_contest_helper(%Contest{} = contest, attrs) do
    contest
    |> Contest.changeset(attrs)
    |> Repo.update()
  end

  def delete_contest(%Contest{} = contest) do
    case Triplex.drop(contest.slug) do
      {:ok, _slug} ->
        Repo.delete(contest)
      {:error, _reason} -> {:error, :bad_request}
    end
  end

  def change_contest(%Contest{} = contest) do
    Contest.changeset(contest, %{})
  end

  def list_incoherences(tenant) do
    Incoherence
    |> preload([:applicant])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  def list_applicant_incoherences(id, tenant) do
    Incoherence
    |> where([i], i.applicant_id == ^id)
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  def get_applicant_incoherence!(applicant_id, id, tenant) do
    Incoherence
    |> where([i], i.applicant_id == ^applicant_id)
    |> where([i], i.id == ^id)
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  def get_incoherence!(id, tenant) do
    Repo.get!(Incoherence, id, prefix: Triplex.to_prefix(tenant))
  end

  def create_incoherence(attrs \\ %{}, tenant) do
    %Incoherence{}
    |> Incoherence.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  def update_incoherence(%Incoherence{} = incoherence, attrs, tenant) do
    incoherence
    |> Incoherence.update_changeset(attrs)
    |> Repo.update(prefix: Triplex.to_prefix(tenant))
  end

  def delete_incoherence(%Incoherence{} = incoherence, tenant) do
    Repo.delete(incoherence, prefix: Triplex.to_prefix(tenant))
  end

  def change_incoherence(%Incoherence{} = incoherence) do
    Incoherence.changeset(incoherence, %{})
  end

  def list_subjects(tenant) do
    # Repo.all(Subject, prefix: Triplex.to_prefix(tenant))

    Subject
    # |> join(:left, [subject], timetables in assoc(subject, :timetables))
    # |> join(:left, [subject], setting in assoc(subject, :setting))
    |> preload([:timetables, :setting, :conflicts])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  def list_subjects(tenant, filter) do
    Subject
    |> preload([:timetables, :setting, :conflicts])
    |> where([s], like(s.name, ^"%#{filter[:name]}%"))
    |> where([s], like(s.code, ^"%#{filter[:code]}%"))
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  def get_subject!(id, tenant) do
    Repo.get!(Subject, id, prefix: Triplex.to_prefix(tenant))
  end

  def get_subject_preload!(id, tenant) do
    Repo.get!(Subject, id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:timetables, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:setting, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:conflicts, prefix: Triplex.to_prefix(tenant))
  end

  def create_subject(attrs \\ %{}, tenant) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  def update_subject(%Subject{} = subject, attrs, tenant) do
    subject
    |> Subject.update_changeset(attrs)
    |> Repo.update(prefix: Triplex.to_prefix(tenant))
  end

  def delete_subject(%Subject{} = subject, tenant) do
    Repo.delete(subject, prefix: Triplex.to_prefix(tenant))
  end

  def change_subject(%Subject{} = subject) do
    Subject.changeset(subject, %{})
  end

  def list_applicant_applications(id, tenant) do
    Application
    |> where([i], i.applicant_id == ^id)
    |> order_by([i], i.preference)
    |> preload([i], [:subject])
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
  end

  def create_application(attrs \\ %{}, tenant) do
    %Application{}
    |> Application.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  def update_application(%Application{} = application, attrs, tenant) do
    application
    |> Application.update_changeset(attrs)
    |> Repo.update(prefix: Triplex.to_prefix(tenant))
  end

  def list_conflicts do
    Repo.all(Conflict)
  end

  def get_conflict!(id), do: Repo.get!(Conflict, id)

  def create_conflict(attrs \\ %{}) do
    %Conflict{}
    |> Conflict.changeset(attrs)
    |> Repo.insert()
  end

  def update_conflict(%Conflict{} = conflict, attrs) do
    conflict
    |> Conflict.changeset(attrs)
    |> Repo.update()
  end

  def delete_conflict(%Conflict{} = conflict) do
    Repo.delete(conflict)
  end

  def change_conflict(%Conflict{} = conflict) do
    Conflict.changeset(conflict, %{})
  end

  def list_settings(tenant) do
    Repo.all(Setting, prefix: Triplex.to_prefix(tenant))
  end

  def get_setting!(id), do: Repo.get!(Setting, id)

  def get_setting_key!(type_key, tenant) do
    Repo.get_by!(Setting, [type_key: type_key], prefix: Triplex.to_prefix(tenant))
  end

  def create_setting(attrs \\ %{}, tenant) do
    %Setting{}
    |> Setting.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  def delete_setting(%Setting{} = setting) do
    Repo.delete(setting)
  end

  def change_setting(%Setting{} = setting) do
    Setting.changeset(setting, %{})
  end

  alias Tupi.Tenders.Timetable

  def list_timetables do
    Repo.all(Timetable)
  end

  def get_timetable!(id), do: Repo.get!(Timetable, id)

  def create_timetable(attrs \\ %{}) do
    %Timetable{}
    |> Timetable.changeset(attrs)
    |> Repo.insert()
  end

  def update_timetable(%Timetable{} = timetable, attrs) do
    timetable
    |> Timetable.changeset(attrs)
    |> Repo.update()
  end

  def delete_timetable(%Timetable{} = timetable) do
    Repo.delete(timetable)
  end

  def change_timetable(%Timetable{} = timetable) do
    Timetable.changeset(timetable, %{})
  end

  def get_subject_preload_allocate!(id, tenant) do
    # from s in Subject, preload: [:timetables, :setting, :conflicts]
    Repo.get!(Subject, id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:timetables, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:setting, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:conflicts, prefix: Triplex.to_prefix(tenant))

    # |> Repo.preload(:applicants, prefix: Triplex.to_prefix(tenant))
  end

  def total_openings(tenant) do
    subjects = list_subjects(tenant)
    unless Enum.empty?(subjects) do
      subjects
      |> Enum.map(fn sub -> %{sub.setting.type_key => sub.openings} end)
      |> Enum.reduce(fn x, acc -> Map.merge(x, acc, fn _k, v1, v2 -> v1 + v2 end) end)
    end
  end

  def min_openings(tenant) do
    openings_map = total_openings(tenant)
    if openings_map do
      Enum.map(openings_map |> Map.keys, fn s ->
        div(Map.get(openings_map, s), get_setting_key!(s, tenant) |> Map.get(:allocations))
      end)
      |> Enum.min()
    else
      0
    end
  end

  def subjects_allocated(id, tenant) do
    Application
    |> where(subject_id: ^id)
    |> where(stage: 2)
    |> Repo.aggregate(:count, :id, prefix: Triplex.to_prefix(tenant))
  end

  def list_results(tenant) do
    query = 
      from s in Subject, 
      inner_join: application in Application, 
      on: application.subject_id == s.id,
      where: application.stage == 2,
      inner_join: applicant in Applicant,
      on: applicant.id == application.applicant_id,
      preload: [applicants: applicant],
      preload: [:setting]

    Repo.all(query, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload([applicants: [:user]], prefix: "public")
  end

  def get_applicant_results(id, tenant) do
    query = 
      from a in Applicant, 
      inner_join: application in Application, 
      on: application.applicant_id == a.id,
      where: application.stage == 2,
      inner_join: subject in Subject,
      on: application.subject_id == subject.id,
      preload: [subjects: subject]

    res = 
      Repo.get(query, id, prefix: Triplex.to_prefix(tenant))
      |> Repo.preload(:user, prefix: "public")

    if is_nil(res) do
      {:error, :not_found}
      #Accounts.get_applicant_preload!(id, tenant)
    else
      {:ok, res}
    end
  end

  def get_applicant_results!(id, tenant) do
    case get_applicant_results(id, tenant) do
      {:error, _nf} -> {:error, :not_found}
      {:ok, res} -> res 
    end
  end

  def list_applicant_results(id, tenant) do
    case get_applicant_results(id, tenant) do
      {:error, _nf} -> {:error, :not_found}
      {:ok, res} -> 
        res.subjects
        |> Repo.preload(:setting, prefix: Triplex.to_prefix(tenant))
    end
  end

  def list_unplaced(tenant) do
    n_allocates = 
      list_settings(tenant)
      |> Enum.reduce(0, fn x, acc -> x.allocations + acc end)

    Applicant
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Enum.map(fn x ->
      case get_applicant_results(x.id, tenant) do
        {:ok, res} ->
          if Enum.count(res.subjects) < n_allocates do
            res
          end
        {:error, _nf} -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  def list_unmediated(tenant) do
    Applicant.with_subjects
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:user, prefix: "public")
    |> Enum.map(fn x -> 
      if Enum.empty?(x.subjects) do
        x
      end 
    end)
    |> Enum.reject(&is_nil/1)
  end
end
