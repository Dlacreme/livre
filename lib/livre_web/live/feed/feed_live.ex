defmodule LivreWeb.FeedLive do
  use LivreWeb, :live_view
  alias Livre.Feed
  alias Livre.Notification
  alias LivreWeb.LiveNotificationHelper

  @impl true
  def mount(_params, _session, socket) do
    current_user_id = socket.assigns.current_user.id
    LiveNotificationHelper.listen(current_user_id)

    {:ok,
     assign(socket,
       posts: Feed.get_feed(current_user_id),
       notifications: Notification.list(current_user_id),
       post_content: ""
     )}
  end

  @impl true
  def handle_info({:notification, _data}, socket) do
    {:noreply, assign(socket, notifications: Notification.list(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_event("create", %{"content" => content}, socket) do
    current_user_id = socket.assigns.current_user.id
    Feed.create_post(current_user_id, content)
    {:noreply, assign(socket, posts: Feed.get_feed(current_user_id))}
  end

  @impl true
  def handle_event("comment", %{"content" => content, "post_id" => post_id}, socket) do
    current_user_id = socket.assigns.current_user.id
    Feed.comment_post(current_user_id, post_id, content)
    {:noreply, assign(socket, posts: Feed.get_feed(current_user_id))}
  end
end
