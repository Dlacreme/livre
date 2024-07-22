defmodule LivreWeb.FallbackHTML do
  use Phoenix.Controller

  def call(conn, {:error, {code, message}}) when is_integer(code) do
    message = Gettext.gettext(LivreWeb.Gettext, message)

    conn
    |> assign(:message, message)
    |> put_status(code)
    |> put_error_template()
  end

  defp put_error_template(conn) do
    conn
    |> put_view(LivreWeb.ErrorHTML)
    |> render("message.html")
  end
end
