defmodule ElixirElmBootstrap.PageController do

  use ElixirElmBootstrap.Web, :controller
  import Guardian.Plug

  def index(conn, _params) do

    case current_resource(conn) do
      nil -> render conn, "index.html"
      user -> redirect conn, to: user_path(conn, :show, user.username)
    end

  end


end
