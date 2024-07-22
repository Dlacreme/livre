defmodule Livre.Query.Helper do
  @moduledoc """
  """
  import Ecto.Query

  @doc """
  Check for a strict equal and fallback on is_nil if required

  Usage:

  iex> user = insert!(:user)
  ...> from(u in User)
  ...> |> Helper.where_eq(:email, user.email)
  ...> |> Livre.Repo.one()
  user

  iex> user = insert!(:user, %{picture_url: nil})
  ...> from(u in User)
  ...> |> Helper.where_eq(:picture_url, nil)
  ...> |> Livre.Repo.one()
  user
  """
  def where_eq(query, key, value) when is_nil(value) do
    where_nil(query, key)
  end

  def where_eq(query, key, value) do
    query
    |> where([u], field(u, ^key) == ^value)
  end

  def where_nil(query, key) do
    query
    |> where([u], is_nil(field(u, ^key)))
  end

  @doc """
  Print an Ecto query into a SQL string and return the query itself

  iex> q = from(u in User)
  ...> Helper.print_sql(q)
  q
  """

  def print_sql(query, opts \\ []) do
    require Logger
    Logger.debug(Ecto.Adapters.SQL.to_sql(:all, Livre.Repo, query), opts)
    query
  end
end
