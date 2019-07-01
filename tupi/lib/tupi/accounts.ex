defmodule Tupi.Accounts do

  import Ecto.Query, warn: false
  alias Tupi.Repo
  alias Ecto.Multi

  alias Tupi.Accounts.User
  alias Tupi.Accounts.Applicant
  alias Tupi.EctoEnums.TypesEnum
  alias Tupi.Auth

  defdelegate authorize(action, user, params), to: Tupi.Accounts.Policy

  def promote_user(user, level) when is_atom(level) do
    User
    |> where([u], u.id == ^user.id)
    |> update([set: [level: ^level, updated_at: ^NaiveDateTime.utc_now()]])
    |> Repo.update_all([])
  end

  def create_admin(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.put_change(:level, :admin)
    |> Repo.insert()
  end

  def list_managers do
    Repo.all from m in User,
    where: m.level == ^:manager
  end

  def get_manager!(id) do 
    Repo.all(from m in User,
    where: m.level == ^:manager,
    where: m.id == ^id)
    |> List.first
  end

  def create_manager(attrs \\ %{}) do
    attrs = Map.put(attrs, "password", Auth.random_string(8))
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.put_change(:level, :manager)
    |> Repo.insert()
  end

  def update_manager(%User{} = user, attrs) do
    user
    |> User.admin_changeset(attrs)
    |> Repo.update()
  end

  def is_manager(%User{} = user) do
    user
    |> Map.get(:level)
    |> Kernel.==(:manager)
  end
  def is_manager(manager_id) do
    get_user!(manager_id)
    |> is_manager
  end

  def is_normal(%User{} = user) do
    user
    |> Map.get(:level)
    |> Kernel.==(:normal)
  end
  def is_normal(user_id) do
    get_user!(user_id)
    |> is_normal
  end

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_preload!(id, tenant) do
    Repo.get!(User, id)
    |> Repo.preload(:applicant, prefix: Triplex.to_prefix(tenant))
  end

  def get_user_token(token) do
    Repo.get_by(User, reset_password_token: token)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def list_applicants(tenant) do
    Applicant.with_applications
    |> Repo.all(prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:user, prefix: "public")
  end

  def get_applicant!(id, tenant) do 
    Repo.get!(Applicant, id, prefix: Triplex.to_prefix(tenant))
  end

  def get_applicant_preload!(id, tenant) do
    Applicant.with_applications
    |> Repo.get!(id, prefix: Triplex.to_prefix(tenant))
    |> Repo.preload(:user, prefix: "public")
  end

  def get_applicant_user(id, tenant) do 
    Repo.get_by(Applicant, [user_id: id], prefix: Triplex.to_prefix(tenant))
  end

  def create_applicant(attrs \\ %{}, tenant) do
    if !is_nil(attrs["user"]["email"]) do
      case get_user_email(attrs["user"]["email"]) do
        nil -> create_applicant_user(attrs, tenant)
        %User{} = user -> create_applicant_user(user, attrs, tenant)
      end
    end
  end

  defp create_applicant_user(%User{} = user, attrs, tenant) do
    attrs = 
      attrs
      |> Map.put("user_id", user.id)
    case create_applicant_user_aux(attrs, tenant) do
      {:ok, applicant} ->
        applicant =
          Map.get(applicant, :id)
          |> get_applicant_preload!(tenant)

        Tupi.Email.send_contest_email(user.email, tenant)
        |> Tupi.Mailer.deliver_now()

        {:ok, applicant}
      {:error, _error} -> {:error, :bad_request}
    end
  end
  
  defp create_applicant_user(attrs, tenant) do
    attrs =
      attrs
      |> Map.put("user", Map.put(attrs["user"], "password", Auth.random_string(8)))
    
    {:ok, map} =
      Multi.new
      |> Multi.insert(:user, User.changeset(%User{}, Map.get(attrs, "user")))
      |> Multi.insert(:applicant, fn %{user: user} ->
          Ecto.build_assoc(user, :applicant, 
            Map.delete(attrs, "user") |> map_to_keywordlist())
        end, prefix: Triplex.to_prefix(tenant))
      |> Repo.transaction()
    applicant = 
      Map.get(map, :applicant)
      |> Map.get(:id)
      |> get_applicant_preload!(tenant)

    user = Auth.reset_password_token(applicant.user)
    Tupi.Email.send_password_email(user.email, user.reset_password_token)
    |> Tupi.Mailer.deliver_now()

    {:ok, applicant}
  end

  defp create_applicant_user_aux(attrs, tenant) do
    %Applicant{}
    |> Applicant.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(tenant))
  end

  def create_applicant_multi(attrs_list, tenant) do
    list = Enum.map(attrs_list, fn %{"attributes" => attr} -> 
      create_applicant_multi_aux(attr) 
    end)

    len = length list

     result = 
      list
      |> Enum.with_index()
      |> Enum.reduce(Multi.new(), fn ({attrs, index}, multi) ->
          Multi.insert(multi, String.to_atom("user#{Integer.to_string(index)}"), 
                       User.changeset(%User{}, Map.get(attrs, "user")))
          |> Multi.insert(String.to_atom("applicant#{Integer.to_string(index)}"), 
                       fn map -> Ecto.build_assoc(
                        Map.get(map, 
                          String.to_atom("user#{Integer.to_string(index)}")), 
                          :applicant, 
                       Map.delete(attrs, "user") |> map_to_keywordlist())
          end, prefix: Triplex.to_prefix(tenant))
         end)
      |> Repo.transaction

    case result do
      {:ok, map} ->
        if map != %{} do
          list_applicants = Enum.map(1..len, fn x -> Map.get(map, 
            String.to_atom("applicant#{x-1}")) end)
          list_applicants = Enum.map(list_applicants, 
            fn st -> get_applicant_preload!(st.id, tenant) end)
          create_applicant_multi_mail(list_applicants)
          {:ok, list_applicants}
        else
          {:error, :bad_request}
        end
      _ ->
        {:error, :bad_request}
    end
  end

  defp create_applicant_multi_aux(attrs) do
    #attrs =
      attrs
      |> Map.put("user", Map.put(attrs["user"], "password", Auth.random_string(8)))
    #%Applicant{}
    #|> Applicant.changeset(attrs)
  end

  defp create_applicant_multi_mail(applicants) do
    Enum.map applicants, fn applicant ->
      user = Auth.reset_password_token(applicant.user)
      Tupi.Email.send_password_email(user.email, user.reset_password_token)
      |> Tupi.Mailer.deliver_now()
    end
  end

  def manager_update_applicant(%Applicant{} = applicant, attrs, tenant) do
    applicant
    |> Applicant.manager_update_changeset(attrs)
    |> Repo.update(prefix: Triplex.to_prefix(tenant))
  end

  def update_applicant(%Applicant{} = applicant, attrs, tenant) do
    applicant
    |> Applicant.update_changeset(attrs)
    |> Repo.update(prefix: Triplex.to_prefix(tenant))
  end

  def delete_applicant(%Applicant{} = applicant, tenant) do
    Repo.delete(applicant, prefix: Triplex.to_prefix(tenant))
  end

  def delete_applicant_multi(tenant) do
    query = from(a in Applicant)
    Multi.new()
    |> Multi.delete_all(:delete_all, query, prefix: Triplex.to_prefix(tenant))
    |> Repo.transaction()
  end

  def change_applicant(%Applicant{} = applicant) do
    Applicant.changeset(applicant, %{})
  end

  def map_to_keywordlist(map) do
    #does not do nested
    Enum.map(map, fn {key, value} -> {String.to_atom(key), value} end)
  end

  ## Seeds

  def create_manager_seed(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.put_change(:level, :manager)
    |> Repo.insert()
  end

  def create_user_applicant_seed(attrs \\ %{}, tenant) do
    Multi.new
    |> Multi.insert(:user, User.changeset(%User{}, Map.get(attrs, "user")))
    |> Multi.insert(:applicant, fn %{user: user} ->
        Ecto.build_assoc(user, :applicant, 
          Map.delete(attrs, "user") |> map_to_keywordlist())
      end, prefix: Triplex.to_prefix(tenant))
    |> Repo.transaction()
  end
end
