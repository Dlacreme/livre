defmodule LivreWeb.SSOControllerTest do
  use LivreWebTest.ConnCase
  alias LivreWeb.SSO

  describe "login/2" do
    test "GET /sso/login/:valid_provider", %{conn: conn} do
      conn = get(conn, ~p"/sso/login/provider_test")
      {:ok, provider_conf} = SSO.get_provider_configuration(:provider_test)
      assert html_response(conn, 302) =~ provider_conf[:authorize_url]
    end

    test "GET /sso/login/:unknown_provider", %{conn: conn} do
      conn = get(conn, ~p"/sso/login/unknown_provider")
      assert html_response(conn, 400)
    end
  end

  describe "callback/2" do
    test "GET /sso/callback/:valid_code", %{conn: conn} do
      conn = get(conn, ~p"/sso/callback/provider_test?code=valid")
      assert html_response(conn, 302)
    end

    test "GET /sso/callback/:invalid_code", %{conn: conn} do
      conn = get(conn, ~p"/sso/callback/provider_test?code=invalid")
      assert html_response(conn, 401) =~ "invalid code"
    end
  end
end
