defmodule Livre.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      add :post_id, references(:posts, type: :binary_id), null: false
      add :content, :text

      timestamps(type: :utc_datetime)
    end
  end
end
