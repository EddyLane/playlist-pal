defmodule ElixirElmBootstrap.LayoutView do

  use ElixirElmBootstrap.Web, :view

  def user(conn) do
    Guardian.Plug.current_resource(conn)
  end

end
