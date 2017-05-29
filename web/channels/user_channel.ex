defmodule ElixirElmBootstrap.UserChannel do

  use ElixirElmBootstrap.Web, :channel
  use Guardian.Phoenix.Socket, only: [:current_resource/1]

  def join("me", params, socket) do
    user = current_resource(socket)
    {:ok, user, socket}
  end

  def handle_in(event, params, socket) do
    user = current_resource(socket)
    handle_in(event, params, user, socket)
  end

  def handle_in(_, _, _, socket), do: {:reply, :ok, socket}

end