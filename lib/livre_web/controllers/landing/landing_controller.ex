defmodule LivreWeb.LandingController do
  use LivreWeb, :controller

  def index(conn, _params) do
    render(conn, :index, layout: false)
  end
end
