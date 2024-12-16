defmodule ElxGist.GistTest do
  use ElxGist.DataCase

  alias ElxGist.Gist

  describe "saved_gists" do
    alias ElxGist.Gist.SavedGist

    import ElxGist.GistFixtures

    @invalid_attrs %{}

    test "list_saved_gists/0 returns all saved_gists" do
      saved_gist = saved_gist_fixture()
      assert Gist.list_saved_gists() == [saved_gist]
    end

    test "get_saved_gist!/1 returns the saved_gist with given id" do
      saved_gist = saved_gist_fixture()
      assert Gist.get_saved_gist!(saved_gist.id) == saved_gist
    end

    test "create_saved_gist/1 with valid data creates a saved_gist" do
      valid_attrs = %{}

      assert {:ok, %SavedGist{} = saved_gist} = Gist.create_saved_gist(valid_attrs)
    end

    test "create_saved_gist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gist.create_saved_gist(@invalid_attrs)
    end

    test "update_saved_gist/2 with valid data updates the saved_gist" do
      saved_gist = saved_gist_fixture()
      update_attrs = %{}

      assert {:ok, %SavedGist{} = saved_gist} = Gist.update_saved_gist(saved_gist, update_attrs)
    end

    test "update_saved_gist/2 with invalid data returns error changeset" do
      saved_gist = saved_gist_fixture()
      assert {:error, %Ecto.Changeset{}} = Gist.update_saved_gist(saved_gist, @invalid_attrs)
      assert saved_gist == Gist.get_saved_gist!(saved_gist.id)
    end

    test "delete_saved_gist/1 deletes the saved_gist" do
      saved_gist = saved_gist_fixture()
      assert {:ok, %SavedGist{}} = Gist.delete_saved_gist(saved_gist)
      assert_raise Ecto.NoResultsError, fn -> Gist.get_saved_gist!(saved_gist.id) end
    end

    test "change_saved_gist/1 returns a saved_gist changeset" do
      saved_gist = saved_gist_fixture()
      assert %Ecto.Changeset{} = Gist.change_saved_gist(saved_gist)
    end
  end
end
