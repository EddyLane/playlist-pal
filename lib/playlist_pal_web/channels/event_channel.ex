defmodule PlaylistPalWeb.EventChannel do

  use PlaylistPalWeb, :channel
  use Phoenix.Channel
  import Guardian.Phoenix.Socket


  def join(_room, %{"guardian_token" => token}, socket) do

    case sign_in(socket, token) do
      {:ok, authed_socket, _guardian_params} ->

        user_events = current_resource(authed_socket)
          |> Ecto.assoc(:events)
          |> Repo.all

        :timer.sleep(:timer.seconds(3))

        {:ok, user_events, authed_socket}

      {:error, _} ->
        {:error, :invalid_token }
    end

  end

  def join(room, _, socket) do
    {:error,  :authentication_required }
  end

#  def handle_in("ping", _payload, socket) do
#    user = current_resource(socket)
#    broadcast(socket, "pong", %{message: "pong", from: user.email})
#    {:noreply, socket}
#  end


end