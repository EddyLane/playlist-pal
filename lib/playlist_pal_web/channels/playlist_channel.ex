defmodule PlaylistPalWeb.PlaylistChannel do

  use PlaylistPalWeb, :channel
  use Phoenix.Channel
  import Guardian.Phoenix.Socket
  alias PlaylistPal.Playlists

  def join("playlists:lobby", %{"guardian_token" => token}, socket) do
    case sign_in(socket, token) do
      {:ok, authed_socket, _guardian_params} ->
        {:ok, playlists(authed_socket), authed_socket}
      {:error, reason} ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def join(_room, _payload, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  defp playlists(socket) do
    socket
      |> current_resource
      |> Playlists.list_playlists
  end


end
