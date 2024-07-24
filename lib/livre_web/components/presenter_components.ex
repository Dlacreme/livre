defmodule LivreWeb.PresenterComponents do
  use Phoenix.Component

  attr :picture_url, :string, required: true
  attr :name, :string, required: true
  attr :link, :string, required: false, default: nil

  def profile(assigns) do
    ~H"""
    <div>
      <%= if @link do %>
        <.link href={@link}>
          <%= profile_row(assigns) %>
        </.link>
      <% else %>
        <%= profile_row(assigns) %>
      <% end %>
    </div>
    """
  end

  defp profile_row(assigns) do
    ~H"""
    <div class="flex items-start justify-start text-brand font-semibold">
      <img src={@picture_url} alt={@name} class="w-8 h-8 mr-2 rounded overflow-hidden" />
      <span><%= @name %></span>
    </div>
    """
  end
end
