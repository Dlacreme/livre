defmodule LivreWeb.AccountController do
  use LivreWeb, :controller
  alias LivreWeb.Auth

	def login(conn, _params) do
		render(conn, :login)
	end

  def logout(conn, _params) do
    conn
    |> Auth.logout()
    |> redirect(to: ~p"/welcome")
  end
end
