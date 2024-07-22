defmodule LivreWeb.FallbackJSON do
  use Phoenix.Controller

  def call(conn, {:error, {code, _message}}) when is_integer(code) do
    conn
    |> put_error_view()
    |> put_status(code)
    |> render("#{code}.json")
  end

  defp put_error_view(conn) do
    put_view(conn, LivreWeb.ErrorJSON)
  end
end
