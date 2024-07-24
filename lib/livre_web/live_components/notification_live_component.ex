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
        <CoreComponents.icon class="cursor-pointer text-slate-400" name="hero-bell-alert" />
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
        <%= if notif.action == nil do %>
          <div class="p-2">
            <%= notif.message %>
          </div>
        <% else %>
          <a href={notif.action} class="p-2 cursor-pointer">
            <%= notif.message %>
          </a>
        <% end %>
      <% end %>
    </div>
    """
  end
end
