defmodule LivreWeb.ProfileControllerTest do
  use LivreWebTest.ConnCase, async: true
  import LivreTest.Factory

  setup %{conn: conn} do
    user = insert!(:user)
    other_user = insert!(:user)

    conn =
      conn
      |> LivreWebTest.AuthHelper.login_user(user: user)

    %{conn: conn, current_user: user, other_user: other_user}
  end

  describe "display/2" do
    test "with 'me' as id", %{conn: conn, current_user: current_user} do
      conn = get(conn, ~p"/profile/me")
      assert html_response(conn, 200) =~ current_user.name
    end

    test "with valid id", %{conn: conn, other_user: other_user} do
      conn = get(conn, "/profile/" <> other_user.id)
      assert html_response(conn, 200) =~ other_user.name
    end

    test "with invalid id", %{conn: conn} do
      conn = get(conn, ~p"/profile/oops")
      assert html_response(conn, 404) =~ "user not found"
    end
  end
end
