defmodule LivreWeb.Router do
  use LivreWeb, :router

  import LivreWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LivreWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LivreWeb do
    pipe_through :browser

    scope "/account" do
      get "/logout", AccountController, :logout
    end

    scope "/sso" do
      get "/login/:provider", SSOController, :login
      get "/callback/:provider", SSOController, :callback
    end
  end

  scope "/", LivreWeb do
    pipe_through [:browser, :redirect_logged_user]

    scope "/account" do
      get "/login", AccountController, :login
    end
  end

  scope "/", LivreWeb do
    pipe_through [:browser, :require_logged_user]

    live_session(:require_logged_user,
      on_mount: [{LivreWeb.Auth, :ensure_logged_user}]
    ) do
      live "/", FeedLive
      live "/profile/:id", ProfileLive
    end
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:livre, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      import Phoenix.LiveDashboard.Router
      live_dashboard "/live_dashboard", metrics: LivreWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
