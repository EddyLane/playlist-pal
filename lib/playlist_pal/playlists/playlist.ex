defmodule NameSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end

defmodule PlaylistPal.Playlists.Playlist do

  use Ecto.Schema
  import Ecto.Changeset
  alias PlaylistPal.Playlists.Playlist

  schema "playlists" do
    field :name, :string
    field :slug, NameSlug.Type

    belongs_to :user, PlaylistPal.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(%Playlist{} = playlist, attrs) do
    playlist
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> NameSlug.maybe_generate_slug
    |> NameSlug.unique_constraint
  end

end
