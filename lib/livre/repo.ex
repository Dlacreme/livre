defmodule Livre.Repo do
  use Ecto.Repo,
    otp_app: :livre,
    adapter: Ecto.Adapters.Postgres
end
