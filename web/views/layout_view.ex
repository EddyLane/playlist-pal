defmodule ElixirElmBootstrap.LayoutView do

  use ElixirElmBootstrap.Web, :view

  def user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def user_json(conn) do
    Poison.encode!(user(conn))
  end


end
