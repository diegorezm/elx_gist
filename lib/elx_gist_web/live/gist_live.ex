defmodule ElxGistWeb.GistLive do
  use ElxGistWeb, :live_view
  alias ElxGistWeb.GistFormComponent
  alias ElxGist.Gists.Gist
  alias ElxGist.Gists

  def mount(%{"id" => id}, _session, socket) do
    gist = Gists.get_gist!(id)
    {:ok, relative_time} = Timex.format(gist.updated_at, "{relative}", :relative)
    gist = Map.put(gist, :relative, relative_time)
    {:ok, assign(socket, gist: gist)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user

    case Gists.delete_gist(current_user, id) do
      {:ok, _gist} ->
        socket = put_flash(socket, :info, "Gist deleted!")
        {:noreply, push_navigate(socket, to: ~p"/gist/create")}

      {:error, _unauthorized} ->
        socket = put_flash(socket, :error, "You are not authorized to do this!")
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"gist" => params}, socket) do
    changeset =
      %Gist{}
      |> Gists.change_gist(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("submit", %{"gist" => params}, socket) do
    case Gists.update_gist(socket.assigns.current_user, params) do
      {:ok, gist} ->
        {:noreply, push_navigate(socket, to: ~p"/gist?#{[id: gist.id]}")}

      {:error, _error} ->
        socket = put_flash(socket, :error, "You are not authorized to do this!")
        {:noreply, socket}
    end
  end
end
