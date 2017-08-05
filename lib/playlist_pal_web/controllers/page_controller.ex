defmodule PlaylistPalWeb.PageController do

  use PlaylistPalWeb.Web, :controller
  import Guardian.Plug

  def index(conn, _params) do
    case current_resource(conn) do
      nil -> render conn, "index.html"
      user -> redirect conn, to: "/app"
    end
  end

  def app(conn, _params) do
    render conn, "app.html"
  end


end
