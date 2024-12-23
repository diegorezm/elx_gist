defmodule ElxGist.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query, warn: false
  alias ElxGist.Accounts.User
  alias ElxGist.Gists.Gist
  alias ElxGist.Repo

  alias ElxGist.Comments.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id) do
    query = from(c in Comment, where: c.id == ^id, preload: [:user])
    Repo.all(query)
  end

  def list_gist_comments(gist_id) do
    query =
      from(
        c in Comment,
        join: g in Gist,
        on: g.id == c.gist_id,
        where: g.id == ^gist_id,
        order_by: [desc: c.inserted_at],
        preload: [:user]
      )

    Repo.all(query)
  end

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:comments)
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%User{} = user, comment_id) do
    comment = Repo.get!(Comment, comment_id)

    if comment.user_id == user.id do
      Repo.delete(comment)
      {:ok, comment}
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
