defmodule PlaylistPal.Spotify.HTTPClient do

  @behaviour PlaylistPal.Spotify

  alias Spotify.Credentials
  alias Spotify.Authentication
  alias Spotify.Profile

  def authenticate(spotify_auth_code) do
    %Credentials{}
    |> Authentication.authenticate(%{"code" => spotify_auth_code})
  end

  def profile(_) do
    {:ok, %Profile{}}
  end

end
