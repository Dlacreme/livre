defmodule LivreWeb.FeedLive do
  use LivreWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    Hello!
    """
  end
end
