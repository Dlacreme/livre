defmodule LivreWeb.NotificationLiveComponent do
  use LivreWeb, :live_component
  alias LivreWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <ul>
      <li>
        <CoreComponents.icon class="cursor-pointer" name="hero-bell" />
      </li>
    </ul>
    """
  end
end
