defmodule Livre.Accounts do
  @moduledoc """
  User management
  """
  alias Livre.Repo
  alias Livre.Accounts.Session

  @doc """
  Expire a session regardless of its current status.
  If the session was already expired - we will override
  the 'expired_at' with the current datetime.
  """
  def expire_session(session) when is_struct(session, Session) do
    now = DateTime.utc_now()

    Session.changeset(session, %{expired_at: now})
    |> Repo.update()
  end
end
