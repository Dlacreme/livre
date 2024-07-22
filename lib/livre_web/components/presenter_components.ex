defmodule LivreWeb.PresenterComponents do
  use Phoenix.Component

  attr :picture_url, :string, required: true
  attr :label, :string, required: true
  attr :link, :string, required: false, default: nil

  def entity(assigns) do
    ~H"""
    <div>
      <%= if @link do %>
        <.link href={@link}>
          <%= entity_row(assigns) %>
        </.link>
      <% else %>
        <%= entity_row(assigns) %>
      <% end %>
    </div>
    """
  end

  defp entity_row(assigns) do
    ~H"""
    <div class="flex items-center justify-center">
      <img src={@picture_url} alt={@label} class="w-8 h-8 mr-2 rounded overflow-hidden" />
      <span><%= @label %></span>
    </div>
    """
  end
end
