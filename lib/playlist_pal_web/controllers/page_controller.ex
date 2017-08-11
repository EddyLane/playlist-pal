defmodule PlaylistPalWeb.PageController do

  use PlaylistPalWeb, :controller
  import Guardian.Plug

  def app(conn, _params) do
    render conn, "app.html"
  end

end
