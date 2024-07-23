defmodule Livre.Repo.Migrations.CreateFriendsStatusEnum do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE friendship_status AS ENUM ('sent', 'approved')"
    drop_query = "DROP TYPE friendship_status"

    execute(create_query, drop_query)
  end
end
