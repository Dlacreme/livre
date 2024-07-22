defmodule Livre.Accounts.Session do
  @behaviour Livre.Query.Schema
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

    belongs_to :user, Livre.Accounts.User
    timestamps(type: :utc_datetime, updated_at: false)
  end

  @impl Livre.Query.Schema
  def from(opts \\ [include_expired?: false]) do
    now = DateTime.utc_now()
    q = Ecto.Query.from(s in __MODULE__)

    if opts[:include_expired?] == false do
      Ecto.Query.where(q, [s], s.expired_at > ^now)
    else
      q
    end
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :token, :expired_at, :initiated_by_ip, :user_agent])
    |> validate_required([:user_id, :token, :expired_at])
  end
end
