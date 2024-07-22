defmodule LivreWeb.BrandingComponents do
  use Phoenix.Component

  attr :id, :string
  attr :mini, :boolean, default: false
  attr :height, :string, default: "30px"
  attr :width, :string, default: "80px"
  attr :color, :atom, default: :white

  def logo(assigns) do
    assigns =
      assign(assigns, :logo_path, get_logo_path(assigns[:mini], assigns[:color]))

    ~H"""
    <div
      style={"height: #{@height}; width: #{@width}"}
      class="bg-hero bg-contain bg-no-repeat bg-center bg-logo-img dark:logo-dark-img"
    >
      &nbsp;
    </div>
    """
  end

  def olg(assigns) do
    ~H"""
    <img
      src={@logo_path}
      title="livre"
      alt="livre logo"
      height={@height}
      style={"height: #{@height}"}
    />
    """
  end

  defp get_logo_path(size, color) do
    img = "/images/logo"
    img = if size == :mini, do: img <> "-mini", else: img
    img = if color == :white, do: img <> "-white", else: img
    img <> ".png"
  end
end
