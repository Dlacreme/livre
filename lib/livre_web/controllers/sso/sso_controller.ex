defmodule LivreWeb.SSOController do
  use LivreWeb, :controller

  require Logger
  alias LivreWeb.SSO
  alias LivreWeb.Auth

  def login(conn, params) do
    case SSO.get_provider_configuration(params["provider"]) do
      {:ok, conf} ->
        redirect(conn,
          external: SSO.build_authorize_url(conf, "openid email profile")
        )

      {:error, :unknown_provider} ->
        {:error, {400, "unknown provider"}}
    end
  end

  def callback(conn, params) do
    with {:ok, conf} <- SSO.get_provider_configuration(params["provider"]),
         {:ok, access_token} <- SSO.fetch_access_token(conf, params["code"]),
         {:ok, userinfo} <- SSO.fetch_userinfo(conf, access_token),
         user_map <- SSO.map_userinfo(params["provider"], userinfo),
         {:ok, user} <- SSO.upsert_user(user_map) do
      conn
      |> Auth.login_user(user)
      |> redirect(to: ~p"/")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("invalid user state #{inspect(changeset)}")
        {:error, {403, "email already taken"}}

      {:error, :unknown_provider} ->
        {:error, {400, "unknown provider"}}

      {:error, :invalid_code} ->
        {:error, {401, "invalid code. unauthorized"}}

      _err ->
        {:error, {500, "server error"}}
    end
  end
end
