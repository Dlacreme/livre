defmodule Livre.Feed do
  use Livre.Repo.Query,
    schemas: [Livre.Repo.User, Livre.Repo.Post, Livre.Repo.Comment]

  require Ecto.Query
  alias Livre.Social
  alias Livre.Notification

  @doc """
  Get posts for a given user

  iex> user = insert!(:user)
  ...> {:ok, post} = Feed.create_post(user.id, "this is a post")
  ...> Feed.get_feed(user.id)
  [post]
  """
  def get_feed(user_id) when is_binary(user_id) do
    ids = [user_id | get_related_user_ids(user_id)]

    Post.from()
    |> where([p], field(p, :user_id) in ^ids)
    |> preload(:user)
    |> preload(comments: :user)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc """
  Create a new post

  iex> user = insert!(:user)
  ...> assert {:ok, post} = Feed.create_post(user.id, "this is a post")
  """
  def create_post(user_id, content) when is_binary(user_id) when is_binary(content) do
    with changeset <- Post.changeset(%Post{}, %{user_id: user_id, content: content}),
         {:ok, _post} = res <- Repo.insert(changeset) do
      get_related_user_ids(user_id)
      |> Enum.each(&Notification.push(&1, "new post on your feed", "/"))

      res
    end
  end

  @doc """
  Comment on an existing post

  iex> user = insert!(:user)
  ...> {:ok, post} = Feed.create_post(user.id, "this is a post")
  ...> assert {:ok, com} = Feed.comment_post(user.id, post.id, user.id, "this is a comment")
  """
  def comment_post(user_id, post_id, post_owner_id, content)
      when is_binary(user_id) and is_binary(post_id)
      when is_binary(content) do
    with changeset <-
           Comment.changeset(%Comment{}, %{user_id: user_id, content: content, post_id: post_id}),
         {:ok, _com} = res <- Repo.insert(changeset) do
      [post_owner_id | get_related_user_ids(post_owner_id)]
      |> Enum.each(&Notification.push(&1, "new comment on your feed", "/"))

      res
    end
  end

  defp get_related_user_ids(user_id) do
    Social.get_friends(user_id)
    |> Enum.map(& &1.id)
  end
end
