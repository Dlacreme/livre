defmodule Livre.Repo.Friendship do
  require Ecto.Query
  @behaviour Livre.Repo.Schema
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "friendships" do
    field :status, Ecto.Enum, values: [:sent, :approved], default: :sent
    belongs_to :from, Livre.Repo.User, foreign_key: :from_id
    belongs_to :to, Livre.Repo.User, foreign_key: :to_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @impl Livre.Repo.Schema
  def from(_opts \\ []) do
    Ecto.Query.from(s in __MODULE__)
  end

  @doc false
  def changeset(friend, attrs) do
    friend
    |> cast(attrs, [:from_id, :to_id, :status])
    |> validate_required([:from_id, :to_id, :status])
  end
end
