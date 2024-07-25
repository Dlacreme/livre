defmodule Livre.Notification do
  @moduledoc """
  Create and send notifications
  """
  require Logger

  use Livre.Repo.Query,
    schemas: [Livre.Repo.Notification, Livre.Repo.User]

  alias Livre.Notification.Publisher

  @doc """
  Maybe push a notification if the first item of
  the first parameter is `:ok`.
  Returns the first parameters.
  Useful to potentially send a notification
  in a pipeline.

  Usage:
  	iex> user = insert!(:user)
  	...> {:ok, "success"} = Notification.maybe_push({:ok, "success"}, user.id, "success action")
  	...> {:error, "failure"} = Notification.maybe_push({:error, "failure"}, user.id, "failed action")
  	...> assert 1 == length(Notification.list(user.id))
  """
  def maybe_push(payload, user_id, message, action \\ nil)

  def maybe_push({:ok, _any} = payload, user_id, message, action) do
    push(user_id, message, action)
    payload
  end

  def maybe_push(any, _user_id, _message, _action) do
    any
  end

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
    |> order_by([n], desc: n.inserted_at)
    |> limit(100)
    |> Repo.all()
  end

  def read(notif_id) when is_binary(notif_id) do
    Repo.get!(Notification, notif_id)
    |> Notification.changeset(%{status: :read})
    |> Repo.update()
  end

  def delete(notif_id) when is_binary(notif_id) do
    %Notification{id: notif_id}
    |> Repo.delete()
  end
end
