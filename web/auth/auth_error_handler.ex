defmodule ElixirElmBootstrap.AuthErrorHandler do

  import ElixirElmBootstrap.Router.Helpers
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import Plug.Conn, only: [halt: 1]

  def unauthenticated(conn, _) do
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt()
  end

end