defmodule ElxGist.Gists.Gist do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "gists" do
    field :name, :string
    field :description, :string
    field :markup_text, :string
    belongs_to :user, ElxGist.Accounts.User
    has_many :comments, ElxGist.Comments.Comment
    has_many :saved_gists, ElxGist.Gists.SavedGist

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(gist, attrs) do
    gist
    |> cast(attrs, [:name, :description, :markup_text, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_length(:markup_text, min: 0, max: 10000)
  end
end
