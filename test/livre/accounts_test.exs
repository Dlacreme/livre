defmodule Livre.AccountsTest do
  use LivreTest.DataCase, async: true

  use Livre.Repo.Query,
    schemas: [
      Livre.Repo.Session
    ]

  import LivreTest.Factory
  alias Livre.Accounts

  doctest Livre.Accounts

  describe "expire_session/1" do
    test "expire an active session" do
      session =
        insert!(:session)

      Accounts.expire_session(session)

      session =
        Session.from(include_expired: true)
        |> where([s], s.id == ^session.id)
        |> Repo.one()

      assert session.expired_at < DateTime.utc_now()
    end
  end
end
