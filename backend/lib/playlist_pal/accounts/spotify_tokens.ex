defmodule PlaylistPal.SpotifyTokens do

  use Ecto.Schema
  import Ecto.Changeset
  alias PlaylistPal.SpotifyTokens
  alias PlaylistPal.User

  schema "spotify_tokens" do
    field :access_token, :string
    field :refresh_token, :string

    belongs_to :user, User

    timestamps()
  end

  @required_fields ~w(access_token)a
  @optional_fields ~w(refresh_token)a

  def changeset(%SpotifyTokens{} = tokens, attrs) do
    tokens
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

end
