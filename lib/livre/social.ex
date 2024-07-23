defmodule Livre.Social do
  use Livre.Repo.Query, schemas: [Livre.Repo.User]
  import Ecto.Query

  @doc """
  Search for people on Livre.

  You can improve the result by using the following options:
   - ignore: list of user ids you don't want to return
   - nb_max_hits: change the max number of results (default 10)

  Usage:

  	iex> user = insert!(:user)
  	...> assert [user] = Social.global_search(user.name)
  	...> assert [] = Social.global_search(user.name, ignore: [user.id])
  """
  def global_search(query, opts \\ []) do
    query = "%#{query}%"
    nb_max_hits = Keyword.get(opts, :nb_max_hits, 10)
    ignore_ids = Keyword.get(opts, :ignore, [])

    User.from()
    |> where([u], ilike(u.name, ^query))
    |> where([u], field(u, :id) not in ^ignore_ids)
    |> limit(^nb_max_hits)
    |> Repo.all()
  end
end
