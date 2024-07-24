defmodule LivreWeb.InteractiveComponents do
  @doc """
  """
  use Phoenix.Component
  alias LivreWeb.CoreComponents

  attr :id, :string, required: true
  attr :arrow?, :boolean, default: true
  attr :content_style, :string, default: ""
  slot :inner_block, required: true
  slot :content, required: true

  def floating_toggle(assigns) do
    ~H"""
    <div id={@id} class="relative">
      <div
        id={"#{@id}-label"}
        onclick={"window.LIVRE.actions.toggleFloatingMenu(event, '#{@id}-content', '#{@id}-arrow')"}
        class="cursor-pointer flex items-center"
      >
        <%= render_slot(@inner_block) %>
        <%= if @arrow? do %>
          <CoreComponents.icon
            id={"#{@id}-arrow"}
            name="hero-chevron-down"
            class="ml-2 transition-all "
          />
        <% end %>
      </div>
      <div
        id={"#{@id}-content"}
        class={
    	"border p-2 mt-4 z-50 " <>
    	"absolute end-0 start-0 " <>
    	"transition-opacity ease-in-out duration-300 opacity-0 -z-50 " <>
    	@content_style}
      >
        <%= render_slot(@content) %>
      </div>
    </div>
    """
  end
end
