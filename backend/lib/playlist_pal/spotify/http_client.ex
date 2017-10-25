defmodule PlaylistPal.Spotify.HTTPClient do

  @behaviour PlaylistPal.Spotify

  alias Spotify.Credentials
  alias Spotify.Authentication

  def authenticate(conn = %Plug.Conn{}, params) do
    conn
    |> Credentials.new()
    |> Authentication.authenticate(params)
  end

end
