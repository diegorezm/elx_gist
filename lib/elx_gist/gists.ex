defmodule ElxGist.Gists do
  @moduledoc """
  The Gists context.
  """

  import Ecto.Query, warn: false

  alias ElxGist.Gists.SavedGist
  alias ElxGist.Comments.Comment
  alias ElxGist.Repo

  alias ElxGist.Gists.Gist
  alias ElxGist.Accounts.User

  @doc """
  Returns the list of gists.

  ## Examples

      iex> list_gists()
      [%Gist{}, ...]

  """
  def list_gists do
    Repo.all(Gist)
  end

  @doc """
  Returns a paginated list of gists

  ## Examples

      iex> list_gists(%{"page" => 1, "page_size" => 10})
      %Scrivener.Page{entries: [%Gist{}, ...], page_number: 1, page_size: 10, total_entries: 100}
  """
  def list_gists(params) do
    query = from(g in Gist, preload: [:user])

    query
    |> Repo.paginate(params)
  end

  def list_gist_comments(gist_id) do
    query = from(c in Comment, where: c.gist_id == ^gist_id, preload: [:user])
    Repo.all(query)
  end

  def list_user_gists(user_id, params) do
    query = from(g in Gist, where: g.user_id == ^user_id, preload: [:user])
    Repo.paginate(query, params)
  end

  def count_gist_comments(gist_id) do
    count = from(c in Comment, where: c.gist_id == ^gist_id, select: count(c.id))
    Repo.one(count)
  end

  def count_saved_gists(gist_id) do
    count_query = from(c in SavedGist, where: c.gist_id == ^gist_id, select: count(c.id))
    Repo.one(count_query)
  end

  @doc """
  Gets a single gist.

  Raises `Ecto.NoResultsError` if the Gist does not exist.

  ## Examples

      iex> get_gist!(123)
      %Gist{}

      iex> get_gist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gist!(id) do
    query = from(g in Gist, where: g.id == ^id, preload: [:user])
    Repo.one(query)
  end

  @doc """
  Creates a gist.

  ## Examples

      iex> create_gist(%{field: value})
      {:ok, %Gist{}}

      iex> create_gist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_gist(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:gists)
    |> Gist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a gist.

  ## Examples

      iex> update_gist(gist, %{field: new_value})
      {:ok, %Gist{}}

      iex> update_gist(gist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_gist(%User{} = user, attrs) do
    gist = Repo.get!(Gist, attrs["id"])

    if user.id == gist.user_id do
      gist
      |> Gist.changeset(attrs)
      |> Repo.update()

      {:ok, gist}
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a gist.

  ## Examples

      iex> delete_gist(gist)
      {:ok, %Gist{}}

      iex> delete_gist(gist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_gist(%User{} = user, gist_id) do
    gist = Repo.get!(Gist, gist_id)

    if user.id == gist.user_id do
      Repo.delete(gist)
      {:ok, gist}
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gist changes.

  ## Examples

      iex> change_gist(gist)
      %Ecto.Changeset{data: %Gist{}}

  """
  def change_gist(%Gist{} = gist, attrs \\ %{}) do
    Gist.changeset(gist, attrs)
  end

  alias ElxGist.Gists.SavedGist

  @doc """
  Returns the list of saved_gists.

  ## Examples

      iex> list_saved_gists()
      [%SavedGist{}, ...]

  """
  def list_saved_gists(%User{} = user) do
    Repo.all(
      from g in Gist,
        join: sg in SavedGist,
        on: sg.gist_id == g.id,
        where: sg.user_id == ^user.id,
        preload: [:user]
    )
  end

  @doc """
  Gets a single saved_gist.

  Raises `Ecto.NoResultsError` if the Saved gist does not exist.

  ## Examples

      iex> get_saved_gist!(123)
      %SavedGist{}

      iex> get_saved_gist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_saved_gist!(id), do: Repo.get!(SavedGist, id)

  @doc """
  Creates a saved_gist.

  ## Examples

      iex> create_saved_gist(%{field: value})
      {:ok, %SavedGist{}}

      iex> create_saved_gist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_saved_gist(%User{} = user, gist_id) do
    gist = Repo.get!(Gist, gist_id)

    if has_user_saved_gist(user.id, gist.id) do
      {:error, :already_saved}
    else
      user
      |> Ecto.build_assoc(:saved_gists)
      |> SavedGist.changeset(%{user_id: user.id, gist_id: gist.id})
      |> Repo.insert()
    end
  end

  @doc """
  Updates a saved_gist.

  ## Examples

      iex> update_saved_gist(saved_gist, %{field: new_value})
      {:ok, %SavedGist{}}

      iex> update_saved_gist(saved_gist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_saved_gist(%SavedGist{} = saved_gist, attrs) do
    saved_gist
    |> SavedGist.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a saved_gist.

  ## Examples

      iex> delete_saved_gist(saved_gist)
      {:ok, %SavedGist{}}

      iex> delete_saved_gist(saved_gist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_saved_gist(%User{} = user, gist_id) do
    saved_gist =
      Repo.one(from(sg in SavedGist, where: sg.user_id == ^user.id and sg.gist_id == ^gist_id))

    IO.inspect(saved_gist, label: "Saved gist")

    if saved_gist == nil do
      {:error, :not_found}
    else
      # This is where the error happens
      Repo.delete(saved_gist)
      {:ok, saved_gist}
    end
  end

  def list_user_saved_gists(user_id) do
    query = from(s in SavedGist, where: s.user_id == ^user_id, preload: [:gists])
    Repo.all(query)
  end

  def toggle_saved_gist(%User{} = user, gist_id) do
    case has_user_saved_gist(user.id, gist_id) do
      true -> delete_saved_gist(user, gist_id)
      false -> create_saved_gist(user, gist_id)
    end
  end

  def has_user_saved_gist(user_id, gist_id) do
    Repo.exists?(from(s in SavedGist, where: s.user_id == ^user_id and s.gist_id == ^gist_id))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking saved_gist changes.

  ## Examples

      iex> change_saved_gist(saved_gist)
      %Ecto.Changeset{data: %SavedGist{}}

  """
  def change_saved_gist(%SavedGist{} = saved_gist, attrs \\ %{}) do
    SavedGist.changeset(saved_gist, attrs)
  end
end
