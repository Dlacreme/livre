defmodule Livre.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :provider, :string, null: true
      add :provider_id, :string, null: true
      add :name, :string, null: true
      add :picture_url, :string, null: true
      add :deleted_at, :utc_datetime, null: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
