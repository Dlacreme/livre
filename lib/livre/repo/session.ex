defmodule Livre.Repo.Session do
  @behaviour Livre.Repo.Schema
  require Ecto.Query

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    field :token, :binary
    field :expired_at, :utc_datetime
    field :initiated_by_ip, :string
    field :user_agent, :string

    belongs_to :user, Livre.Repo.User
    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Start a query with non-expired session by default.
  Use `include_expired: true` to include expired session.

  Usage:

  	iex> session = insert!(:session)
  	...> expire_at = DateTime.utc_now()
  	...> |> DateTime.add(-1, :day)
  	...> |> DateTime.truncate(:second)
  	...> insert!(:session, %{expired_at: expire_at})
  	...> Livre.Repo.all(Session.from())
  	[session]

  	iex> expire_at = DateTime.utc_now()
  	...> |> DateTime.add(-1, :day)
  	...> |> DateTime.truncate(:second)
  	...> session = insert!(:session, %{expired_at: expire_at})
  	...> Livre.Repo.all(Session.from(include_expired: true))
  	[session]
  """
  @impl Livre.Repo.Schema
  def from(opts \\ [include_expired: false]) do
    now = DateTime.utc_now()
    q = Ecto.Query.from(s in __MODULE__)

    if opts[:include_expired] == true do
      q
    else
      Ecto.Query.where(q, [s], s.expired_at > ^now)
    end
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :token, :expired_at, :initiated_by_ip, :user_agent])
    |> validate_required([:user_id, :token, :expired_at])
  end
end
