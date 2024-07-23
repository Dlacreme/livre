defmodule LivreWeb.ProfileLiveTest do
  use LivreWebTest.ConnCase, async: true
  import Phoenix.LiveViewTest
  import LivreTest.Factory

  use Livre.Repo.Query,
    schemas: [Livre.Repo.User]

  setup %{conn: conn} do
    user = insert!(:user)
    other_user = insert!(:user)

    conn =
      conn
      |> LivreWebTest.AuthHelper.login_user(user: user)

    {:ok, %{conn: conn, current_user: user, other_user: other_user}}
  end

  test "with a valid user", %{conn: conn, other_user: other_user} do
    {:ok, _view, html} = live(conn, "/profile/#{other_user.id}")
    assert html =~ other_user.name
  end

  test "with 'me' as id", %{conn: conn, current_user: current_user} do
    {:ok, _view, html} = live(conn, "/profile/me")
    assert html =~ current_user.name
  end

  test "with invalid id", %{conn: conn} do
    {:error, {:redirect, _any}} = live(conn, "/profile/oops")
  end
end
