defmodule ElxGistWeb.GistLive do
  alias ElxGist.Comments.Comment
  alias ElxGist.Comments
  use ElxGistWeb, :live_view
  alias ElxGistWeb.GistFormComponent
  alias ElxGist.Gists.Gist
  alias ElxGist.Gists

  def mount(%{"id" => id}, _session, socket) do
    gist = Gists.get_gist!(id)
    comments = Comments.list_gist_comments(id)
    {:ok, relative_time} = Timex.format(gist.updated_at, "{relative}", :relative)
    gist = Map.put(gist, :relative, relative_time)
    comment_form = to_form(Comments.change_comment(%Comment{}))
    {:ok, assign(socket, gist: gist, comments: comments, comment_form: comment_form)}
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

  def handle_event("comment-submit", %{"comment" => params}, socket) do
    current_user = socket.assigns.current_user

    case Comments.create_comment(current_user, params) do
      {:ok, comment} ->
        socket = push_event(socket, "clear-textareas", %{})
        changeset = Comments.change_comment(%Comment{})
        socket = assign(socket, comment_for: changeset)
        socket = send_update(socket, id: comment.id)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("comment-delete", %{"id" => comment_id}, socket) do
    current_user = socket.assigns.current_user

    case Comments.delete_comment(current_user, comment_id) do
      {:ok, _comment} ->
        socket = send_update(socket, id: current_user.id)
        {:noreply, socket}

      {:error, _message} ->
        socket = put_flash(socket, :error, "You are not authorized to do this!")
        {:noreply, socket}
    end
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

  def handle_event("bookmark", %{"gist" => gist_id}, socket) do
    current_user = socket.assigns.current_user
    Gists.toggle_saved_gist(current_user, gist_id)
    socket = send_update(GistCardComponent, id: gist_id, current_user: current_user)
    {:noreply, socket}
  end

  def get_formatted_date(date) do
    {:ok, relative_time} = Timex.format(date, "{relative}", :relative)
    relative_time
  end

  def get_saved_count(gist_id) do
    Gists.count_saved_gists(gist_id)
  end

  def has_user_saved_gist(user, gist_id) do
    Gists.has_user_saved_gist(user.id, gist_id)
  end

  def toggle_saved_gist(user, gist_id) do
    Gists.toggle_saved_gist(user, gist_id)
  end
end
