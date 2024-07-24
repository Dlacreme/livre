defmodule Livre.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      add :message, :string, null: false
      add :action, :string, null: true
      add :status, :notification_status, null: false, default: "new"

      timestamps(type: :utc_datetime, updated_at: false)
    end
  end
end
