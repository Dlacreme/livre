defmodule LivreWeb.NotificationLiveComponent do
  use LivreWeb, :live_component
  alias LivreWeb.CoreComponents
  import LivreWeb.Gettext
  alias Livre.Notification

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    nb_unread_notifs = nb_unread_notif(assigns.notifications)

    bell_color =
      if nb_unread_notifs > 0 do
        "text-red-700"
      else
        "text-slate-400"
      end

    assigns =
      assigns
      |> assign(:nb_unread, nb_unread_notifs)
      |> assign(:bell_color, bell_color)

    ~H"""
    <div>
      <Interactive.floating_toggle
        id="notification-center"
        arrow?={false}
        content_style="bg-white w-96"
      >
        <CoreComponents.icon class={"cursor-pointer " <> @bell_color} name="hero-bell-alert" />
        <%= if @nb_unread > 0 do %>
          <span class="text-white italic absolute bottom-2 left-4 text-xs font-bold">
            <%= @nb_unread %>
          </span>
        <% end %>
        <:content>
          <%= render_notifications(assigns) %>
        </:content>
      </Interactive.floating_toggle>
    </div>
    """
  end

  def render_notifications(%{notifications: []} = assigns) do
    ~H"""
    <div><%= gettext("No notifications") %></div>
    """
  end

  def render_notifications(assigns) do
    ~H"""
    <div class="flex flex-col">
      <%= for notif <- @notifications do %>
        <%= render_notification(%{myself: @myself, notification: notif}) %>
      <% end %>
    </div>
    """
  end

  defp render_notification(assigns) do
    ~H"""
    <div
      phx-click="read_notif"
      phx-target={@myself}
      phx-value-id={@notification.id}
      phx-value-action={@notification.action}
      class="cursor-pointer flex items-center border-b"
    >
      <a
        href={notif_link(@notification)}
        class={"flex-grow text-brand " <> state_class(@notification)}
      >
        <%= @notification.message %>
      </a>
      <Button.simple phx-click="remove_notif" phx-value-id={@notification.id} phx-target={@myself}>
        <CoreComponents.icon class="cursor-pointer text-slate-400" name="hero-trash" />
      </Button.simple>
    </div>
    """
  end

  @impl true
  def handle_event("remove_notif", %{"id" => notif_id}, socket) do
    current_user_id = socket.assigns.current_user.id
    Notification.delete(notif_id)
    {:noreply, assign(socket, notifications: Notification.list(current_user_id))}
  end

  @impl true
  def handle_event("read_notif", %{"id" => notif_id} = params, socket) do
    action = Map.get(params, "actions", nil)
    current_user_id = socket.assigns.current_user.id

    Notification.read(notif_id)

    if action do
      {:noreply, redirect(socket, to: action)}
    else
      {:noreply, assign(socket, notifications: Notification.list(current_user_id))}
    end
  end

  defp notif_link(notif) do
    if notif.action != nil do
      notif.action
    else
      "#"
    end
  end

  defp nb_unread_notif(notifications) do
    notifications
    |> Enum.filter(&(&1.status == :new))
    |> Enum.count()
  end

  defp state_class(notification) do
    if notification.status == :new do
      "font-bold"
    else
      "font-normal"
    end
  end
end
