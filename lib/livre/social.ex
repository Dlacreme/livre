defmodule Livre.Social do
  use Livre.Repo.Query,
    schemas: [Livre.Repo.User, Livre.Repo.Friendship]

  require Ecto.Query

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

  @doc """
  Return all friend for a given user.

  Returns a tuple with the friendship as the first item and the
  friend's user data as second item.

  Usage:

  	iex> user = insert!(:user)
  	...> insert!(:friendship, %{from_id: user.id, status: :approved})
  	...> insert!(:friendship, %{to_id: user.id, status: :approved})
  	...> assert length(Social.get_friends(user.id)) == 2
  """
  def get_friend(user) when is_struct(user, User) do
    get_friends(user.id)
  end

  def get_friends(user_id) when is_binary(user_id) do
    # since we don't know if `user_id` is in the 'from'
    # or 'to' column we query both distinctively and merge
    # the results.
    # Otherwise we would end up with the user_id listed
    # as a friend of themself.
    from_res =
      Friendship.from()
      |> join(:inner, [f], u in User, on: f.from_id == u.id)
      |> get_friend_query(user_id)
      |> Repo.all()

    to_res =
      Friendship.from()
      |> join(:inner, [f], u in User, on: f.from_id == u.id)
      |> get_friend_query(user_id)
      |> Repo.all()

    from_res ++ to_res
  end

  defp get_friend_query(q, user_id) do
    q
    |> where_eq(:status, :approved)
    |> where_eq(:from_id, user_id)
    |> select([f, u], {f, u})
  end

  @doc """
   Return the friendship status between 2 users.
   Status can be
   - :sent (pending)
   - :approved (friend)
   - :none (non-existing, cancelled or refused)

  Usage:

  	iex> user1 = insert!(:user)
  	...> user2 = insert!(:user)
  	...> user3 = insert!(:user)
  	...> insert!(:friendship, %{from_id: user1.id, to_id: user2.id, status: :approved})
  	...> :approved = Social.get_friendship_status(user1.id, user2.id)
  	...> :none = Social.get_friendship_status(user1.id, user3.id)
  """
  def get_friendship_status(user1_id, user2_id)
      when is_binary(user1_id) and is_binary(user2_id) do
    case(get_friendship(user1_id, user2_id)) do
      nil -> :none
      fr when is_struct(fr, Friendship) -> fr.status
    end
  end

  @doc """
   Create a new pending relationship between 2 users

   Usage:

   	iex> user1 = insert!(:user)
    ...> user2 = insert!(:user)
    ...> {:ok, _any} = Social.ask_friend(user1.id, user2.id)
    ...> {:error, :relationship_exists} = Social.ask_friend(user2.id, user1.id)
  """
  def ask_friend(from_id, to_id) do
    %Friendship{}
    |> Friendship.changeset(%{from_id: from_id, to_id: to_id})
    |> Repo.insert()
  rescue
    # we rely on a pure SQL constraints to avoid duplicate
    _any -> {:error, :relationship_exists}
  end

  @doc """
  Update an existing friendship to set its status to `approved`.
  Also edit the `inserted_at` column to use as 'friend since'.

  Usage:

    iex> fr = insert!(:friendship)
    ...> Social.confirm_friendship(fr)
    ...> fr = Livre.Repo.get(Livre.Repo.Friendship, fr.id)
    ...> assert fr.status == :approved
  """
  def confirm_friendship(friendship) when is_struct(friendship, Friendship) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    friendship
    |> Friendship.changeset(%{status: :approved, inserted_at: now})
    |> Repo.update()
  end

  @doc """
  Remove entirely a friendship regardless of the status

  Usage:

    iex> fr = insert!(:friendship)
    ...> Social.cancel_friendship(fr)
    ...> assert nil == Livre.Repo.get(Livre.Repo.Friendship, fr.id)
  """
  def cancel_friendship(friendship) when is_struct(friendship, Friendship) do
    Repo.delete(friendship)
  end

  @doc """
  Return a friendship between 2 users or nil if none exists.

  Usage:

  		iex> user1 = insert!(:user)
  		...> user2 = insert!(:user)
  		...> fr = insert!(:friendship, %{from_id: user1.id, to_id: user2.id})
  		...> Social.get_friendship(user1.id, user2.id)
  		fr
  """
  def get_friendship(user1_id, user2_id) do
    Friendship.from()
    |> where(
      [fr],
      (field(fr, :from_id) == ^user1_id and field(fr, :to_id) == ^user2_id) or
        (field(fr, :from_id) == ^user2_id and field(fr, :to_id) == ^user1_id)
    )
    |> Repo.one()
  end
end
