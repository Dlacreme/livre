defmodule LivreWeb.AccountControllerTest do
  use LivreWebTest.ConnCase

  alias LivreWeb.AccountController

  describe "login/2" do
    test "display the login button", %{conn: conn} do
      conn = get(conn, ~p"/account/login")
      assert html_response(conn, 200) =~ "login with google"
    end

    test "display the introduction", %{conn: conn} do
      conn = get(conn, ~p"/account/login")
      assert html_response(conn, 200) =~ "login with google"
    end
  end
end
