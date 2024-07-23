defmodule LivreWeb.ProfileController do
  use LivreWeb, :controller

  use Livre.Repo.Query,
    schemas: [Livre.Repo.User]

  def display(conn, %{"id" => "me"}) do
    display(conn, %{"id" => conn.assigns.current_user.id})
  end

  def display(conn, %{"id" => id}) when is_binary(id) do
    case fetch_user(id) do
      user when is_struct(user, User) ->
        conn
        |> assign(:user, user)
        |> render(:index)

      _any ->
        {:error, {404, "user not found"}}
    end
  end

  defp fetch_user(id) do
    User.from()
    |> where_eq(:id, id)
    |> Repo.one()
  rescue
    # if id is not a valid uuid
    _any -> nil
  end
end
