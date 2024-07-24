defmodule LivreWeb.NotificationLiveComponent do
  @moduledoc """
  This is a fully indenpendant LiveComponent
  	that fetch data from our database and listen
  	to upcoming notification through Livre.PubSub
  """
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
    <div>
      <%= for notif <- @notifications do %>
        <%= notif.message %>
      <% end %>
    </div>
    """
  end
end
