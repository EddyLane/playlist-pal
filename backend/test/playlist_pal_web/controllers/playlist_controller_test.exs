defmodule PlaylistPalWeb.PlaylistControllerTest do
  use PlaylistPalWeb.ConnCase

  alias PlaylistPal.Playlists
  alias PlaylistPal.Playlists.Playlist

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:playlist) do
    {:ok, playlist} = Playlists.create_playlist(@create_attrs)
    playlist
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all playlists", %{conn: conn} do
      conn = get conn, playlist_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create playlist" do
    test "renders playlist when data is valid", %{conn: conn} do
      conn = post conn, playlist_path(conn, :create), playlist: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, playlist_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some name"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, playlist_path(conn, :create), playlist: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update playlist" do
    setup [:create_playlist]

    test "renders playlist when data is valid", %{conn: conn, playlist: %Playlist{id: id} = playlist} do
      conn = put conn, playlist_path(conn, :update, playlist), playlist: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, playlist_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some updated name"}
    end

    test "renders errors when data is invalid", %{conn: conn, playlist: playlist} do
      conn = put conn, playlist_path(conn, :update, playlist), playlist: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete playlist" do
    setup [:create_playlist]

    test "deletes chosen playlist", %{conn: conn, playlist: playlist} do
      conn = delete conn, playlist_path(conn, :delete, playlist)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, playlist_path(conn, :show, playlist)
      end
    end
  end

  defp create_playlist(_) do
    playlist = fixture(:playlist)
    {:ok, playlist: playlist}
  end
end
