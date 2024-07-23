defmodule LivreWeb.ButtonComponents do
  @moduledoc """
  """
  use Phoenix.Component

  @doc """
  Render a toggle button
  """
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(onclick)
  attr :type, :string, default: "button"
  attr :active, :boolean, default: false

  slot :inner_block, required: true

  def toggle(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "border rounded-full border-zinc-900 min-w-0",
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <Button.simple>Send!</Button.simple>
      <Button.simple phx-click="go" class="ml-2">Send!</Button.simple>
  """
  attr :class, :string, default: nil
  attr :style, :atom, values: [:flat, :brand], default: :flat
  attr :rest, :global, include: ~w(disabled form name value)
  attr :size, :atom, values: [:default, :xs], default: :default

  attr :type, :string, default: "button"
  slot :inner_block, required: true

  def simple(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        generic_class(),
        style_class(@style),
        size_class(@size),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :class, :string, default: nil
  attr :style, :atom, values: [:flat, :brand], default: :flat
  attr :rest, :global, include: ~w(disabled form name value)
  attr :size, :atom, values: [:default, :xs], default: :default

  slot :inner_block, required: true

  def fake(assigns) do
    assigns
    |> assign(:tag, "div")
    |> render()
  end

  attr :class, :string, default: nil
  attr :style, :atom, values: [:flat, :brand], default: :flat
  attr :rest, :global, include: ~w(disabled form name value)
  attr :size, :atom, values: [:default, :xs], default: :default
  attr :href, :string, default: "#"

  slot :inner_block, required: true

  def link(assigns) do
    # there is an odd warning when using 'href'
    # on a dynamic so I'm not directly use 'render'
    ~H"""
    <a href={@href}>
      <%= fake(assigns) %>
    </a>
    """
  end

  attr :tag, :string, required: true
  attr :class, :string, default: nil
  attr :style, :atom, values: [:flat, :brand], default: :flat
  attr :rest, :global, include: ~w(disabled form name value)
  attr :size, :atom, values: [:default, :xs], default: :default
  attr :type, :string, default: "button"
  slot :inner_block, required: true

  def render(assigns) do
    ~H"""
    <.dynamic_tag
      name={@tag}
      type={@type}
      class={[
        "flex items-center justify-center",
        generic_class(),
        style_class(@style),
        size_class(@size),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.dynamic_tag>
    """
  end

  defp generic_class() do
    "rounded phx-submit-loading:opacity-75 text-sm px-2 py-2 text-zinc-900 dark:text-white dark:enabled:active:text-zinc-900 dark:text-white/50 h-10 disabled:opacity-75"
  end

  defp style_class(style) do
    case style do
      :brand ->
        "bg-brand text-lg text-white enabled:hover:bg-brand-400 enabled:active:bg-brand-600"

      _ ->
        "enabled:hover:bg-zinc-300 enabled:active:bg-zinc-400 dark:enabled:hover:bg-zinc-800 dark:enabled:active:bg-zinc-950"
    end
  end

  defp size_class(size) do
    case size do
      :xs -> "text-xs px-1 py-1 h-8"
      _ -> ""
    end
  end

  slot :inner_block, required: true

  def google_login(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        generic_class(),
        "font-light w-56 max-w-56 text-white bg-[#4285F4] hover:bg-[#4285F4]/90 focus:ring-4 focus:outline-none focus:ring-[#4285F4]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center inline-flex items-center justify-between dark:focus:ring-[#4285F4]/55 mr-2 mb-2"
      ]}
    >
      <svg
        class="mr-2 -ml-1 w-4 h-4"
        aria-hidden="true"
        focusable="false"
        data-prefix="fab"
        data-icon="google"
        role="img"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 488 512"
      >
        <path
          fill="white"
          d="M488 261.8C488 403.3 391.1 504 248 504 110.8 504 0 393.2 0 256S110.8 8 248 8c66.8 0 123 24.5 166.3 64.9l-67.5 64.9C258.5 52.6 94.3 116.6 94.3 256c0 86.5 69.1 156.6 153.7 156.6 98.2 0 135-70.4 140.8-106.9H248v-85.3h236.1c2.3 12.7 3.9 24.9 3.9 41.4z"
        >
        </path>
      </svg>
      <%= render_slot(@inner_block) %>
      <div></div>
    </button>
    """
  end
end
