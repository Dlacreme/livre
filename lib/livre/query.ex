defmodule Livre.Query do
  @moduledoc """
  This module import the common modules used to query our Database & models
  """
  defmacro __using__(opts \\ [schemas: []]) do
    quote do
      import Ecto.Query
      import Livre.Query.Helper
			alias Livre.Repo
      unquote(maybe_include_schemas(opts[:schemas]))
    end
  end


  defp maybe_include_schemas(schemas) when is_list(schemas) do
    for s <- schemas do
      quote do
        alias unquote(s)
      end
    end
  end

  defp maybe_include_schemas(_) do
    # nothing
  end
end
