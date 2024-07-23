defmodule Livre.Repo.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "friends" do
    field :status, Ecto.Enum, values: [:sent, :approved], default: :sent
    belongs_to :from, Livre.User, foreign_key: :from_id
    belongs_to :to, Livre.User, foreign_key: :to_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(friend, attrs) do
    friend
    |> cast(attrs, [:from_id, :to_id, :status])
    |> validate_required([:from_id, :to_id, :status])
  end
end
