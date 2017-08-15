defmodule PlaylistPalWeb.PlaylistController do

  use PlaylistPalWeb, :controller
  use Guardian.Phoenix.Controller

  alias PlaylistPal.Playlists
  alias PlaylistPal.Playlists.Playlist

  import PlaylistPalWeb.Endpoint, only: [broadcast: 3]

  action_fallback PlaylistPalWeb.FallbackController

  def create(conn, %{"playlist" => playlist_params}, user, _) do

    playlist_params = Map.put(playlist_params, "user_id", user.id)

    with {:ok, %Playlist{} = playlist} <- Playlists.create_playlist(playlist_params) do

      broadcast("playlists:lobby", "added", playlist)

      conn
      |> put_status(:created)
      |> render("show.json", playlist: playlist)

    end
  end

end
