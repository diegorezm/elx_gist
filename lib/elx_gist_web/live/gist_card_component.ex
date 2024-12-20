defmodule ElxGistWeb.GistCardComponent do
  alias ElxGistWeb.GistCardComponent
  use ElxGistWeb, :live_component
  alias ElxGist.Gists

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <li class="space-y-4 w-2/3">
      <nav class="flex items-center justify-between">
        <div class="flex items-center gap-4">
          <img src="/images/user-image.svg" class="h-7 w-auto" />
          <div>
            <p class="font-bold text-primary">
              <.link href={~p"/users/gists?#{[id: @gist.user.id]}"} class="hover:underline">
                {@gist.user.email}
              </.link>
              <span class="text-foreground">/</span>
              <.link href={~p"/gist?#{[id: @gist.id]}"} class="hover:underline">
                {@gist.name}
              </.link>
            </p>
            <p class="text-sm">
              {get_formatted_date(@gist.updated_at)}
            </p>
            <p :if={@gist.description && @gist.description != ""} class="text-sm">
              {@gist.description}
            </p>
          </div>
        </div>
        <div class="inline-flex gap-4">
          <button class="btn btn-ghost">
            <img src="/images/comment.svg" alt="Comment button" class="h-5 w-5" /> {get_gist_comment_count(
              @gist.id
            )}
          </button>

          <button
            class="btn btn-ghost"
            phx-click="bookmark"
            phx-value-gist={@gist.id}
            phx-target={@myself}
          >
            <%= if has_user_saved_gist(@current_user, @gist.id)  do %>
              <img src="/images/BookmarkFilled.svg" alt="Bookmark button" class="h-5 w-5" /> {get_gist_saved_count(
                @gist.id
              )}
            <% else %>
              <img src="/images/BookmarkOutline.svg" alt="Bookmark button" class="h-5 w-5" /> {get_gist_saved_count(
                @gist.id
              )}
            <% end %>
          </button>
        </div>
      </nav>
      <div
        phx-hook="Highlight"
        id="view-code-block-element"
        class="flex h-full"
        data-name={@gist.name}
        phx-update="ignore"
      >
        <pre class="h-full max-h-[300px] w-full rounded-md bg-background border border-input-b m-0 overflow-auto"><code class="w-full">{@gist.markup_text}</code></pre>
      </div>
    </li>
    """
  end

  def has_user_saved_gist(user, gist_id) do
    Gists.has_user_saved_gist(user.id, gist_id)
  end

  def handle_event("bookmark", %{"gist" => gist_id}, socket) do
    current_user = socket.assigns.current_user
    Gists.toggle_saved_gist(current_user, gist_id)
    socket = send_update(GistCardComponent, id: gist_id, current_user: current_user)
    {:noreply, socket}
  end

  def toggle_saved_gist(user, gist_id) do
    Gists.toggle_saved_gist(user, gist_id)
  end

  def get_gist_comment_count(gist_id) do
    Gists.count_gist_comments(gist_id)
  end

  def get_gist_saved_count(gist_id) do
    Gists.count_saved_gists(gist_id)
  end

  def get_formatted_date(date) do
    case Timex.format(date, "{relative}", :relative) do
      {:ok, relative_time} ->
        relative_time

      {:error, _error} ->
        date
    end
  end
end
