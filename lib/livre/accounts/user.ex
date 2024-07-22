defmodule Livre.Accounts.User do
  alias Ecto.Changeset
  @behaviour Livre.Query.Schema
  require Ecto.Query

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :provider, :string
    field :provider_id, :string
    field :name, :string
    field :picture_url, :string
    field :deleted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @impl Livre.Query.Schema
  def from(opts \\ [include_deleted?: false]) do
    q = Ecto.Query.from(u in __MODULE__)

    if opts[:include_deleted?] == false do
      Ecto.Query.where(q, [u], is_nil(u.deleted_at))
    else
      Ecto.Query.where(q, [u], not is_nil(u.deleted_at))
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :provider, :provider_id, :name, :picture_url])
    |> validate_required([:email])
    |> unsafe_validate_unique(:email, Livre.Repo)
    |> unique_constraint(:email)
  end
end
