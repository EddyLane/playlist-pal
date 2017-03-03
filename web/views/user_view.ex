defmodule ElixirElmBootstrap.UserView do
  use ElixirElmBootstrap.Web, :view
  alias ElixirElmBootstrap.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

end