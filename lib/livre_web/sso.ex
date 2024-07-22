defmodule LivreWeb.SSO do
  @moduledoc """
  Handle every SSO related actions
  """
  use Livre.Query, repo: Livre.Repo
  require Logger
  alias Livre.Accounts.User

  use Phoenix.VerifiedRoutes,
    endpoint: LivreWeb.Endpoint,
    router: LivreWeb.Router

  def valid_provider?(provider) do
    existing_providers =
      Application.get_env(:livre, LivreWeb.SSO)
      |> Keyword.keys()
      |> Enum.map(&Atom.to_string/1)

    provider in existing_providers
  end

  def get_provider_configuration(provider) when is_binary(provider) do
    case valid_provider?(provider) do
      true -> get_provider_configuration(String.to_atom(provider))
      false -> {:error, :unknown_provider}
    end
  end

  def get_provider_configuration(provider) do
    Application.get_env(:livre, LivreWeb.SSO)
    |> Keyword.get(provider, nil)
    |> case do
      nil ->
        {:error, :unknown_provider}

      conf ->
        {:ok,
         Keyword.merge(conf,
           redirect_uri: LivreWeb.Endpoint.url() <> ~p"/sso/callback/#{provider}"
         )}
    end
  end

  def build_authorize_url(provider_configuration, scope) do
    params =
      provider_configuration
      |> Keyword.take([:client_id, :redirect_uri])
      |> Keyword.merge(response_type: "code", scope: scope)

    build_url(provider_configuration[:authorize_url], params)
  end

  def fetch_access_token(provider_configuration, code) do
    auth_header =
      (provider_configuration[:client_id] <> ":" <> provider_configuration[:client_secret])
      |> Base.encode64()
      |> then(fn x -> {"Authorization", "Basic " <> x} end)

    params =
      provider_configuration
      |> Keyword.take([:client_id, :redirect_uri])
      |> Keyword.merge(
        code: code,
        grant_type: "authorization_code"
      )

    case Finch.build(
           :post,
           build_url(provider_configuration[:token_url], params),
           [
             auth_header,
             {"Content-Type", "application/x-www-form-urlencoded"}
           ],
           ""
         )
         |> Finch.request(Livre.Finch) do
      {:ok, %Finch.Response{status: 200} = response} ->
        parse_access_token(response)

      _err ->
        {:error, :invalid_code}
    end
  end

  defp parse_access_token(response) do
    with {:ok, body} <- Jason.decode(response.body) do
      {:ok, body["access_token"]}
    else
      _err -> {:error, :invalid_access_token_body}
    end
  end

  def fetch_userinfo(provider_configuration, access_token) do
    auth_header = {"Authorization", "Bearer #{access_token}"}

    Finch.build(
      :get,
      provider_configuration[:userinfo_url],
      [auth_header]
    )
    |> Finch.request(Livre.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200} = response} ->
        Jason.decode(response.body)

      _err ->
        Logger.error("failed to get user info")
        {:error, :failed_to_get_userinfo}
    end
  end

  def map_userinfo(provider, userinfo) when is_binary(provider) do
    userinfo
    |> Map.merge(%{
      "provider" => provider,
      "provider_id" => userinfo["sub"],
      "picture_url" => userinfo["picture"]
    })
    |> Map.take([
      "email",
      "name",
      "picture_url",
      "provider",
      "provider_id"
    ])
  end

  def upsert_user(user_map) do
    case fetch_user(user_map) do
      nil ->
        User.changeset(%User{}, user_map)
        |> Repo.insert()

      user ->
        User.changeset(user, user_map)
        |> Repo.update()
    end
  end

  defp fetch_user(user_map) do
    User.from()
    |> where_eq(:provider, user_map["provider"])
    |> where_eq(:provider, user_map["provider"])
    |> where_eq(:provider_id, user_map["provider_id"])
    |> Repo.one()
    |> case do
      nil ->
        User.from()
        |> where_eq(:provider, user_map["provider"])
        |> where_eq(:email, user_map["email"])
        |> Repo.one()

      user ->
        user
    end
  end

  defp build_url(endpoint, params) do
    URI.parse(endpoint)
    |> Map.put(:query, URI.encode_query(params))
    |> URI.to_string()
  end
end
