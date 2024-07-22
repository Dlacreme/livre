defmodule Livre.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :binary
      add :expired_at, :utc_datetime
      add :initiated_by_ip, :string, null: true, size: 50
      add :user_agent, :string, null: true, size: 512
      add :user_id, references(:users, type: :binary_id), null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end
  end
end
