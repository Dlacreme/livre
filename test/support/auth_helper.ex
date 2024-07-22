defmodule LivreWebTest.AuthHelper do
  import LivreTest.Factory
  alias LivreWeb.Auth

  def login_user(conn, opts \\ []) do
    user = Keyword.get(opts, :user, insert!(:user))

    conn =
      conn
      |> Map.replace!(:secret_key_base, LivreWeb.Endpoint.config(:secret_key_base))
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Auth.login_user(user, opts)
      |> Plug.Conn.fetch_session()

    Plug.Test.put_req_cookie(
      conn,
      "_livre_session",
      conn.resp_cookies["_livre_session"][:value]
    )
  end
end
