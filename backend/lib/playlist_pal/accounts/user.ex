defmodule PlaylistPal.User do

  use Ecto.Schema
  import Ecto.Changeset
  alias PlaylistPal.User
  alias PlaylistPal.SpotifyTokens

  schema "users" do
    field :spotify_id, :string
    field :image, :string, virtual: true

    has_one :spotify_tokens, SpotifyTokens

    timestamps()
  end

  @required_fields ~w(spotify_id)a

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:spotify_id)
    |> cast_assoc(:spotify_tokens, required: true)
  end

end
