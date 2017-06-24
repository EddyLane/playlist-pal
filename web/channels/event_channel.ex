defmodule ElixirElmBootstrap.EventChannel do

  use ElixirElmBootstrap.Web, :channel
  use Guardian.Phoenix.Socket, only: [:current_resource/1]

  def join("events:" <> username, _, socket) do

    user = current_resource(socket)

    if user.username != username do
      { :err, socket }
    end

    case user.username do
        username ->
            user_events = user
                |> assoc(:events)
                |> Repo.all
            {:ok, user_events, socket}
        _ ->
            {:err, socket }
    end

  end

end