defmodule ElixirElmBootstrap.EventChannel do

  use ElixirElmBootstrap.Web, :channel
  use Guardian.Phoenix.Socket, only: [:current_resource/1]

  def join("events", _, socket) do
    user_events = current_resource(socket) |> assoc(:events)
    {:ok, Poison.encode!(user_events), socket}
  end


end