defmodule PlaylistPal.SpotifyTokens do

  use Ecto.Schema
  import Ecto.Changeset
  alias PlaylistPal.SpotifyTokens
  alias PlaylistPal.User

  schema "spotify_tokens" do
    field :access_token, :string
    field :refresh_token, :string

    belongs_to(:user, User)

    timestamps()
  end

  def changeset(%SpotifyTokens{} = user, attrs) do
    user
    |> cast(attrs, [:access_token, :refresh_token, :user_id])
    |> validate_required([:access_token, :user_id])
  end

end
