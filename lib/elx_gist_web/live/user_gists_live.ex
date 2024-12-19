defmodule ElxGistWeb.UserGistsLive do
  alias ElxGist.Gists
  use ElxGistWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    params =
      Map.merge(
        %{"page" => "1", "page_size" => "5", "id" => socket.assigns.current_user.id},
        params
      )

    paginated_gists = Gists.list_user_gists(Map.get(params, "id"), params)
    gists = paginated_gists.entries

    pagination_info = %{
      page_number: paginated_gists.page_number,
      page_size: paginated_gists.page_size,
      total_pages: paginated_gists.total_pages,
      total_entries: paginated_gists.total_entries
    }

    socket =
      assign(socket,
        gists: gists,
        pagination_info: pagination_info
      )

    {:noreply, socket}
  end
end
