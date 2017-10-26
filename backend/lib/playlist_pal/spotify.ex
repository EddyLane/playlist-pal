defmodule PlaylistPal.Spotify do
  @moduledoc false

  @callback authenticate(String.t) :: {:ok, %Spotify.Credentials{}}

end
