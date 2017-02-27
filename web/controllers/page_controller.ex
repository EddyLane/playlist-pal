defmodule ElixirElmBootstrap.PageController do
  use ElixirElmBootstrap.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

end
