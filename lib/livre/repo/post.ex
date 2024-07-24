defmodule Livre.Repo.Post do
  use Ecto.Schema
  @behaviour Livre.Repo.Schema
  import Ecto.Changeset
  require Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :content, :string
    belongs_to :user, Livre.Repo.User
    has_many :comments, Livre.Repo.Comment

    timestamps(type: :utc_datetime)
  end

  @impl Livre.Repo.Schema
  def from(_opts \\ []) do
    Ecto.Query.from(s in __MODULE__)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :user_id])
    |> validate_required([:content, :user_id])
  end
end
