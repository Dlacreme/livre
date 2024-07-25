defmodule LivreWeb.PresenterComponents do
  use Phoenix.Component

  attr :user, :map, required: true

  def profile(assigns) do
    ~H"""
    <div>
      <.link href={"/profile/#{@user.id}"}>
        <%= profile_row(assigns) %>
      </.link>
    </div>
    """
  end

  attr :user, :map, required: true

  defp profile_row(assigns) do
    ~H"""
    <div class="flex items-start justify-start text-brand font-semibold">
      <img src={@user.picture_url} alt={@user.name} class="w-8 h-8 mr-2 rounded overflow-hidden" />
      <span><%= @user.name %></span>
    </div>
    """
  end

  attr :users, :list, default: []

  def profile_list(assigns) do
    ~H"""
    <div class="flex flex-col">
      <%= for user <- @users do %>
        <div class="mb-2">
          <%= profile(%{
            user: user
          }) %>
        </div>
      <% end %>
    </div>
    """
  end
end
