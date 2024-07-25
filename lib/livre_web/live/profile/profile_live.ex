defmodule LivreWeb.ProfileLive do
  alias Livre.Feed
  alias LivreWeb.LiveNotificationHelper
  use LivreWeb, :live_view

  use Livre.Repo.Query,
    schemas: [Livre.Repo.User]

  alias Livre.Social
  alias Livre.Notification

  @impl true
  def mount(params, _session, socket) do
    LiveNotificationHelper.listen(socket.assigns.current_user.id)

    socket =
      case get_user(params["id"], socket.assigns.current_user) do
        user when is_struct(user, User) ->
          LiveNotificationHelper.listen(socket.assigns.current_user.id)

          assign(socket,
            user: user,
            friendship: Social.get_friendship(socket.assigns.current_user.id, user.id),
            myself?: socket.assigns.current_user.id == user.id,
            notifications: Notification.list(socket.assigns.current_user.id),
            posts: Feed.get_user_posts(user.id),
            friends: Social.get_friends(user.id)
          )

        _any ->
          redirect(socket, to: "/404")
      end

    {:ok, socket}
  end

  @impl true
  def handle_info({:notification, _data}, socket) do
    {:noreply,
     assign(socket,
       posts: Feed.get_user_posts(socket.assigns.user.id),
       friends: Social.get_friends(socket.assigns.user.id),
       notifications: Notification.list(socket.assigns.current_user.id)
     )}
  end

  @impl true
  def handle_event(
        "comment",
        %{"content" => content, "post_owner_id" => post_owner_id, "post_id" => post_id},
        socket
      ) do
    current_user_id = socket.assigns.current_user.id
    Feed.comment_post(current_user_id, post_id, post_owner_id, content)
    {:noreply, assign(socket, posts: Feed.get_user_posts(socket.assigns.user.id))}
  end

  defp get_user("me", current_user) do
    get_user(current_user.id, nil)
  end

  defp get_user(id, _any) do
    User.from()
    |> where_eq(:id, id)
    |> Repo.one()
  rescue
    # if id is not a valid uuid
    _any -> nil
  end
end
