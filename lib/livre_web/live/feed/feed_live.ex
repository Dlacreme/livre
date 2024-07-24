defmodule LivreWeb.FeedLive do
  use LivreWeb, :live_view
  alias Livre.Feed
  alias Livre.Social
  alias Livre.Notification
  alias LivreWeb.LiveNotificationHelper

  @impl true
  def mount(_params, _session, socket) do
    current_user_id = socket.assigns.current_user.id
    LiveNotificationHelper.listen(current_user_id)

    {:ok,
     assign(socket,
       friend_suggestion: Social.friend_suggestion(current_user_id),
       posts: Feed.get_feed(current_user_id),
       notifications: Notification.list(current_user_id),
       post_content: ""
     )}
  end

  @impl true
  def handle_info({:notification, _data}, socket) do
    current_user_id = socket.assigns.current_user.id

    {:noreply,
     assign(socket,
       posts: Feed.get_feed(current_user_id),
       notifications: Notification.list(current_user_id)
     )}
  end

  @impl true
  def handle_event("create", %{"content" => content}, socket) do
    current_user_id = socket.assigns.current_user.id
    Feed.create_post(current_user_id, content)
    {:noreply, assign(socket, post_content: "", posts: Feed.get_feed(current_user_id))}
  end

  @impl true
  def handle_event(
        "comment",
        %{"content" => content, "post_owner_id" => post_owner_id, "post_id" => post_id},
        socket
      ) do
    current_user_id = socket.assigns.current_user.id
    Feed.comment_post(current_user_id, post_id, post_owner_id, content)
    {:noreply, assign(socket, posts: Feed.get_feed(current_user_id))}
  end

  defp order_comments(comments) when is_list(comments) do
    comments
    |> Enum.sort(&(&1.inserted_at < &2.inserted_at))
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%I:%M %d-%m-%y")
  end
end
