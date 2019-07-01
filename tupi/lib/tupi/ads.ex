defmodule Tupi.Ads do
  alias Tupi.Ads.Code
  alias Tupi.Ads.Subject
  alias Tupi.Ads.Setting

  def key_by_tenant(key, tenant) do
    "#{key}_#{tenant}"
  end

  def get_subject!(id, tenant) do
    Memento.transaction! fn ->
      Memento.Query.read(Subject, key_by_tenant(id, tenant))
    end
  end

  def update_subject(%Subject{} = subject) do
    Memento.transaction! fn ->
      Memento.Query.write(subject)
    end
  end

  def get_setting!(type_key, tenant) do
    Memento.transaction! fn ->
      Memento.Query.read(Setting, key_by_tenant(type_key, tenant))
    end
  end

  def update_setting(%Setting{} = setting) do
    Memento.transaction! fn ->
      Memento.Query.write(setting)
    end
  end

  def list_code do
    Memento.transaction! fn ->
      Memento.Query.all(Code)
    end
  end

  def list_code_str do
    list_code()
    |> Enum.map(fn x -> x.code end)
  end

  def create_code(%Code{} = code) do
    Memento.transaction! fn ->
      Memento.Query.write(code)
    end
  end
end
