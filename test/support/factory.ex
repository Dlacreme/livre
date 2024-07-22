defmodule LivreTest.Factory do
  @moduledoc """
  Factory for tests

  Usage:

  insert!(:user, %{name: "hello"})
  """
  alias Livre.Repo
  alias Livre.Accounts.{Session, User}

  def build(:user) do
    uniq_int = System.unique_integer()

    valid_attrs = %{
      email: "user#{uniq_int}@example.com",
      provider: "provider_test",
      provider_id: "test_#{uniq_int}",
      name: "name#{uniq_int}"
    }

    %User{}
    |> User.changeset(valid_attrs)
    |> Ecto.Changeset.apply_action!(:update)
  end

  def build(:session) do
    expiration_date =
      DateTime.utc_now()
      |> DateTime.add(1, :day)
      |> DateTime.truncate(:second)

    user = insert!(:user)

    %Session{
      user_id: user.id,
      initiated_by_ip: "127.0.0.1",
      user_agent: "local-test",
      expired_at: expiration_date,
      token: :crypto.strong_rand_bytes(8)
    }
  end

  # API

  def build(factory_name, attributes) do
    factory_name
    |> build()
    |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    build(factory_name, attributes)
    |> Repo.insert!()
  end
end
