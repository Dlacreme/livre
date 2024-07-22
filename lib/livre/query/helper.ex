defmodule Livre.Query.Helper do
  @moduledoc """
  """
  import Ecto.Query

  @doc """
  Check for a strict equal and fallback on is_nil if required

  Usage:

  iex> channel = insert!(:channel)
  ...> from(c in Channel)
  ...> |> Helper.where_eq(:slug, channel.slug)
  ...> |> Livre.Repo.one()
  channel

  iex> channel = insert!(:channel, %{picture_url: nil})
  ...> from(c in Channel)
  ...> |> Helper.where_eq(:picture_url, nil)
  ...> |> Livre.Repo.one()
  channel
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

  iex> q = from(c in Channel)
  ...> Helper.print_sql(q)
  q
  """

  def print_sql(query, opts \\ []) do
    require Logger
    Logger.debug(Ecto.Adapters.SQL.to_sql(:all, Livre.Repo, query), opts)
    query
  end
end
