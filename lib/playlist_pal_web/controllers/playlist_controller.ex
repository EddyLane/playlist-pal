defmodule PlaylistPalWeb.PlaylistController do
  use PlaylistPalWeb, :controller

  alias PlaylistPal.Playlists
  alias PlaylistPal.Playlists.Playlist

  action_fallback PlaylistPalWeb.FallbackController

  def index(conn, _params) do
    playlists = Playlists.list_playlists()
    render(conn, "index.json", playlists: playlists)
  end

  def create(conn, %{"playlist" => playlist_params}) do
    with {:ok, %Playlist{} = playlist} <- Playlists.create_playlist(playlist_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", playlist_path(conn, :show, playlist))
      |> render("show.json", playlist: playlist)
    end
  end

  def show(conn, %{"id" => id}) do
    playlist = Playlists.get_playlist!(id)
    render(conn, "show.json", playlist: playlist)
  end

  def update(conn, %{"id" => id, "playlist" => playlist_params}) do
    playlist = Playlists.get_playlist!(id)

    with {:ok, %Playlist{} = playlist} <- Playlists.update_playlist(playlist, playlist_params) do
      render(conn, "show.json", playlist: playlist)
    end
  end

  def delete(conn, %{"id" => id}) do
    playlist = Playlists.get_playlist!(id)
    with {:ok, %Playlist{}} <- Playlists.delete_playlist(playlist) do
      send_resp(conn, :no_content, "")
    end
  end
end
