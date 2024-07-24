defmodule LivreWeb.ProfileLive do
  use LivreWeb, :live_view

  use Livre.Repo.Query,
    schemas: [Livre.Repo.User]

  alias Livre.Social

  def mount(params, _session, socket) do
    socket =
      case get_user(params["id"], socket.assigns.current_user) do
        user when is_struct(user, User) ->
          assign(socket,
            user: user,
            friendship: Social.get_friendship(socket.assigns.current_user.id, user.id),
            myself?: socket.assigns.current_user.id == user.id
          )

        _any ->
          redirect(socket, to: "/404")
      end

    {:ok, socket}
  end

  defp get_user("me", current_user) do
    get_user(current_user.id, nil)
  end

  defp get_user(id, _any) do
    User.from()
    |> where_eq(:id, id)
    |> Repo.one()
  rescue
    # if id is not a valid uuid
    _any -> nil
  end
end
