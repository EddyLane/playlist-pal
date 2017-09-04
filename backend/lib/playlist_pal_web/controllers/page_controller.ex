defmodule PlaylistPalWeb.PageController do

  use PlaylistPalWeb, :controller
  import Guardian.Plug

  def app(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Health check OK")
  end

end
