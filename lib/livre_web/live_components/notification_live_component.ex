defmodule LivreWeb.NotificationLiveComponent do
  use Phoenix.LiveComponent
  alias LivreWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <ul>
      <li>
        <CoreComponents.icon class="cursor-pointer" name="hero-user" />
      </li>
    </ul>
    """
  end
end
