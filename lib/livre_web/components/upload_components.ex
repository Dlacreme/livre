defmodule LivreWeb.UploadComponents do
  alias LivreWeb.FormComponents
  alias LivreWeb.ButtonComponents
  use Phoenix.Component
  import LivreWeb.Gettext

  attr :class, :string, default: nil
  attr :upload, :any, required: true
  attr :preview, :string, default: "/images/states/noimage.png"

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  def input(assigns) do
    IO.inspect(assigns[:preview], label: "preview")
    IO.inspect(assigns[:field], label: "field")

    ~H"""
    <div>
      <label
        for={@upload.ref}
        class={[
          "relative border rounded-full block overflow-hidden",
          @class
        ]}
        style={"background-image:url('#{@preview}');"}
      >
        <img
          id={"preview-#{@field.name}"}
          src={@preview}
          class="w-full h-full absolute top-0 right-0 left-0 bottom-0"
          alt="picture"
        />
        <div class="bg-slate-500/10 opacity-0 hover:opacity-100 cursor-pointer absolute top-0 right-0 left-0 bottom-0 flex justify-center items-center">
          <ButtonComponents.fake style={:brand} size={:xs}>
            <%= gettext("upload new") %>
          </ButtonComponents.fake>
        </div>
      </label>
      <.live_file_input upload={@upload} class="invisible" />
      <FormComponents.input type="text" readonly={true} name={@field.name} value={@field.value} />
    </div>
    """
  end
end
