defmodule ElixirElmBootstrap.LayoutView do

  use ElixirElmBootstrap.Web, :view

  import Guardian.Plug

  def user(conn) do
    current_resource(conn)
  end

  def user_json(conn) do
    Poison.encode!(user(conn))
  end


end
