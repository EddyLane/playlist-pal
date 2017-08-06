defmodule PlaylistPalWeb.TrackChannel do

  use PlaylistPalWeb, :channel
  use Guardian.Phoenix.Socket, only: [:current_resource/1]

  def join("tracks", _, socket) do

    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do

    push socket, "new_track", %{
         name: "Float on",
         href: "href",
         id: "id",
         album: %{
             name:  "album",
             images: []
         },
         artists: []
     }

     {:noreply, socket}

  end

  def handle_in("new_track", params, socket) do



#    user = current_resource(socket)
#
#    changeset =
#        user
#        |> build_assoc(:tracks)
#        |> PlaylistPalWeb.Track.changeset(params)
#
#
#    case Repo.insert(changeset) do
#      {:ok, track} L
#    end
#
    {:reply, :ok, socket}
  end

end