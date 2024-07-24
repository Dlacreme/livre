defmodule LivreWeb.NotificationLiveComponent do
  use LivreWeb, :live_component
  alias LivreWeb.CoreComponents
  import LivreWeb.Gettext

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <Interactive.floating_toggle
        id="notification-center"
        arrow?={false}
        content_style="bg-white w-96"
      >
        <CoreComponents.icon
          class={"cursor-pointer " <> class_color(assigns.notifications)}
          name="hero-bell-alert"
        />
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
        <div
          phx-click="read_notif"
          phx-value-id={notif.id}
          class="cursor-pointer flex items-center border-b"
        >
          <a href={notif_link(notif)} class={"flex-grow text-brand " <> state_class(notif)}>
            <%= notif.message %>
          </a>
          <Button.simple phx-click="remove_notif" phx-value-id={notif.id}>
            <CoreComponents.icon class="cursor-pointer text-slate-400" name="hero-trash" />
          </Button.simple>
        </div>
      <% end %>
    </div>
    """
  end

  defp notif_link(notif) do
    if notif.action != nil do
      notif.action
    else
      "#"
    end
  end

  defp class_color(notifications) do
    unread? =
      notifications
      |> Enum.map(&(&1.status == :new))
      |> Enum.any?()

    if unread? do
      "text-red-700"
    else
      "text-slate-400"
    end
  end

  defp state_class(notification) do
    if notification.status == :new do
      "font-bold"
    else
      "font-normal"
    end
  end
end
