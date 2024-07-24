defmodule Livre.Notification do
  @moduledoc """
  Create and send notifications
  """
  require Logger

  use Livre.Repo.Query,
    schemas: [Livre.Repo.Notification, Livre.Repo.User]

  alias Livre.Notification.Publisher

  @doc """
  Create a new notification and broadcast
  on Livre.PubSub

  Usage:

  	iex> user = insert!(:user)
  	...> {:ok, _notif} = Notification.push(user.id, "this is a test")
  """
  def push(user_id, message, action \\ nil)
      when is_binary(user_id) and is_binary(message) and (is_binary(action) or is_nil(action)) do
    attr = %{
      user_id: user_id,
      message: message,
      action: action
    }

    with changeset <- Notification.changeset(%Notification{}, attr),
         true <- changeset.valid?,
         {:ok, notif} <- Repo.insert(changeset) do
      Publisher.push(notif)
      {:ok, notif}
    else
      _any ->
        Logger.warning("fail to insert notification")
        {:error, :fail_to_insert_notification}
    end
  end

  @doc """
  List all notifications for a user

  Usage:

  	iex> user = insert!(:user)
  	...> {:ok, notif} = Notification.push(user.id, "this is a test")
  	...> Notification.list(user)
  	[notif]
  """
  def list(user) when is_struct(user, User) do
    list(user.id)
  end

  def list(user_id) when is_binary(user_id) do
    Notification.from()
    |> where_eq(:user_id, user_id)
    |> order_by([n], n.inserted_at)
    |> limit(100)
    |> Repo.all()
  end
end
