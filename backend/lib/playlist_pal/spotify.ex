defmodule PlaylistPal.Spotify do
  @moduledoc false

  @callback authenticate(String.t) :: {:ok, %Spotify.Credentials{}}

  @callback profile(String.t) :: {:ok, %Spotify.Profile{}}

end
