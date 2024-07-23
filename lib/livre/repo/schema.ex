defmodule Livre.Repo.Schema do
  @moduledoc """
  All schemas defined in Livre.Repo should
  implement this behaviour to force query
  composition
  """

  @doc """
  Return a `from` ecto query. See the schema
  definition & implementation for more details.
  """
  @callback from(opts :: keyword()) :: Ecto.Query.t()
end
