defmodule Livre.Repo.Comment do
  use Ecto.Schema
  require Ecto.Query
  @behaviour Livre.Repo.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :content, :string
    belongs_to :user, Livre.Repo.User
    belongs_to :post, Livre.Repo.Post

    timestamps(type: :utc_datetime)
  end

  @impl Livre.Repo.Schema
  def from(_opts \\ []) do
    Ecto.Query.from(s in __MODULE__)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :user_id, :post_id])
    |> validate_required([:content, :user_id, :post_id])
  end
end
