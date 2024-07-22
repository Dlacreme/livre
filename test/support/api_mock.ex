defmodule LivreTest.ApiMock do
  use Plug.Router
  require Logger

  plug(:match)
  plug(:dispatch)

  # Helpers

  @url "http://localhost:14000"

  def url() do
    @url
  end

  def error_url(status) do
    @url <> "/error?status=#{status}"
  end

  def server_unavailable_url do
    "http://localhost:14001"
  end

  # Implementation

  def init(opts) do
    opts
  end

  get "/" do
    send_resp(conn, 200, Jason.encode!(%{alive: true}))
  end

  get "/error" do
    conn =
      fetch_query_params(conn)

    send_resp(conn, String.to_integer(Map.get(conn.query_params, "status", "500")), "error")
  end

  # SSO
  post "/token" do
    case get_param(conn, "code") do
      "valid" -> send_resp(conn, 200, Jason.encode!(%{"access_token" => "valid_access_token"}))
      _any -> send_resp(conn, 401, "not authorized")
    end
  end

  get "/test_provider/userinfo" do
    auth_header =
      conn
      |> Map.get(:req_headers)
      |> Enum.find(fn x -> elem(x, 0) == "authorization" end)
      |> then(&elem(&1, 1))

    case auth_header == "Bearer valid_access_token" do
      true ->
        send_resp(
          conn,
          200,
          Jason.encode!(%{
            "name" => "Mathieu D",
            "email" => "user#{System.unique_integer()}@test.com"
          })
        )

      false ->
        send_resp(conn, 400, Jason.encode!(%{}))
    end
  end

  defp get_param(conn, key, default \\ nil) do
    conn = fetch_query_params(conn)
    Map.get(conn.query_params, key, default)
  end
end
