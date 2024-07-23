defmodule LivreTest.AuthTest do
  use LivreWebTest.ConnCase, async: true
  import LivreTest.Factory
  alias LivreWebTest.AuthHelper
  alias LivreWeb.Auth
  use Livre.Repo.Query, schemas: [Livre.Repo.Session]

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, LivreWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{conn: conn}
  end

  describe "login_user/2" do
    test "create a valid session", %{conn: conn} do
      user = insert!(:user)

      Auth.login_user(conn, user)

      session =
        from(s in Session, where: s.user_id == ^user.id)
        |> Repo.one()

      assert session.user_id == user.id
      # maybe improve this test
      assert Date.diff(session.expired_at, DateTime.utc_now()) > 0
    end

    test "set a valid cookie", %{conn: conn} do
      user = insert!(:user)
      %{resp_cookies: %{"_livre_session" => _cookie}} = Auth.login_user(conn, user)
    end
  end

  describe "logout/1" do
    test "removes the session cookie", %{conn: conn} do
      conn =
        conn
        |> AuthHelper.login_user()
        |> Auth.logout()

      assert %{
               resp_cookies: %{
                 "_livre_session" => %{
                   max_age: 0
                 }
               }
             } = conn
    end

    test "expire the current session", %{conn: conn} do
      user = insert!(:user)

      now = DateTime.utc_now()

      q =
        from(s in Session,
          where: s.user_id == ^user.id and s.expired_at > ^now,
          select: count()
        )

      conn =
        conn
        |> AuthHelper.login_user(user: user)

      assert 1 == Repo.one(q)

      conn
      |> Auth.logout()

      assert 0 == Repo.one(q)
    end
  end

  describe "fetch_current_user/2" do
    test "do nothing if no cookie available", %{conn: conn} do
      conn =
        conn
        |> Auth.fetch_current_user([])

      assert nil == Map.get(conn.assigns, :current_user)
    end

    test "do nothing if session has expired", %{conn: conn} do
      conn =
        conn
        |> AuthHelper.login_user(session_duration: -10)
        |> Auth.fetch_current_user([])

      assert nil == conn.assigns[:current_user]
    end

    test "set current_user if session is valid", %{conn: conn} do
      user = insert!(:user)

      conn =
        conn
        |> AuthHelper.login_user(user: user)
        |> Auth.fetch_current_user([])

      assert user == conn.assigns[:current_user]
    end
  end

  describe "require_logged_user/2" do
    test "allow user if authenticated", %{conn: conn} do
      user = insert!(:user)

      conn =
        conn
        |> AuthHelper.login_user(user: user)
        |> Auth.fetch_current_user([])
        |> Auth.require_logged_user([])

      refute conn.halted
      refute conn.status
    end

    test "redirect user to login page", %{conn: conn} do
      conn =
        conn
        |> Auth.fetch_current_user([])
        |> Auth.require_logged_user([])

      assert conn.halted
      assert redirected_to(conn) == ~p"/account/login"
    end
  end
end
