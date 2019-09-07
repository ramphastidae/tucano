defmodule Tupi.Accounts.Policy do
  alias Tupi.Accounts
  alias Tupi.Tenders

  @behaviour Bodyguard.Policy

  def authorize(_, %Accounts.User{level: :admin}, _) do
    true
  end

  def authorize(action, %Accounts.User{id: m1, level: :manager}, 
                %Accounts.User{id: m2, level: :manager})
    when action in [:get_user!, :update_user] do
    if m1 == m2 do
      true
    else
      false
    end 
  end

  def authorize(action, %Accounts.User{level: :manager}, %Accounts.User{level: :normal})
    when action in [:get_user!, :manager_update_applicant] do
      true
  end

  def authorize(action, %Accounts.User{level: :manager}, _)
    when action in [
      :list_applicants, 
      :create_applicant, 
      :create_applicant_multi,
      :list_contests_manager,
      :create_contest,
      :list_settings,
      :get_contest_slug!,
      :get_applicant_preload!,
      :delete_applicant,
      :delete_applicant_multi,
      :list_subjects,
      :create_subject,
      :get_subject_preload!,
      :update_subject,
      :list_incoherences,
      :update_incoherence,
      :update_contest,
      :list_applicant_incoherences,
      :list_applicant_applications,
      :allocate_applicants,
      :list_results,
      :list_unplaced,
      :list_unmediated,
      :delete_contest
    ] do
    true
  end

  def authorize(action, %Accounts.User{id: u1, level: :normal}, 
                %Accounts.User{id: u2, level: :normal})
    when action in [
      :get_user!,
      :get_user_preload!,
      :list_applicant_incoherences,
      :create_incoherence,
      :delete_incoherence,
      :get_applicant_incoherence!,
      :update_applicant,
      :list_applicant_applications,
      :get_applicant_results!,
      :list_applicant_results,
      :list_applicant_settings,
      :update_applicant_setting
    ] do
    if u1 == u2 do
      true
    else
      false
    end 
  end

  def authorize(action, %Accounts.User{level: :normal} = user, slug)
    when action in [:get_contest_slug!] do
    Tenders.applicant_in_contest?(user, Tenders.get_contest_slug!(slug))
  end

  def authorize(action, %Accounts.User{level: :normal}, _)
    when action in [
      :list_contests_applicant,
      :get_user_preload!,
      :get_contest_slug!,
      :list_subjects
    ] do
    true
  end

  def authorize(action, %Tenders.Contest{} = contest, :period)
    when action in [
      :update_applicant,
      :list_applicant_applications,
      :update_applicant_setting
    ] do
    interval = Timex.Interval.new(from: contest.begin, until: contest.end)
    DateTime.utc_now in interval
  end

  def authorize(action, %Tenders.Contest{} = contest, :period_after_end)
    when action in [
      :update_applicant,
      :list_applicant_applications
    ] do
    interval = Timex.Interval.new(from: contest.begin, until: contest.end)
    DateTime.utc_now in interval || DateTime.compare(DateTime.utc_now, contest.end) == :gt
  end

  def authorize(action, %Tenders.Contest{} = contest, :before_begin)
    when action in [
      :create_subject
    ] do
    case DateTime.compare(DateTime.utc_now, contest.begin) do
      :lt -> true
      _   -> false
    end
  end

  def authorize(action, %Tenders.Contest{} = contest, :after_end)
    when action in [
      :allocate_applicants
    ] do
    case DateTime.compare(DateTime.utc_now, contest.end) do
      :gt -> true
      _   -> false
    end
  end

  def authorize(action, %Tenders.Contest{} = contest, :published)
    when action in [
      :list_applicant_results
    ] do
    if contest.status == :published do
      true
    else
      false
    end
  end

  # Admin users can do anything
  # def authorize(_, %Blog.User{role: :admin}, _), do: true

  # Regular users can create posts
  #def authorize(:create_post, _, _), do: true

  # Regular users can modify their own posts
  # def authorize(action, %Blog.User{id: user_id}, %Blog.Post{user_id: user_id})
  #  when action in [:update_post, :delete_post], do: true

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
