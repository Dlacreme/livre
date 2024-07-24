defmodule Livre.Repo.Notification do
  @behaviour Livre.Repo.Schema
  require Ecto.Query
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :message, :string
    field :action, :string
    belongs_to :user, Livre.Repo.User
    field :status, Ecto.Enum, values: [:new, :read], default: :new

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Start a query for notification.
  """
  def from(_opts \\ []) do
    Ecto.Query.from(n in __MODULE__)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :message, :action, :status])
    |> validate_required([:user_id, :message])
  end
end
