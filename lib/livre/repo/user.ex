defmodule Livre.Repo.User do
  @behaviour Livre.Repo.Schema
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
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    has_many :notifications, Livre.Repo.Notification

    timestamps(type: :utc_datetime)
  end

  @doc """
  Start a query with non-anonymised user by default.
  Use `include_deleted

  Usage:
    iex> insert!(:user)
    ...> deleted_at = DateTime.utc_now()
    ...> |> DateTime.add(-1, :day)
    ...> |> DateTime.truncate(:second)
    ...> insert!(:user, %{deleted_at: deleted_at})
    ...> Livre.Repo.all(User.from())
    ...> |> Enum.map(&(&1.deleted_at) == nil)
    ...> |> Enum.any?()
    true
  """
  @impl Livre.Repo.Schema
  def from(opts \\ [include_deleted: false]) do
    q = Ecto.Query.from(u in __MODULE__)

    if opts[:include_deleted] == false do
      Ecto.Query.where(q, [u], is_nil(u.deleted_at))
    else
      Ecto.Query.where(q, [u], not is_nil(u.deleted_at))
    end
  end

  @doc false
  def password_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_email()
    |> validate_password()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :provider, :provider_id, :name, :picture_url])
    |> validate_required([:email])
    |> unsafe_validate_unique(:email, Livre.Repo)
    |> unique_constraint(:email)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 72)
    |> hash_password()
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
