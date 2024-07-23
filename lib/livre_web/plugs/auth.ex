defmodule LivreWeb.Auth do
  @moduledoc """
  Handle authentication
  """
  use Livre.Repo.Query,
    schemas: [
      Livre.Repo.User,
      Livre.Repo.Session
    ]

  import Plug.Conn
  import Phoenix.Controller
  alias Livre.Accounts
  require Logger

  use Phoenix.VerifiedRoutes,
    endpoint: LivreWeb.Endpoint,
    router: LivreWeb.Router

  # 30 days
  @session_duration 60 * 60 * 24 * 30
  @rand_size 32
  @cookie "_livre_session"

  def login_user(conn, user, opts \\ []) do
    session_duration =
      Keyword.get(opts, :session_duration, @session_duration)

    case create_session(user, get_ip(conn), get_user_agent(conn), session_duration) do
      {:ok, session} ->
        conn
        |> renew_session()
        |> put_token_in_session(session.token)
        |> put_resp_cookie(@cookie, Base.encode64(session.token),
          sign: true,
          max_age: session_duration,
          same_site: "Lax"
        )

      err ->
        Logger.error("failed to log user in > #{inspect(err)}")
        {:error, :login_failed}
    end
  end

  def logout(conn) do
    with {conn, token} <- get_current_session_token(conn),
         %Session{} = session <- get_session_from_token(token) do
      Accounts.expire_session(session)

      conn
      |> renew_session()
      |> delete_resp_cookie(@cookie, sign: true, same_site: "Lax")
      |> redirect(to: ~p"/welcome")
    else
      _any -> conn
    end
  end

  def fetch_current_user(conn, _opts) do
    {conn, user} =
      case get_current_session_token(conn) do
        :error -> {conn, nil}
        {conn, token} -> {conn, get_user_from_session_token(token)}
      end

    # it's fine to assign a nil value here should the
    # user be missing
    assign(conn, :current_user, user)
  end

  def require_logged_user(%{assigns: %{current_user: current_user}} = conn, _opts)
      when is_struct(current_user, User) do
    conn
  end

  def require_logged_user(conn, _opts) do
    conn
    |> Phoenix.Controller.redirect(to: ~p"/account/login")
    |> halt()
  end

  def get_current_session_token(conn) do
    if token = get_session(conn, :user_token) do
      {conn, token}
    else
      conn = fetch_cookies(conn, signed: [@cookie])

      with {:ok, token} <- Map.fetch(conn.cookies, @cookie),
           {:ok, token} <- Base.decode64(token),
           conn <- put_token_in_session(conn, token) do
        {conn, token}
      end
    end
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule LivreWeb.PageLive do
        use LivreWeb, :live_view

        on_mount {LivreWeb.Auth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{LivreWeb.Auth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_logged_user, _params, session, socket) do
    socket =
      mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.redirect(to: ~p"/welcome")

      {:halt, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if token = session["user_token"] do
        get_user_from_session_token(token)
      end
    end)
  end

  defp get_session_from_token(token) do
    Session.from()
    |> where([s], s.token == ^token)
    |> Repo.one()
  end

  defp get_user_from_session_token(nil) do
    nil
  end

  defp get_user_from_session_token(token) do
    Session.from()
    |> join(:inner, [s], u in assoc(s, :user))
    |> where([s, u], s.token == ^token)
    |> select([s, u], u)
    |> Repo.one()
  end

  defp create_session(user, ip, user_agent, session_duration) when is_struct(user, User) do
    expiration_date =
      DateTime.utc_now()
      |> DateTime.add(session_duration)

    %Session{}
    |> Session.changeset(%{
      user_id: user.id,
      initiated_by_ip: ip,
      user_agent: user_agent,
      expired_at: expiration_date,
      token: :crypto.strong_rand_bytes(@rand_size)
    })
    |> Repo.insert()
  end

  defp get_user_agent(conn) do
    conn.req_headers
    |> Enum.find(fn x -> elem(x, 0) == "user-agent" end)
    |> case do
      {"user-agent", user_agent} -> user_agent
      _any -> nil
    end
  end

  defp get_ip(conn) do
    case Map.get(conn, :remote_ip, nil) do
      nil -> nil
      ip_tuple -> :inet.ntoa(ip_tuple) |> to_string
    end
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end
end
