defmodule LivreWeb.LayoutComponents do
  use Phoenix.Component

  @doc """
  Renders a div used as a main container on a page.
  Possible values for @type:
  - :standard (default) - standard 1200px width
  - :full - use full width

  Possible values for @padding:
  - :standard (default) - px-8 py-4
  - :none - p-0
  - :large - p-18
  """
  attr :type, :atom, default: :standard
  attr :padding, :atom, default: :standard
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def container(assigns) do
    cls_type =
      case Map.get(assigns, :type) do
        :standard -> "max-w-screen-xl h-full m-auto"
        :full -> "w-full h-full"
        :mini -> "max-w-screen-md h-full m-auto"
      end

    cls_padding =
      case Map.get(assigns, :padding) do
        :standard -> "px-12 py-4"
        :none -> "p-0"
        :large -> "p-16"
      end

    assigns = assign(assigns, cls_type: cls_type, cls_padding: cls_padding)

    ~H"""
    <div class="h-full w-full">
      <div class={"flex flex-col #{@cls_type} #{@cls_padding} #{@class}"}>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Render a title
  """
  attr :class, :string, default: nil
  attr :type, :string, default: "h1"
  slot :inner_block, required: true

  def title(assigns) do
    ~H"""
    <.dynamic_tag
      name={@type}
      class={[
        "text-lg font-semibold px-4 py-2 m-0",
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </.dynamic_tag>
    """
  end

  @doc """
  Show a hint/advice box
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def info(assigns) do
    ~H"""
    <div class={["p-4 bg-brand-200/40 rounded shadow bg-slate-700", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
