defmodule Livre.Notification.Publisher do
  @moduledoc """
  Publish notification on Phoenix.PubSub
  """
  alias Phoenix.PubSub
  alias Livre.Repo.Notification

  def push(notification) when is_struct(notification, Notification) do
    PubSub.broadcast(Livre.PubSub, "user:" <> notification.user_id, format(notification))
  end

  defp format(notification) do
    {:notification, %{new_notification: notification.message}}
  end
end
