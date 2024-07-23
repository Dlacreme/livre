defmodule Livre.Accounts do
  @moduledoc """
  Manager User & Sessions
  """
  use Livre.Repo.Query, schemas: [Livre.Repo.Session]

  def anonymise_user(_user) do
    {:error, :not_implemented}
  end

  @doc """
  Expire a session regardless of its current status.
  If the session was already expired - it override
  the 'expired_at' with the current datetime.
  """
  def expire_session(session) when is_struct(session, Session) do
    now = DateTime.utc_now()

    Session.changeset(session, %{expired_at: now})
    |> Repo.update()
  end
end
