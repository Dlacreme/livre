defmodule LivreWeb.DashboardController do
  use LivreWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
