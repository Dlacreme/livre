defmodule LivreWeb.ChannelTest do
  use LivreWebTest.ConnCase, async: true
  alias LivreWebTest.AuthHelper
  alias LivreWeb.Channel
  import LivreTest.Factory
  import Ecto.Query, only: [from: 2]

  describe "ensure_has_active_channel/2" do
    test "redirect to /channel/new if no channel available", %{conn: conn} do
      conn =
        conn
        |> AuthHelper.login_user()
        |> LivreWeb.Auth.fetch_current_user([])
        |> Channel.ensure_has_active_channel([])

      assert redirected_to(conn) =~ ~p"/channel/new"
    end

    test "use the active_channel set from user", %{conn: conn} do
      user = insert!(:user)
      channel = insert!(:channel, %{user_id: user.id})
      Livre.Creators.set_current_channel(user, channel.id)

      conn
      |> AuthHelper.login_user(user: user)
      |> LivreWeb.Auth.fetch_current_user([])
      |> Channel.ensure_has_active_channel([])

      user =
        from(u in Livre.Accounts.User, where: u.id == ^user.id)
        |> Livre.Repo.one!()

      assert user.current_channel_id == channel.id
    end

    test "use first channel available and set active_channel if no active_channel set", %{
      conn: conn
    } do
      user = insert!(:user)
      channel = insert!(:channel, %{user_id: user.id})

      conn
      |> AuthHelper.login_user(user: user)
      |> LivreWeb.Auth.fetch_current_user([])
      |> Channel.ensure_has_active_channel([])

      user =
        from(u in Livre.Accounts.User, where: u.id == ^user.id)
        |> Livre.Repo.one!()

      assert user.current_channel_id == channel.id
    end
  end
end
