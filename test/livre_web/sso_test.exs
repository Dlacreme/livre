defmodule LivreWeb.SSOTest do
  use LivreTest.DataCase, async: true

  alias LivreWeb.SSO
  alias Livre.Accounts.User
  import LivreTest.Factory

  setup do
    {:ok, conf} = SSO.get_provider_configuration(:provider_test)

    %{
      provider_configuration: conf
    }
  end

  describe "valid_provider?/1" do
    test "with a valid provider" do
      assert true == SSO.valid_provider?("provider_test")
    end

    test "with a invalid provider" do
      assert false == SSO.valid_provider?("unknown_provider")
    end
  end

  describe "get_provider_configuration/1" do
    test "return a valid configuration" do
      expected_configuration = [
        client_id: "provider_test_client_id",
        site: "http://test.com",
        authorize_url: "http://localhost:14000/authorize",
        token_url: "http://localhost:14000/token",
        userinfo_url: "http://localhost:14000/test_provider/userinfo",
        client_secret: "mysecret",
        redirect_uri: "http://localhost:4002/sso/callback/provider_test"
      ]

      assert {:ok, expected_configuration} == SSO.get_provider_configuration(:provider_test)
    end

    test "return a valid configuration using string" do
      assert {:ok, _any} = SSO.get_provider_configuration("provider_test")
    end

    test "return an error if the provider isn't configured" do
      assert {:error, :unknown_provider} = SSO.get_provider_configuration(:unknown_provider)
    end
  end

  describe "build_authorize_url" do
    test "build a valid authorize url", %{provider_configuration: conf} do
      expected_url =
        "http://localhost:14000/authorize?client_id=provider_test_client_id&redirect_uri=http%3A%2F%2Flocalhost%3A4002%2Fsso%2Fcallback%2Fprovider_test&response_type=code&scope=email"

      assert expected_url == SSO.build_authorize_url(conf, "email")
    end
  end

  describe "fetch_access_token/2" do
    test "with a valid code", %{provider_configuration: conf} do
      assert {:ok, "valid_access_token"} == SSO.fetch_access_token(conf, "valid")
    end

    test "with an invalid code", %{provider_configuration: conf} do
      assert {:error, :invalid_code} == SSO.fetch_access_token(conf, "invalid")
    end
  end

  describe "fetch_userinfo/2" do
    test "with a valid access_token", %{provider_configuration: conf} do
      assert {:ok, %{"name" => "Mathieu D"}} = SSO.fetch_userinfo(conf, "valid_access_token")
    end

    test "with an invalid access_token", %{provider_configuration: conf} do
      assert {:error, :failed_to_get_userinfo} ==
               SSO.fetch_userinfo(conf, "invalid_access_token")
    end
  end

  describe "userinfo_to_user_map/2" do
    test "with a valid SSO payload" do
      expected_result = %{
        "provider" => "test",
        "provider_id" => "test_id",
        "name" => "Mathieu D",
        "email" => "test@livre.com",
        "picture_url" => "picture.url"
      }

      assert expected_result ==
               SSO.map_userinfo("test", %{
                 "email" => "test@livre.com",
                 "email_verified" => true,
                 "family_name" => "D",
                 "given_name" => "Mathieu",
                 "locale" => "fr",
                 "name" => "Mathieu D",
                 "picture" => "picture.url",
                 "sub" => "test_id"
               })
    end
  end

  describe "upsert_user/1" do
    test "create a new user" do
      assert {:ok, %User{email: "user@public.com"}} =
               SSO.upsert_user(%{
                 "provider" => "provider_test",
                 "provider_id" => "#{System.unique_integer()}",
                 "picture_url" => "picture.url",
                 "name" => "Mathieu D",
                 "email" => "user@public.com"
               })
    end

    test "update an existing user with IDs" do
      user = insert!(:user)

      assert {:ok, %User{email: "updated@public.com"}} =
               SSO.upsert_user(%{
                 "provider" => user.provider,
                 "provider_id" => user.provider_id,
                 "email" => "updated@public.com"
               })
    end

    test "update an existing user with email" do
      user = insert!(:user, %{provider: "provider_test"})

      assert {:ok,
              %User{
                provider_id: "new_provider_id",
                provider: "provider_test"
              }} =
               SSO.upsert_user(%{
                 "provider" => "provider_test",
                 "provider_id" => "new_provider_id",
                 "email" => user.email
               })
    end

    test "return an error if email is taken" do
      insert!(:user, %{
        email: "user1@public.com",
        provider: "provider_test",
        provider_id: "existing_user_id"
      })

      assert {:error, %Ecto.Changeset{}} =
               SSO.upsert_user(%{
                 "provider" => "another_provider",
                 "provider_id" => "new_user_id",
                 "email" => "user1@public.com"
               })
    end
  end
end
