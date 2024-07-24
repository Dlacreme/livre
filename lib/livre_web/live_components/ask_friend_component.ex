defmodule LivreWeb.AskFriendComponent do
  use LivreWeb, :live_component
  alias Livre.Social

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @friendship == nil do %>
        <Button.simple style={:brand} phx-click="ask" phx-target={@myself}>
          <%= gettext("Ask friend") %>
        </Button.simple>
      <% else %>
        <%= if @friendship.status == :approved do %>
          <span><%= gettext("Friend since %{date}", date: @friendship.inserted_at) %></span>
          <Button.simple style={:brand} phx-click="remove" phx-target={@myself}>
            <%= gettext("Remove friend") %>
          </Button.simple>
        <% else %>
          <%= render_friendship_action(assigns) %>
        <% end %>
      <% end %>
    </div>
    """
  end

  def render_friendship_action(assigns) do
    ~H"""
    <div>
      <%= if @friendship.from_id == @current_user.id do %>
        <%= gettext("Request sent") %>
        <Button.simple style={:brand} phx-click="remove" phx-target={@myself}>
          <%= gettext("Cancel request friend") %>
        </Button.simple>
      <% else %>
        <%= gettext("Asked you as a friend") %>
        <Button.simple style={:brand} phx-click="approve" phx-target={@myself}>
          <%= gettext("Approve") %>
        </Button.simple>
        <Button.simple style={:brand} phx-click="remove" phx-target={@myself}>
          <%= gettext("Deny") %>
        </Button.simple>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("ask", _params, socket) do
    {:ok, friendship} =
      Social.ask_friend(socket.assigns.current_user.id, socket.assigns.target_user_id)

    {:noreply, assign(socket, friendship: friendship)}
  end

  def handle_event("approve", _params, socket) do
    {:noreply, Social.confirm_friendship(socket.assigns.friendship)}
  end

  def handle_event("remove", _params, socket) do
    Social.cancel_friendship(socket.assigns.friendship)
    {:noreply, assign(socket, friendship: nil)}
  end
end
