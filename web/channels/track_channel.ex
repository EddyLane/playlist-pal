defmodule ElixirElmBootstrap.TrackChannel do

  use ElixirElmBootstrap.Web, :channel
  use Guardian.Phoenix.Socket, only: [:current_resource/1]

  def join("tracks", params, socket) do
    user = current_resource(socket)

#    send(self, :after_join)

    {:ok, user, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "new_track", [%{
         name: "name",
         href: "href",
         id: "id",
         album: %{
             name:  "album",
             images: []
         },
         artists: []
     }]
     {:noreply, socket}
  end

  def handle_in("new_track", params, socket) do



#    user = current_resource(socket)
#
#    changeset =
#        user
#        |> build_assoc(:tracks)
#        |> ElixirElmBootstrap.Track.changeset(params)
#
#
#    case Repo.insert(changeset) do
#      {:ok, track} L
#    end
#
#    {:reply, :ok, socket}
  end

end