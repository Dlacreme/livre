# defmodule LivreWeb.ChannelFormLiveTest do
# use LivreWebTest.ConnCase
# use Livre.Query, repo: Livre.Repo, with_schemas: [Livre.Creators.Channel]
# import Phoenix.LiveViewTest

# setup %{conn: conn} do
# conn =
# conn
# |> LivreWebTest.AuthHelper.login_user()

# %{conn: conn}
# end

# describe "new" do
# test "render form", %{conn: conn} do
# {:ok, _view, html} = live(conn, ~p"/channel/new")
# assert html =~ "create new channel"
# assert html =~ ~s(name="channel[label]")
# assert html =~ ~s(name="channel[slug]")
# assert html =~ ~s(disabled="disabled">\n  \nnext\n        \n</button>)
# end

# test "can submit when valid", %{conn: conn} do
# {:ok, view, _html} = live(conn, ~p"/channel/new")

# assert render_change(view, :validate, %{
# "channel" => %{
# "label" => "valid label",
# "slug" => "valid_slug"
# }
# }) =~
# ~s( \">\n  \nnext\n        \n</button>)

# assert {:error, {:redirect, %{to: "/channel/" <> _channel_id}}} =
# render_change(view, :save, %{
# "channel" => %{
# "label" => "valid label",
# "slug" => "valid_slug"
# }
# })

# Channel.from()
# |> where_eq(:slug, "valid_slug")
# |> Repo.one!()
# end
# end
# end
