defmodule Livre.Query.Schema do
  @moduledoc """
  We use Query Composition to avoid duplicating code
  """
  @callback from(opts :: keyword()) :: Ecto.Query.t()
end
