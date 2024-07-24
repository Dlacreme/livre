defmodule Livre.Feed do
  use Livre.Repo.Query,
    schemas: [Livre.Repo.User, Livre.Repo.Post, Livre.Repo.Comment]

  @doc """
  Get posts for a given user

  iex> user = insert!(:user)
  ...> {:ok, post} = Feed.create_post(user.id, "this is a post")
  ...> Feed.get_feed(user.id)
  [post]
  """
  def get_feed(user_id) when is_binary(user_id) do
    Post.from()
    |> where_eq(:user_id, user_id)
    |> preload(:user)
    |> preload(comments: :user)
    |> Repo.all()
  end

  def create_post(user_id, content) when is_binary(user_id) when is_binary(content) do
    Post.changeset(%Post{}, %{user_id: user_id, content: content})
    |> Repo.insert()
  end

  def comment_post(user_id, post_id, content)
      when is_binary(user_id) and is_binary(post_id)
      when is_binary(content) do
    Comment.changeset(%Comment{}, %{user_id: user_id, content: content, post_id: post_id})
    |> Repo.insert()
  end
end
