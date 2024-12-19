defmodule ElxGistWeb.GistFormComponent do
  use ElxGistWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="gist-form" phx-submit="submit" phx-change="validate" class="space-y-4">
        <.input
          field={@form[:description]}
          type="text"
          id="create_gist_form_description"
          placeholder="Your description..."
          autocomplete="off"
          phx-debounce="blur"
        />
        <.input :if={@form.data.id} field={@form[:id]} hidden />
        <div class="w-full h-full space-y-0 gap-0">
          <nav class="w-full flex justify-start items-center bg-card text-card-foreground  rounded-t-md rounded-b-none p-4">
            <.input
              field={@form[:name]}
              id="create_gist_form_name"
              type="text"
              placeholder="File name with extension..."
              phx-debounce="blur"
            />
          </nav>
          <div
            class="inline-flex w-full text-foreground"
            phx-update="ignore"
            id="gist-textarea-wrapper"
          >
            <textarea
              id="line-numbers"
              class="rounded-bl-md border-input-b text-sm h-[300px] w-[54px] text-right overflow-hidden resize-none pr-2 leading-6 bg-background focus:outline-none focus:border-input-b focus:ring-0"
              readonly
              autocomplete="off"
              style="border-right: none;border-top: none;"
            ></textarea>
            <div class="w-full">
              <.input
                id="gist-textarea"
                phx-hook="UpdateLineNumbers"
                field={@form[:markup_text]}
                type="textarea"
                class="h-[300px] w-full rounded-br-md bg-background focus:ring-0 resize-none border-input-b focus:outline-none focus:ring-none focus:border-input-b"
                placeholder="Your code..."
                phx-debounce="blur"
                autocomplete="off"
                style="border-top: none; border-left:none;"
              />
            </div>
          </div>
        </div>
        <div :if={@id && @id == :new}>
          <.button phx-disable-with="Creating...">
            Create gist
          </.button>
        </div>
        <div :if={@id && @id == :update}>
          <.button phx-disable-with="Updating...">
            Update gist
          </.button>
        </div>
      </.form>
    </div>
    """
  end
end
