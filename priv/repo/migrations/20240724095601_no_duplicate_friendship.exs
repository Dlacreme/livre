defmodule Livre.Repo.Migrations.NoDuplicateFriendship do
  use Ecto.Migration

  def up do
    execute """
    CREATE UNIQUE INDEX friendship_dup ON friendships (LEAST(to_id, from_id), GREATEST(to_id, from_id));
    """
  end

  def down do
    execute """
    DROP INDEX friendship_dup;
    """
  end
end
