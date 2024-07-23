defmodule LivreWeb.SearchLiveComponent do
  use Phoenix.LiveComponent
  import LivreWeb.Gettext
  alias Livre.Social

  @impl true
  def mount(socket) do
    {:ok, assign(socket, results: [], query: "")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full relative">
      <form class="w-full" phx-change="search" phx-target={@myself}>
        <input
          name="query"
          class="w-full h-8"
          placeholder="search..."
          type="text"
          value={@query}
          phx-debounce="500"
        />
      </form>
      <%= if @query != "" do %>
        <div class="absolute bg-white w-full border">
          <%= display_result(%{results: @results}) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp display_result(%{results: []} = assigns) do
    ~H"""
    <div class="p-4"><%= gettext("no result") %></div>
    """
  end

  defp display_result(assigns) do
    ~H"""
    <div class="w-full flex flex-col">
      <%= for result <- @results do %>
        <a href={"/profile/#{result.id}"} class="px-4 py-2 display-block"><%= result.name %></a>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply,
     assign(socket,
       results: Social.global_search(query, ignore: [socket.assigns.current_user.id]),
       query: query
     )}
  end
end
