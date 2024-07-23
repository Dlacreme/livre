defmodule LivreWeb.BrandingComponents do
  use Phoenix.Component

  def logo(assigns) do
    ~H"""
    <div style="font-family: logo" class="text-white text-bold text-xl">
      FaceLivre
    </div>
    """
  end
end
