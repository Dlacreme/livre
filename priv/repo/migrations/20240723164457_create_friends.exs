defmodule Livre.Repo.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friendships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :from, references(:users, name: :from_id, type: :binary_id), null: false
      add :to, references(:users, name: :to_id, type: :binary_id), null: false
      add :status, :friendship_status, null: false, default: "sent"

      timestamps(type: :utc_datetime, updated_at: false)
    end
  end
end
