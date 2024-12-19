defmodule ElxGistWeb.UserSavedGistsLive do
  use ElxGistWeb, :live_view

  alias ElxGist.Gists

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    gists = Gists.list_saved_gists(current_user)
    socket = assign(socket, gists: gists)
    {:ok, socket}
  end
end
