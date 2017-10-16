defmodule PlaylistPal.User do

  use Ecto.Schema
  import Ecto.Changeset
  alias PlaylistPal.User

  schema "users" do
    field :spotify_id, :string

    has_many(:spotify_tokens, PlaylistPal.SpotifyTokens)

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:spotify_id])
    |> validate_required([:spotify_id])
  end

end
