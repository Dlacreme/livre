defmodule LivreWeb.AccountController do
  use LivreWeb, :controller
  alias LivreWeb.Auth
  use Livre.Repo.Query, schemas: [Livre.Repo.User]

  def login(conn, _params) do
    conn
    |> assign(:signup_error, nil)
    |> render(:login)
  end

  def signup(conn, params) do
    with changeset <-
           User.changeset(
             %User{picture_url: "https://static.thenounproject.com/png/770852-200.png"},
             params
           ),
         true <- changeset.valid?,
         {:ok, user} <- Repo.insert(changeset) do
      conn
      |> Auth.login_user(user)
      |> assign(:signup_error, nil)
      |> redirect(to: ~p"/")
    else
      _any ->
        conn
        |> assign(:signup_error, "invalid params")
        |> render(:login)
    end
  end

  def logout(conn, _params) do
    conn
    |> Auth.logout()
    |> redirect(to: ~p"/account/login")
  end
end
