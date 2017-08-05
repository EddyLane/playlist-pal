defmodule PlaylistPal.ApiAuthErrorHandler do

  import Plug.Conn, only: [halt: 1, send_resp: 3]

  def unauthenticated(conn, _) do
      conn
        |> send_resp(:unauthorized, "")
        |> halt()
  end

end