defmodule LivreWeb.ProfileLive do
  alias LivreWeb.LiveNotificationHelper
  use LivreWeb, :live_view

  use Livre.Repo.Query,
    schemas: [Livre.Repo.User]

  alias Livre.Social
  alias Livre.Notification

  @impl true
  def mount(params, _session, socket) do
    socket =
      case get_user(params["id"], socket.assigns.current_user) do
        user when is_struct(user, User) ->
          LiveNotificationHelper.listen(socket.assigns.current_user.id)

          assign(socket,
            user: user,
            friendship: Social.get_friendship(socket.assigns.current_user.id, user.id),
            myself?: socket.assigns.current_user.id == user.id,
            notifications: Notification.list(socket.assigns.current_user.id)
          )

        _any ->
          redirect(socket, to: "/404")
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("remove_notif", %{"id" => notif_id}, socket) do
    current_user_id = socket.assigns.current_user.id
    Notification.delete(notif_id)
    {:noreply, assign(socket, notifications: Notification.list(current_user_id))}
  end

  @impl true
  def handle_event("read_notif", %{"id" => notif_id}, socket) do
    current_user_id = socket.assigns.current_user.id
    Notification.read(notif_id)
    {:noreply, assign(socket, notifications: Notification.list(current_user_id))}
  end

  @impl true
  def handle_info({:notification, _data}, socket) do
    {:noreply, assign(socket, notifications: Notification.list(socket.assigns.current_user.id))}
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
