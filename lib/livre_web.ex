defmodule LivreWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use LivreWeb, :controller
      use LivreWeb, {:html, folder: "your_folder"}

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: true

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller(opts \\ [])

  def controller(format: :json) do
    quote do
      use Phoenix.Controller,
        formats: [:json],
        layouts: [html: LivreWeb.Layouts]

      action_fallback LivreWeb.FallbackJSON
      unquote(all_format_controller())
    end
  end

  def controller(_opts) do
    quote do
      use Phoenix.Controller,
        formats: [:html],
        layouts: [html: LivreWeb.Layouts]

      action_fallback LivreWeb.FallbackHTML
      unquote(all_format_controller())
    end
  end

  defp all_format_controller do
    quote do
      import Plug.Conn
      import LivreWeb.Gettext
      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {LivreWeb.Layouts, :live_app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html(opts \\ []) do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())

      # Maybe set embed_template by default
      unquote(maybe_embed_templates(opts[:embed_templates]))
    end
  end

  defp maybe_embed_templates(true) do
    quote do
      embed_templates("./*")
    end
  end

  defp maybe_embed_templates(_opts) do
    quote do
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import LivreWeb.CoreComponents
      # more generic components must be exposed with Alias to avoid confusing name
      alias LivreWeb.LayoutComponents, as: Layout
      alias LivreWeb.BrandingComponents, as: Branding
      alias LivreWeb.FormComponents, as: Form
      alias LivreWeb.ButtonComponents, as: Button
      alias LivreWeb.PresenterComponents, as: Presenter
      alias LivreWeb.InteractiveComponents, as: Interactive
      alias LivreWeb.UploadComponents, as: Upload
      alias LivreWeb.PresenterComponents, as: Presenter

      import LivreWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: LivreWeb.Endpoint,
        router: LivreWeb.Router,
        statics: LivreWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__({which, opts}) when is_atom(which) do
    apply(__MODULE__, which, [opts])
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
