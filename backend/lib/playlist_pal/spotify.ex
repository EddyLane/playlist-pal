defmodule PlaylistPal.Spotify do
  @moduledoc false

  @callback authenticate(%Plug.Conn{}, map()) :: {:ok, %Spotify.Credentials{}}

end
