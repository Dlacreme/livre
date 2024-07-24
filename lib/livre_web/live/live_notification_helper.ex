defmodule LivreWeb.LiveNotificationHelper do
  @moduledoc """
  Centralize notification handling for our live views.

  You must use `listen/1` in your `mount/3` action and then
  implement the following handler:

  	def handle_info({:notification, data}, socket) do
  	  # change your socket
  		{:noreply, socket}
  	end
  """

  def listen(user_id) when is_binary(user_id) do
    Phoenix.PubSub.subscribe(Livre.PubSub, "user:" <> user_id)
  end
end
