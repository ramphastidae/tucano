defmodule Tupi.Mediator do
  import Ecto.Query, warn: false
  alias Tupi.Repo

  alias Tupi.Ads
  alias Tupi.Tenders
  alias Tupi.Accounts.Applicant
  alias Tupi.Tenders.Timetable
  alias Tupi.Tenders.Setting
  alias Tupi.Tenders.Subject

  def allocate_applicants(tenant) do
    query = from(p in Tupi.Tenders.Application, update: [set: [stage: 1]])
    initial_stage =
      Ecto.Multi.new()
      |> Ecto.Multi.update_all(:update_all, query, [], prefix: Triplex.to_prefix(tenant))
      |> Repo.transaction()

    applicants =
      with {:ok, _any} <- initial_stage do
        Applicant.with_applications_order()
        |> order_by(desc: :score)
        |> Repo.all(prefix: Triplex.to_prefix(tenant))
      end

    if Tenders.min_openings(tenant) < Enum.count(applicants) do
      {:error, :cannot_allocate}
    else
      filter_empty_applications(applicants)
      |> allocate_multi(tenant)
    end
  end

  defp filter_empty_applications(applicants) do
    Enum.filter(applicants, fn x -> x.applications != [] end)
  end

  defp allocate_multi(applicants, tenant) do
    Memento.Table.create!(Ads.Subject)
    create_map_openings_allocated(tenant)
    conflicts_map = create_conflicts_struct(tenant)

    # TODO: Should be a transaction
    Enum.each(applicants, fn x -> single_allocate(x, conflicts_map, tenant) end)

    Memento.Table.delete!(Ads.Subject)
  end

  defp create_conflicts_struct(tenant) do
    l_subjects = Tenders.list_subjects(tenant)
    unless Enum.empty?(l_subjects) do
      l_subjects
      |> Enum.map(fn sub ->
        %{sub.code => conflicts_struct(sub, tenant)}
      end)
      |> Enum.reduce(fn x, acc -> Map.merge(x, acc) end)
    end
  end

  defp conflicts_struct(subject, tenant) do
    timetables = 
      Timetable
      |> preload([i], [:subject])
      |> Repo.all(prefix: Triplex.to_prefix(tenant))
    Enum.map(subject.timetables, fn x ->
      time_incompatibility(x, timetables)
    end)
    |> List.flatten
    |> Kernel.++(Enum.map(subject.conflicts, fn x -> x.subject_code end))
    |> Enum.uniq
    |> Enum.reject(&is_nil/1)
  end

  defp time_incompatibility(timetable, timetables) do
    #TODO: Running around midnight can cause problems
    Enum.map(timetables, fn x ->
      dt = DateTime.utc_now |> DateTime.to_date
      {:ok, xb} = NaiveDateTime.new(dt, x.begin)
      {:ok, xe} = NaiveDateTime.new(dt, x.end)
      {:ok, tb} = NaiveDateTime.new(dt, timetable.begin)
      {:ok, te} = NaiveDateTime.new(dt, timetable.end)
      interval_x = Timex.Interval.new(from: xb, until: xe)
      interval_t = Timex.Interval.new(from: tb, until: te)
      if x.weekday == timetable.weekday 
        && Timex.Interval.overlaps?(interval_x, interval_t) do
        x.subject.code
      end
    end)
  end

  defp create_map_openings_allocated(tenant) do
    Tenders.list_subjects(tenant)
    |> Enum.map(fn %Subject{id: id, openings: openings} ->
      Memento.transaction! fn ->
        Memento.Query.write(%Ads.Subject{id: Ads.key_by_tenant(id, tenant), 
          openings: openings, occupied: 0})
      end
    end)
  end

  defp create_map_settings_allocated(tenant) do
    Tenders.list_settings(tenant)
    |> Enum.map(fn %Setting{allocations: allocations, type_key: type_key} ->
      Memento.transaction! fn ->
        Memento.Query.write(
          %Ads.Setting{type_key: Ads.key_by_tenant(type_key, tenant), 
          allocations: allocations, occupied: 0})
      end
    end)
  end

  # true if conflicts exist, else false
  defp check_conflicts?(list1, list2) do
    MapSet.intersection(Enum.into(list1, MapSet.new), Enum.into(list2, MapSet.new)) 
    |> Enum.empty?
    |> Kernel.not
  end

  defp single_allocate(applicant, conflicts_map, tenant) do
    Memento.Table.create!(Ads.Setting)
    Memento.Table.create!(Ads.Code)
    create_map_settings_allocated(tenant)

    Enum.each(applicant.applications, fn x ->
      subject = Tenders.get_subject_preload_allocate!(x.subject_id, tenant)
      # Openings [x]
      # Conflicts [x]
      # Timetables overlapping [x]
      # setting.allocations [x]
      # applicant settings [x]

      m_subject = Ads.get_subject!(subject.id, tenant)
      m_setting = Ads.get_setting!(subject.setting.type_key, tenant)

      l_conflicts = Map.get(conflicts_map, subject.code)
      l_code_applicant = Ads.list_code_str()

      a_setting = Tenders.get_applicant_setting_key!(applicant.id, subject.setting.type_key, tenant)

      if m_subject.openings > m_subject.occupied &&
        m_setting.allocations > m_setting.occupied &&
        a_setting.allocations > m_setting.occupied &&
        !check_conflicts?(l_conflicts, l_code_applicant) do
        
        Tenders.update_application(x, %{stage: 2}, tenant)
        Ads.update_subject(Map.put(m_subject, :occupied, m_subject.occupied + 1))
        Ads.update_setting(Map.put(m_setting, :occupied, m_setting.occupied + 1))
        Ads.create_code(%Ads.Code{code: subject.code})
      end
    end)
    Memento.Table.delete!(Ads.Code)
    Memento.Table.delete!(Ads.Setting)
  end
end
