defmodule Livre.Repo.Migrations.CreateFriendsStatusEnum do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE notification_status AS ENUM ('new', 'read')"
    drop_query = "DROP TYPE notification_status"

    execute(create_query, drop_query)
  end
end
